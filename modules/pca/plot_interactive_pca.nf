process PLOT_INTERACTIVE_PCA{

    tag { "plot_interactive_pca" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/genetic_structure/interactive_plots/pca/", mode:"copy")

    input:
        path(eigenvect)
        path(eigenval)
        path(m_pop_sc_col)

    output:
        path("*.html")
        path("*.log")
        path("pop_markershape_col.txt")
        

    when:
        task.ext.when == null || task.ext.when

    script:
        
        prefix = eigenvect.getSimpleName()

        pca_plot_param = params.pca_yml

        f_pop_marker = params.f_pop_marker

        if ( f_pop_marker == "none"){

	"""

        awk 'NR==FNR{markershape[NR]=\$0;next}{col_cnt=int(rand() * 20)+5;print \$1,markershape[col_cnt],\$3}' ${baseDir}/extra/markershapes.txt ${m_pop_sc_col} > pop_markershape_col.txt

        python ${baseDir}/bin/plot_interactive_pca.py ${eigenvect} ${eigenval} pop_markershape_col.txt ${pca_plot_param} ${prefix}

        cp .command.log plot_interactive_pca_${prefix}.log

	"""

        }
        else{

	"""

        awk 'NR==FNR{markershape[\$1]=\$2;next}{print \$1,markershape[\$1],\$3}' ${f_pop_marker} ${m_pop_sc_col} > pop_markershape_col.txt

        python ${baseDir}/bin/plot_interactive_pca.py ${eigenvect} ${eigenval} pop_markershape_col.txt ${pca_plot_param} ${prefix}
        
        cp .command.log plot_interactive_pca_${prefix}.log

	"""

        }
}
