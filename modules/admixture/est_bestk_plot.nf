process EST_BESTK_PLOT {

    tag { "estimating_bestK" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/genetic_structure/admixture/", mode:"copy")
    errorStrategy 'ignore'

    input:
	path(k_cv_log_files)
        path(pq_files)
        path(bed)

    output:
    	path("*.png")

    when:
     	task.ext.when == null || task.ext.when

    script:

        def bed_prefix = bed[0].getSimpleName()
        def pop_labels = params.pop_labels
        
        """
	
	python3 ${baseDir}/bin/est_best_k_and_plot.py "global" ${k_cv_log_files}

	k_array=(`find ./ -maxdepth 1 -name "best_k*.png"`)

        if [[ ${pop_labels} != "none" ]];then awk 'NR==FNR{fam_id[\$1]=\$2;next}{print \$1,fam_id[\$1]}' $pop_labels ${bed_prefix}.fam > pop_labels.txt;else awk '{print \$1}' ${bed_prefix}.fam > pop_labels.txt;fi
        
        if [ \${#k_array[@]} -gt 0 ];then regex='./best_k_([0-9]+)*'; [[ \${k_array[0]} =~ \${regex} ]];Rscript ${baseDir}/bin/plot_q_matrix.r -q *.\${BASH_REMATCH[1]}.Q  -l pop_labels.txt -k \${BASH_REMATCH[1]}; fi
        
	""" 

}
