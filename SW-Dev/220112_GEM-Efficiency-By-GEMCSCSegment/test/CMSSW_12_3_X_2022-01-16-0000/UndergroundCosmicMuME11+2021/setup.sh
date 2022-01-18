#!/bin/sh
source /cvmfs/cms.cern.ch/cmsset_default.sh
cd ../../../CMSSW_12_3_X_2022-01-16-0000/src/
eval `scramv1 runtime -sh`
cd -

PROJECT=220112_GEM-Efficiency-By-GEMCSCSegment
SAMPLE=UndergroundCosmicMuME11+2021

if [[ $(hostname) == "gate" ]]; then
    DATA_DIR=/store/user/seyang/GEM/
elif [[ $(hostname) == "ui20.sdfarm.kr" ]]; then
    DATA_DIR=/xrootd/store/user/seyang/GEM/
else
    echo "unkown hostname: $(hostname)"
    exit 1
fi

OUTPUT_ROOT=${DATA_DIR}/${PROJECT}/${CMSSW_VERSION}/${SAMPLE}
JOB_BATCH_NAME_PREFIX=${PROJECT}__${CMSSW_VERSION}__${SAMPLE}

## helper functions
function check_output_root() {
    echo "check existence of OUTPUT_ROOT: ${OUTPUT_ROOT}"
    if [ -d ${OUTPUT_ROOT} ]; then
        echo "OUTPUT_ROOT found"
    else
        echo "OUTPUT_ROOT not found"
        if [[ $(hostname) == "gate" ]]; then
            mkdir -vp ${OUTPUT_ROOT}
        elif [[ $(hostname) == "ui20.sdfarm.kr" ]]; then
            mkdir -vp /xrootd_user/slowmoyang/xrootd2/GEM/${PROJECT}/${CMSSW_VERSION}/${SAMPLE}
        else
            echo "unkown hostname: $(hostname)"
            exit 1
        fi

    fi
}

function print_var() {
    VAR=${1}
    echo "${VAR}=${!VAR}"
}

function check_log_dir() {
    LOG_DIR=${1}
    if [ -d ${LOG_DIR} ]; then
        rm -f ${LOG_DIR}/*.log ${LOG_DIR}/*.out ${LOG_DIR}/*.err
    else
        mkdir -vp ${LOG_DIR}
    fi
}

function get_step() {
    CFG=${1}

    STEP=$(basename ${CFG})

    for SUFFIX in "_cfg.py" ".py"
    do
        if [[ ${STEP} == *${SUFFIX} ]]; then
            STEP=${STEP/${SUFFIX}/""}
            break
        fi
    done

    # return
    echo ${STEP}
}

function submit_empty() {
    CFG=${1}
    NUM_JOBS=${2}

    local STEP=$(get_step ${CFG})

    JOB_BATCH_NAME=${JOB_BATCH_NAME_PREFIX}__${STEP}
    OUTPUT_DIR=${OUTPUT_ROOT}/${STEP}
    LOG_DIR=./logs/${STEP}

    check_output_root
    check_log_dir ${LOG_DIR}

    COMMAND="gem-dqm-submit.py -o ${OUTPUT_DIR} -l ${LOG_DIR} -n ${NUM_JOBS} -b ${JOB_BATCH_NAME} ${CFG}"
    echo ${COMMAND}
    eval ${COMMAND}
}

function submit_pool() {
    PREV_CFG=${1}
    CFG=${2}

    local PREV_STEP=$(get_step ${PREV_CFG})
    local STEP=$(get_step ${CFG})

    JOB_BATCH_NAME=${JOB_BATCH_NAME_PREFIX}__${STEP}
    INPUT_DIR=${OUTPUT_ROOT}/${PREV_STEP}
    OUTPUT_DIR=${OUTPUT_ROOT}/${STEP}
    LOG_DIR=./logs/${STEP}

    check_output_root
    check_log_dir ${LOG_DIR}

    COMMAND="gem-dqm-submit.py -i ${INPUT_DIR} -o ${OUTPUT_DIR} -l ${LOG_DIR} -b ${JOB_BATCH_NAME} ${CFG}"
    echo ${COMMAND}
    eval ${COMMAND}
}

##########
print_var CMSSW_BASE
print_var CMSSW_VERSION
print_var OUTPUT_ROOT
print_var JOB_BATCH_NAME_PREFIX
