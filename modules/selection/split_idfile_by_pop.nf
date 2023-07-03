process SPLIT_IDFILE_BY_POP{

    tag { "splitting_idfile_by_pop" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/input", mode:"copy")
    container "maulik23/scalepopgen:0.1.1"

    input:
        path(sample_map)

    output:
        path ("*.txt"), emit: splitted_samples
        path ("pop_remove_ids.1")

    script:
    
        def min_samp_sel = params.min_samples_per_pop
        def skip_pop = params.skip_pop
        
        """
        
        awk -v min_samp=${min_samp_sel} '{pop[\$1]++;next}END{for(i in pop){if(pop[i] >= min_samp){print i}}}' ${sample_map} > pop_remove.ids

        if [[ ${skip_pop} != "none" ]]; then cat ${skip_pop} pop_remove.ids > pop_remove_ids.1;else mv pop_remove.ids pop_remove_ids.1;fi

        if [[ "\$(wc -l <pop_remove_ids.1)" -gt 0 ]]; then awk 'NR==FNR{pop[\$1];next}!(\$2 in pop){print \$1>>\$2".txt"}' pop_remove_ids.1 ${sample_map};else awk '{print \$1>>\$2".txt"}' ${sample_map};fi

        """ 
}
