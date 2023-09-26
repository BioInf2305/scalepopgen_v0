process CALC_INDIV_SUMMARY{

    tag { "calculating_chromosomewise_summary_${chrom}" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/summary_stats/indiv_stats/", mode:"copy")

    input:
        tuple val(chrom), path(vcf), path(vcf_idx), path(sample_map)

    output:
        path("${chrom}_sample_summary.scount"), emit: samplesummary
        path("${chrom}*.idepth"), emit: sampledepthinfo
        
    
    script:

        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ params.max_chrom+" --threads "+task.cpus
	if( params.allow_extra_chrom ){
                
            opt_args = opt_args + " --allow-extra-chr "

            }
        opt_args = opt_args + " --out "+chrom+"_sample_summary"

        """
        plink2 --vcf ${vcf} --nonfounders --sample-counts ${opt_args}

        vcftools --gzvcf ${vcf} --depth --out ${chrom}_depth_info

        """ 
}
