process CALC_WFST{

    tag { "calculating_pairwise_fst" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/vcftools/pairwise_fst/${prefix}/", mode:"copy")

    input:
        tuple val(prefix), path(vcf), path(pop1_file), path(pop2_file)

    output:
        tuple val("${pop1}_${pop2}"), path("*.weir.fst"), emit: pairwise_fst_out

    script:
        
        def args = ""
        if (params.fst_window_size > 0){
            args = args + " "+ "--fst-window-size "+ params.fst_window_size
        }
        if ( params.fst_step_size > 0 ) {
                args = args + " " + "--fst-window-step "+ params.fst_step_size
        
        }
        
        pop1 = pop1_file.getSimpleName()
        pop2 = pop2_file.getSimpleName()
        


        """

        vcftools --gzvcf ${vcf} --weir-fst-pop ${pop1_file} --weir-fst-pop ${pop2_file} $args --out ${prefix}_${pop1}_${pop2}


        """ 
}
