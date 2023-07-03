process EST_PAIRWISE_FST{
    
    tag {"pairwise_vcf"}
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/pairwiseFst", mode:"copy")

    input:
        tuple file(pop1File), file(pop2File), val(chrom), file(vcfFile)

    output:
        path("*.weir.fst"), emit: pairwise_fst_out

    script:

        def Command = ""
        if ( params.fst_window_size > 0 ){
                Command = Command + " "+ "--fst-window-size "+ params.fst_window_size
        }

        if ( params.fst_step_size > 0 ) {
                Command = Command + " " + "--fst-window-step "+ params.fst_step_size
        
        }
        def pop1 = pop1File.baseName
        def pop2 = pop2File.baseName

        """

        vcftools --vcf ${vcfFile} --weir-fst-pop ${pop1File} --weir-fst-pop ${pop2File} --out ${pop1}_vs_${pop2} ${Command}

        """
}
