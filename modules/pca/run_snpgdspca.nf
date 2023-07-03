process RUN_SNPGDSPCA{

    tag { "running_snpgdspca_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.2"
    publishDir("${params.outDir}/genetic_structure/gds_pca/", mode:"copy")

    input:
        file(bed)

    output:
        path("*.{eigenvect,jpeg,varprop}")
        path("*.log")
        path("*.gds")

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


	"""
}
