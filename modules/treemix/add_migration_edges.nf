process ADD_MIGRATION_EDGES{

    tag { "adding_edge_${itr}_${mig}_treemix" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container 'popgen48/scalepopgen:0.1.1'
    publishDir("${params.outDir}/treemix/out_tree_mig", mode:"copy")

    input:
        tuple val(itr), val(mig), file(treemix_in), file(pop_id)

    output:
        path("*.vertices.gz"), emit: vertices
	    path("*.llik"), emit:llik
	    path("*.treeout.gz"), emit: treeout
	    path("*.edges.gz"), emit: edges
	    path("*.modelcov.gz"), emit: modelcov
	    path("*.covse.gz"), emit: covse
	    path("*.cov.gz"), emit: cov
	    path("*.pdf"), emit:pdf

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
	int randNum = (Math.abs(new Random().nextInt() % params.upper_limit) + 1)
	int randBlock = 100 + (Math.abs(new Random().nextInt() % params.k_snps) + 1)
        args = args + " -k "+ randBlock + " -global -m "+mig+" -seed "+ randNum + " -bootstrap"

        """
	

        treemix -i ${treemix_in} -o ${prefix}.${itr}.${mig} ${args}

	#Rscript ${baseDir}/bin/plot_resid.r ${prefix}.${itr}.${mig} ${pop_id} ${prefix}.${itr}.${mig}.resid.pdf

	Rscript ${baseDir}/bin/plot_tree.r ${prefix}.${itr}.${mig} ${prefix}.${itr}.${mig}.treeOut.pdf

        """ 
}
