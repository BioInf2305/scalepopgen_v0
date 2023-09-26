process SPLIT_IDFILE_BY_POP{

    tag { "splitting_idfile_by_pop" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/input_pop/${type_analysis}", mode:"copy")
    container "popgen48/scalepopgen:0.1.1"

    input:
        path(sample_map)
        val(type_analysis)

    output:
        path ("*.txt"), emit: splitted_samples
        path ("pop_remove_ids.1")
        path ( "included_samples.csv" ), emit: iss

    script:
    
        def min_samp_sel = params.min_samples_per_pop
        def skip_pop = params.skip_pop
        def skip_sel_outgroup = params.skip_sel_outgroup
        def outgroup = params.outgroup
        
        """
        
        awk -v min_samp=${min_samp_sel} -v outgrp=${outgroup} '{if(\$2!=outgrp){pop[\$2]++;next}}END{for(i in pop){if(pop[i] <= min_samp){print i}}}' ${sample_map} > pop_remove.ids

        if [[ ${skip_pop} != "none" ]]; then cat ${skip_pop} pop_remove.ids > pop_remove_ids.1;else mv pop_remove.ids pop_remove_ids.1;fi

        if ${skip_sel_outgroup};then echo ${outgroup} >> pop_remove_ids.1;fi

        if [[ "\$(wc -l <pop_remove_ids.1)" -gt 0 ]]; then awk 'NR==FNR{pop[\$1];next}!(\$2 in pop){print \$1>>\$2".txt"}' pop_remove_ids.1 ${sample_map};else awk '{print \$1>>\$2".txt"}' ${sample_map};fi
        
        cat *.txt > included_samples.csv

        """ 
}
