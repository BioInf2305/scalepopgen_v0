process CALC_WFST_ONE_VS_REMAINING{

    tag { "calculating_one_vs_remaining_fst" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/vcftools/wfst_one_vs_remaining/${prefix}/", mode:"copy")

    input:
        tuple val(prefix), path(vcf), path(pop1_file), path(pop2_file)

    output:
        tuple val(pop1), path("*.weir.fst"), emit: pairwise_fst_out

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
        awk 'NR==FNR{a[\$1];next}!(\$1 in a){print \$1}' ${pop1_file} ${pop2_file} > total_samples_excluding_${pop1}.txt

        vcftools --gzvcf ${vcf} --weir-fst-pop ${pop1_file} --weir-fst-pop total_samples_excluding_${pop1}.txt $args --out ${prefix}_${pop1}_vs_remaining.txt


        """ 
}
