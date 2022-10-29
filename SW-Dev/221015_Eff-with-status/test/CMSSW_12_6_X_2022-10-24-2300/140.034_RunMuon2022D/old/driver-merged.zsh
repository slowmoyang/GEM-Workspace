cmsDriver.py step2  \
	--process reHLT \
	--step L1REPACK:Full,HLT:@relval2022,RAW2DIGI,L1Reco,RECO \
	--conditions auto:run3_hlt_relval \
	--data  \
	--eventcontent RECO \
	--datatier RECO \
	--era Run3 \
	--number -1  \
	--filein filelist:step1_dasquery.log \
	--lumiToProcess step1_lumiRanges.log \
	--fileout file:step2.root \
    --no_exec
