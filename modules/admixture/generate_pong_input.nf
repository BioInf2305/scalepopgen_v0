process GENERATE_PONG_INPUT{

    tag { "generating_pong_input" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/genetic_structure/admixture/", mode:"copy")

    input:
	path(k_cv_log_files)

    output:
	path("*.map")

    when:
     	task.ext.when == null || task.ext.when

    script:

	
        
        """
	
	python3 ${baseDir}/bin/generate_pong_input.py ${k_cv_log_files}
	
        
	""" 

}
