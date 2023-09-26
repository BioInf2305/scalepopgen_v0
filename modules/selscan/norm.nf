process NORM{

    tag { "norm_${pop}" }
    label "fourCpus"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/selscan/norm/${selscan_method}/${pop}", mode:"copy")

    input:
        tuple val(pop), path(selscan_out)
        val(selscan_method)

    output:
        tuple val(pop), path ("*norm*")

    script:
        
        def args = selscan_method == "ihs" ? "--ihs "+params.norm_ihs_args : "--xpehh "+params.norm_xpehh_args



        """
        norm ${args} --files ${selscan_out}

        """ 
        
}
