process RUN_CONSENSE {

    tag { "run_phylip_consensus" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/treemix/consensus_trees", pattern:"out*",mode:"copy")

    input:
        path(trees)

    output:
        path("out*")

    when:
     task.ext.when == null || task.ext.when

    script:
        

        """
	zcat ${trees} > treemixBootstrapped.trees
	
	phylip consense << inputStarts
	treemixBootstrapped.trees
	Y
	inputStarts

        """ 

}
