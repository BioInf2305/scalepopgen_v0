process FILTER_SNPS_FROM_BED{

    tag { "filter_snps_${prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.2"
    publishDir("${params.outDir}/plink/sites_filtered/", mode:"copy")

    input:
        file(bed)

    output:
        path("${prefix}_filt_sites*"), emit: filt_sites_bed
        path("*.log" ), emit: log_file

    when:
        task.ext.when == null || task.ext.when

    script:
        prefix = bed[0].baseName
        def max_chrom = params.max_chrom
        def opt_arg = ""
        opt_arg = opt_arg + " --chr-set "+ max_chrom
	if( params.allow_extra_chrom ){
                
            opt_arg = opt_arg + " --allow-extra-chr "

            }

        if ( params.remove_snps != "none" ){
        
            opt_arg = opt_arg + " --exclude " + params.remove_snps
        }
        
        if ( params.max_missing > 0 ){
        
            opt_arg = opt_arg + " --geno " + params.max_missing
        }

        if ( params.hwe > 0 ){
        
            opt_arg = opt_arg + " --hwe " + params.hwe
        }

        if ( params.maf > 0 ){
        
            opt_arg = opt_arg + " --maf " + params.maf
        }

        opt_arg = opt_arg + " --make-bed --out " + prefix +"_filt_sites"
        
        """
	
        plink2 --bfile ${prefix} ${opt_arg}
            

        """ 
}
