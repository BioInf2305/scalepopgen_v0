process RUN_TREEMIX_DEFAULT{

    tag { "run_treemix_default_${prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/treemix/out_tree_default_m0", pattern:"*_out*",mode:"copy")

    input:
        tuple file(treemix_in), file(sample_map)

    output:
        path("*.vertices.gz"), emit: vertices
	path("*.llik"), emit:llik
	path("*.treeout.gz"), emit: treeout
	path("*.edges.gz"), emit: edges
	path("*.modelcov.gz"), emit: modelcov
	path("*.covse.gz"), emit: covse
	path("*.cov.gz"), emit: cov
	path("*.pdf"), emit: pdf

    when:
     task.ext.when == null || task.ext.when

    script:
        def args = ""
	def k_snps = params.k_snps
	def outgroup = params.outgroup
        if( outgroup != "none" ){
            args = args + " -root "+outgroup
        }
        prefix = treemix_in.baseName
        args = args + " -k "+k_snps

        """

        treemix -i ${treemix_in} -o ${prefix}_out ${args}

	#Rscript ${baseDir}/bin/plot_resid.r ${prefix}_out ${sample_map} ${prefix}_reside_out.pdf

	Rscript ${baseDir}/bin/plot_tree.r ${prefix}_out ${prefix}_tree_out.pdf

        """ 

}
