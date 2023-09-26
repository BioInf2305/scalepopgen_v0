process RUN_TREEMIX_WITH_BOOTSTRAP{

    tag { "run_treemix_${random_num}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/treemix/out_tree_bootstrap", pattern:"*_out*",mode:"copy")

    input:
        tuple file(treemix_in), file(sample_id), val(random_num)

    output:
        path("*.vertices.gz"), emit: vertices
	path("*.llik"), emit:llik
	path("*.treeout.gz"), emit: treeout
	path("*.edges.gz"), emit: edges
	path("*.modelcov.gz"), emit: modelcov
	path("*.covse.gz"), emit: covse
	path("*.cov.gz"), emit: cov
	path("*.pdf"), emit: tiff

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
        args = args + " -k "+k_snps+ " -seed "+ random_num + " -bootstrap"

        """

        treemix -i ${treemix_in} -o ${prefix}_${random_num}_out -${args}

	#Rscript ${baseDir}/bin/plot_resid.r ${prefix}_${random_num}_out ${sample_id} ${prefix}.${random_num}_out.pdf

	Rscript ${baseDir}/bin/plot_tree.r ${prefix}_${random_num}_out ${prefix}_${random_num}_tree_out.pdf

        """ 

}
