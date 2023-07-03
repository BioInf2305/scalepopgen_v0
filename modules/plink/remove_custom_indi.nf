process REMOVE_CUSTOM_INDI{

    tag { "remove_indi_pca_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.2"
    publishDir("${params.outDir}/plink/rem_indi_genetic_structure/", mode:"copy")

    input:
        file(bed)
        file(rem_indi)

    output:
        path("${new_prefix}_rem_indi.{bed,bim,fam}"), emit: rem_indi_bed
        path("*.log")

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = bed[0].baseName
        def opt_arg = ""
        opt_arg = opt_arg + " --chr-set "+ params.max_chrom
        opt_arg = opt_arg + " --remove " + params.structure_remove_indi
        
	if( params.allow_extra_chrom ){
                
            opt_arg = opt_arg + " --allow-extra-chr "

            }

        opt_arg = opt_arg + " --make-bed --out " +new_prefix+"_rem_indi"
        
        """
        
        plink2 --bfile ${new_prefix} ${opt_arg}


        """ 
}
