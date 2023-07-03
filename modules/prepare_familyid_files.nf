process PREPARE_FAMILYID_FILES{

    tag { "preparing_familyid_files" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"

    input:
        path(id)

    output:
        path ("*.sampleId.txt")

    script:
        def includePops = params.includePops
        def excludePops = params.excludePops
        
        """
        python3 ${baseDir}/bin/makeFamIdFiles.py -m ${id} -P ${includePops} -p ${excludePops}

        """ 
}
