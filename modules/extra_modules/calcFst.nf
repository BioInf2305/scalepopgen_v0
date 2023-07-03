#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//plinkContainer = "biocontainers/plink1.9:v1.90b6.6-0.1.12-1-deb_cv1"
pythonContainer = "maulik23/scalepopgen:1.0.9"


process prepareFstTreeInput {

    tag { "prepare_fst_input" }
    label "oneCpu"
    container pythonContainer

    input:
        tuple val(chrom), file(plink_files)

    output:
        path ("*.sampleId.txt")

    script:
        
        """

        python3 ${baseDir}/bin/prepareFstTreeInput.py -f ${chrom}.fam

        """ 

}

process prepareFstSelectionInput {

    tag { "prepare_fst_selection_input" }
    label "oneCpu"
    container pythonContainer

    input:
        tuple val(chrom), file(plink_files)

    output:
        path ("*.txt")

    script:
        
        if( params.diffSampleSet == "No" ){

        """

        python3 ${baseDir}/bin/prepareFstSelectionInput.py -f ${chrom}.fam

        """ 
        }

        else{
            def sampleSet = params.diffSampleSet

        """
        python3 ${baseDir}/bin/prepareFstSelectionInput.py -f ${sampleSet}

        """
        }

}

process plinkToVcf{

    tag {"plink_to_vcf"}
    label "oneCpu"
    container pythonContainer

    input:
        tuple val(chrom), file(plink_files)

    output:
        tuple val(chrom), file("*.vcf")

    script:
        def max_chrm = params.chrm_set

        """

        plink --bfile ${chrom} --chr-set ${max_chrm} --nonfounders --recode vcf-iid --out ${chrom}

        """

}

process pairwiseFst{
    
    publishDir(params.fst_output_dir, pattern:"*.weir.fst",mode:"copy")
    tag {"pairwise_vcf"}
    label "oneCpu"
    container pythonContainer

    input:
        tuple val(pop1), file(pop1File), val(pop2), file(pop2File), val(chrom), file(vcfFile)

    output:
        path("*.weir.fst")

    script:

        def fst_window_size = params.fst_window_size
        def fst_step_size   = params.fst_step_size
        def Command = ""
        if ( fst_window_size > 0 ){
                Command = Command + " "+ "--fst-window-size "+ fst_window_size
        }

        if (fst_step_size > 0) {
                Command = Command + " " + "--fst-window-step "+ fst_step_size
        
        }

        """
        vcftools --vcf ${vcfFile} --weir-fst-pop ${pop1File} --weir-fst-pop ${pop2File} --out ${pop1}_vs_${pop2} ${Command}

        """

}

process makePopVcf{
    
    tag {"vcf_${pop1}"}
    label "oneCpu"
    container pythonContainer

    input:
        tuple val(pop1), file(pop1File), val(chrom), file(vcfFile)

    output:
        tuple val(pop1), path("*.recode.vcf")

    script:


        """
        vcftools --vcf ${vcfFile} --keep ${pop1File} --recode --out ${pop1}

        """

}

process calcTajimaD{
    
    publishDir(params.tajimaD_output_dir, pattern:"*Tajima.D",mode:"copy")
    tag {"tajimas_D_${popFile}"}
    label "oneCpu"
    container pythonContainer

    input:
        tuple val(pop), file(vcfFile)

    output:
        path("*Tajima.D")

    script:

        def fst_window_size = params.fst_window_size

        """

        vcftools --vcf ${vcfFile} --out ${pop} --TajimaD ${fst_window_size}

        """

}

process calcWindowPi{
    
    publishDir(params.windowPi_output_dir, pattern:"*windowed.pi",mode:"copy")
    tag {"windowPi_${pop}"}
    label "oneCpu"
    container pythonContainer

    input:
        tuple val(pop), file(vcfFile)

    output:
        path("*windowed.pi")

    script:

        def fst_window_size = params.fst_window_size

        """

        vcftools --vcf ${vcfFile} --out ${pop} --window-pi ${fst_window_size}

        """

}

process pairwiseFstSelection{
    
    publishDir(params.fst_output_dir, pattern:"*.weir.fst",mode:"copy")
    tag {"pairwise_vcf"}
    label "oneCpu"
    container pythonContainer

    input:
        tuple val(pop1), file(pop1File), val(pop2), file(pop2File), val(chrom), file(vcfFile)

    output:
        path("*.weir.fst")

    script:

        def fst_window_size = params.fst_window_size
        def fst_step_size   = params.fst_step_size
        def Command = ""
        if ( fst_window_size > 0 ){
                Command = Command + " "+ "--fst-window-size "+ fst_window_size
        }

        if (fst_step_size > 0) {
                Command = Command + " " + "--fst-window-step "+ fst_step_size
        
        }

        """
        vcftools --vcf ${vcfFile} --weir-fst-pop ${pop1File} --weir-fst-pop ${pop2File} --out ${pop1}_vs_${pop2} ${Command}

        """

}

process makeFstNjTree{
    
    publishDir(params.fst_output_dir, pattern:"*.nwick",mode:"copy")
    tag {"njTreeBasedOnFst"}
    label "oneCpu"
    container pythonContainer

    input:
        file(pairwiseFstFiles)

    output:
        file("*.nwick")


    script:

    
    """
    
    python3 ${baseDir}/bin/makeFstTree.py -i ${pairwiseFstFiles} -o Trial.nwick

    """
}


def returnPairedDiffPopT( fileListPop ){

        file1 = fileListPop.flatten().map { file -> tuple(file.baseName, file) }
        file2 = fileListPop.flatten().map { file -> tuple(file.baseName, file) }
        filePairs = file1.combine(file2)
        filePairsB = filePairs.branch{ file1Prefix, file1Path, file2Prefix, file2Path ->

            samePop : file1Prefix == file2Prefix
                return tuple(file1Prefix, file1Path, file2Prefix, file2Path)
            diffPop : file1Prefix != file2Prefix
                return tuple(file1Prefix, file1Path, file2Prefix, file2Path)
        
        }
        return filePairsB.diffPop

}


def returnPairedPooledPopT( fileListPooledPop ){

        fileListPooledPopT  = fileListPooledPop.flatten().map { file -> tuple(file.baseName, file) }
        filePooledPopB = fileListPooledPopT.branch{ file1Prefix, file1Path ->

            diffPooledPop : file1Prefix =~ /Exclude/
                return tuple(file1Prefix, file1Path)
            samePooledPop : true
                return tuple(file1Prefix, file1Path)
        
        }
        filePairsPooledPopB = filePooledPopB.diffPooledPop.combine(filePooledPopB.samePooledPop)
        filePairsPooledPopBB = filePairsPooledPopB.branch{ file1Prefix, file1Path, file2Prefix, file2Path ->
            
            group1 = file1Prefix =~ /(Exclude)\_(.+)/
            group2 = file2Prefix =~ /([A-Za-z0-9\._]+?)\.(sampleId)/
            

            reqPair : group1[0][2] == group2[0][1]
                return tuple(file1Prefix, file1Path, file2Prefix, file2Path)
            NotReqPair : group1[0][2] != group2[0][1]
                return tuple(file1Prefix, file1Path, file2Prefix, file2Path)
        }
        return filePairsPooledPopBB.reqPair
}

workflow CALCFST {
    take:
       filtered_plink_file
    main:
        filtered_vcf_file = plinkToVcf( filtered_plink_file )
        fileList       = prepareFstTreeInput( filtered_plink_file )
        if (params.tajimaD == "Yes" || params.windowPi == "Yes"  ){
           fileTuple = fileList.flatten().map { file -> tuple(file.baseName, file) }
           popVcfFilePairsT = fileTuple.combine(filtered_vcf_file)
           popVcfFileT = makePopVcf(popVcfFilePairsT)
          if (params.tajimaD == "Yes" ){
          calcTajimaD(popVcfFileT)
          }
          if(params.windowPi == "Yes" ){
          calcWindowPi(popVcfFileT)
          }
        }
        if (params.fstBasedTree == "Yes" ){
        finalFilePairsListForTree = returnPairedDiffPopT( fileList )
        finalFilesThreeFilesT      = finalFilePairsListForTree.combine(filtered_vcf_file)
        pairwiseFstFilesOut = pairwiseFst(finalFilesThreeFilesT).collect()
        makeFstNjTreeOut = makeFstNjTree(pairwiseFstFilesOut)
        }
        if (params.selection == "Yes"){
        fileListSelection       = prepareFstSelectionInput( filtered_plink_file )
        finalFilePairsPooledPop = returnPairedPooledPopT( fileListSelection )
        finalFilesThreeFilesP     = finalFilePairsPooledPop.combine(filtered_vcf_file)
        pairwiseFstSelection(finalFilesThreeFilesP)
            }
}
