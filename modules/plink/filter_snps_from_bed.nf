process FILTER_SNPS_FROM_BED{

    tag { "filter_snps_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/plink/sites_filtered/", mode:"copy")

    input:
        file(bed)

    output:
        path("${new_prefix}_filt_site*.{bed,bim,fam}"), emit: filt_sites_bed
        path("*.log" ), emit: log_file

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = bed[0].getSimpleName()
        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ params.max_chrom
	if( params.allow_extra_chrom ){
                
            opt_args = opt_args + " --allow-extra-chr "

            }

        if ( params.remove_snps != "none" ){
        
            opt_args = opt_args + " --exclude " + params.remove_snps
        }
        
        if ( params.max_missing > 0 ){
        
            opt_args = opt_args + " --geno " + params.max_missing
        }

        if ( params.hwe > 0 ){
        
            opt_args = opt_args + " --hwe " + params.hwe
        }

        if ( params.maf > 0 ){
        
            opt_args = opt_args + " --maf " + params.maf
        }

        opt_args = opt_args + " --make-bed --out " + new_prefix +"_filt_sites"
        
        """
	
        plink2 --bfile ${new_prefix} ${opt_args}
            

        """ 
}
