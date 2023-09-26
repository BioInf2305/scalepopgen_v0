process FILTER_SITES{

    tag { "filter_sites_${chrom}" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/vcftools/sites_filtered/", mode:"copy")

    input:
        tuple val(chrom), file(f_vcf)

    output:
        tuple val(chrom), path ("*filt_sites.vcf.gz"), path("*filt_sites.vcf.gz.tbi"), emit: s_chrom_vcf_tbi
        path("*.log"), emit: log
    
    script:
        def opt_arg = ""
        prefix = f_vcf.getSimpleName()
        if(params.maf >= 0){
            opt_arg = opt_arg + " --maf "+params.maf
        }
        if(params.min_meanDP >= 0){
            opt_arg = opt_arg + " --min-meanDP "+params.min_meanDP
        }
        if(params.max_meanDP >= 0){
            opt_arg = opt_arg + " --max-meanDP "+params.max_meanDP
        }
        if(params.hwe >= 0){
            opt_arg = opt_arg + " --hwe "+params.hwe
        }
        if(params.max_missing >= 0){
            opt_arg = opt_arg + " --max-missing "+params.max_missing
        }
        if(params.minQ >= 0){
            opt_arg = opt_arg + " --minQ "+params.minQ
        }
        if(params.remove_snps != "none"){
            opt_arg = opt_arg + " --exclude-positions "+params.remove_snps
        }

        """
        
        vcftools --gzvcf ${f_vcf} ${opt_arg} --recode --stdout |sed "s/\\s\\.:/\t.\\/.:/g"|bgzip -c > ${prefix}_filt_sites.vcf.gz

        tabix -p vcf ${prefix}_filt_sites.vcf.gz

        cp .command.log ${prefix}_filter_sites.log


        """ 
}
