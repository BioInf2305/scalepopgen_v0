process UPDATE_CHROM_IDS{

    tag { "updating_chrom_ids" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/plink/update_chrom_ids/", mode:"copy")

    input:
        file(bed)

    output:
        path("${new_prefix}_update_chrm_ids*.{bed,bim,fam}"), emit: update_chromids_bed
        path("*.log")

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = bed[0].getSimpleName()
        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ params.max_chrom + " --threads "+task.cpus
	if( params.allow_extra_chrom ){
                
            opt_args = opt_args + " --allow-extra-chr "

        }

        opt_args = opt_args + " --make-bed --out " +new_prefix+"_update_chrm_ids"



	"""
	    awk -v cnt=0 '{if(!(\$1 not in a)){a[\$1];cnt++;print \$1,cnt}}' ${new_prefix}.bim > old_new_ids.txt

	    plink2 -bfile ${new_prefix} ${opt_args}

            awk 'NR==FNR{a[\$1]=\$2;next}{print a[\$1],\$2,\$3,\$4,\$5,\$6}' old_new_ids.txt ${new_prefix}_update_chrm_ids.bim>${new_prefix}_update_chrm_ids.1.bim
        
            mv ${new_prefix}_update_chrm_ids.1.bim ${new_prefix}_update_chrm_ids.bim 
	    
	"""

}
