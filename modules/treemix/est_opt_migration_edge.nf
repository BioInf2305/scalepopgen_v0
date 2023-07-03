process EST_OPT_MIGRATION_EDGE{

    tag { "estimate_optimal_mig_edge" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container 'maulik23/scalepopgen:0.1.1'
    publishDir("${params.outDir}/treemix", pattern:"OptMResults*",mode:"copy")

    input:
        path(llik)
	    path(modelcov)
	    path(cov)

    output:
        path("OptMResults*")

    when:
     task.ext.when == null || task.ext.when
    
   
    script:
        

        """
	    Rscript ${baseDir}/bin/est_opt_mig_edge.r -d `pwd` > optMResults.log 2>&1

        """ 
}
