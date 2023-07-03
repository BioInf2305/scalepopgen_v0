process UPDATE_FAMILY_IDS{

    tag { "remove_indi_pca_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/genetic_structure/", mode:"copy")

    input:
        file(bed)
        file(new_fam_ids)

    output:
        path("${new_prefix}_update_fam_id*"), emit: update_fam_bed

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = bed[0].baseName
        def max_chrom = params.max_chrom
        def opt_arg = ""
        opt_arg = opt_arg + " --chr-set "+ max_chrom
	if( params.allow_extra_chrom ){
                
            opt_arg = opt_arg + " --allow-extra-chr "

        }

        opt_arg = opt_arg + " --out " +new_prefix+"_update_fam_id"



	"""
	    awk 'NR==FNR{familyId[\$1]=\$2;next}{print \$1,\$2,familyId[\$1],\$2}' ${new_fam_ids} ${new_prefix}.fam > updatedFamilyInfo.txt

	    plink -bfile ${new_prefix} --update-ids updatedFamilyInfo.txt ${opt_arg}
	    
	"""

}
