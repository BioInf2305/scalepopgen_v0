process EST_BESTK_PLOT {

    tag { "estimating_bestK" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/genetic_structure/admixture/", mode:"copy")
    errorStrategy 'ignore'

    input:
	path(k_cv_log_files)
        path(pq_files)
        path(bed)
        path(m_pop_sc_color)

    output:
    	path("*.html")

    when:
     	task.ext.when == null || task.ext.when

    script:

        def bed_prefix = bed[0].getSimpleName()
        def plot_pop_order = params.plot_pop_order
        def admixture_yml = params.admixture_yml
        def outprefix = bed[0].getSimpleName()+"_q_mat"
        
        """
	
	python3 ${baseDir}/bin/est_best_k_and_plot.py "global" ${k_cv_log_files}

        awk '{print \$3}' ${m_pop_sc_color} > color.txt

	k_array=(`find ./ -maxdepth 1 -name "best_k*.html"`)

        if [[ ${plot_pop_order} != "none" ]];then awk '{print \$1}' ${plot_pop_order} > plot_pop_order.txt;else awk '{pop[\$1]}END{for(id in pop){print id}}' ${bed_prefix}.fam > plot_pop_order.txt;fi
        
        if [ \${#k_array[@]} -gt 0 ];then regex='./best_k_([0-9]+)*'; [[ \${k_array[0]} =~ \${regex} ]];python3 ${baseDir}/bin/plot_interactive_q_mat.py -q *.\${BASH_REMATCH[1]}.Q -f ${bed_prefix}.fam -y ${admixture_yml} -c color.txt -o ${outprefix} -s plot_pop_order.txt;fi
        
	""" 

}
