process REMOVE_CUSTOM_INDI{

    tag { "remove_indi_pca_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
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
        new_prefix = bed[0].getSimpleName()
        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ params.max_chrom + " --threads "+task.cpus
        opt_args = opt_args + " --remove " + params.structure_remove_indi
        
	if( params.allow_extra_chrom ){
                
            opt_args = opt_args + " --allow-extra-chr "

            }

        opt_args = opt_args + " --make-bed --out " +new_prefix+"_rem_indi"
        
        """
        
        plink2 --bfile ${new_prefix} ${opt_args}


        """ 
}
