process GENERATE_INTERACTIVE_MANHATTAN_PLOT{

    tag { "generating_mahnattan_plot" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/interactive_manhattan_plots/${type_measure}/", mode:"copy")

    input:
        tuple val(prefix), path(result_files)
        val(type_measure)
        val(window_size)
        

    output:
        path("*.html")
        path("*_merged_results.1.txt")

    script:

        def sel_perc_threshold = params.sel_perc_cutoff

        manhattanp_yml = params.manhattplot_yml

        def opt_args = ""
        
        if(type_measure != "tajimas_d" && type_measure != "nucl_diversity_pi" ){
            opt_args = opt_args + " -r "
        }
        else{
            opt_args = opt_args+ "-r -V "
        }


            """
            cat ${result_files} | awk '\$0!~/CHROM/{print \$1, \$2, \$NF}' > ${prefix}_${type_measure}_merged_results.txt

            sort -k1,2 -V ${prefix}_${type_measure}_merged_results.txt > ${prefix}_${type_measure}_merged_results.1.txt

            sort -k3,3 ${opt_args} ${prefix}_${type_measure}_merged_results.1.txt > ${prefix}_${type_measure}_merged_results.2.txt

            tl="\$(wc -l ${prefix}_${type_measure}_merged_results.2.txt|awk -v v_sel_perc_threshold=${sel_perc_threshold} '{printf "%.0f", \$1*v_sel_perc_threshold/100}')"

            co="\$(awk -v v_tl=\$tl 'NR==v_tl{print \$NF}' ${prefix}_${type_measure}_merged_results.2.txt)"
            
            python3 ${baseDir}/bin/make_manhattan_plot.py ${prefix}_${type_measure}_merged_results.1.txt ${manhattanp_yml} \$co ${window_size} ${type_measure} ${prefix}_${type_measure}_merged_results 
            

            """ 
}
