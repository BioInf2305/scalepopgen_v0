process RUN_ADMIXTURE_DEFAULT{

    tag { "run_admixture_${k}" }
    label "sixteenCpus"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/genetic_structure/admixture/", mode:"copy")

    input:
        tuple val(k), path(bed), path(bim), path(fam)

    output:
        path("${new_prefix}.${k}.{P,Q}"), emit: pq_files
	path("${new_prefix}.${k}.log"), emit: log_file
    when:
     	task.ext.when == null || task.ext.when

    script:
        new_prefix = bed[0].getSimpleName()
        def opt_args = ""
        opt_args = opt_args + " -C "+ params.termination_criteria + " -j"+ task.cpus
        if ( params.cross_validation > 0 ){
                opt_args = opt_args + " --cv="+params.cross_validation
            }

        """

        admixture ${opt_args} ${bed} ${k} >& ${new_prefix}.${k}.log


        """ 

}
