process RUN_SNPGDSPCA{

    tag { "running_snpgdspca_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.2"
    publishDir("${params.outDir}/genetic_structure/gds_pca/", mode:"copy")

    input:
        file(bed)

    output:
        path("${new_prefix}.{eigenvect,jpeg,varprop}")
        path("*.log")
        path("*.gds")
        path("*snprelate.eigenvect"), emit: eigenvect
        path("*snprelate.varprop"), emit: varprop
        

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = bed[0].baseName
        def max_chrom = params.max_chrom
        def opt_arg = ""
	if( params.pop_color_file != "none"){
                opt_arg = opt_arg + " -c "+ params.pop_color_file
        }
            

	"""

	Rscript ${baseDir}/bin/pca.r -b ${new_prefix} -C ${max_chrom} ${opt_arg}

        cp .command.log ${new_prefix}_snpgdspca.log

        awk 'NR==FNR{a[\$2]=\$1;next}{if(FNR==1){print \$0,"pop";next}else;print \$0,a[\$1]}' ${new_prefix}.fam ${new_prefix}.eigenvect > ${new_prefix}_snprelate.eigenvect

        awk 'NR>1{print \$1*100}' ${new_prefix}.varprop > ${new_prefix}_snprelate.varprop


	"""
}
