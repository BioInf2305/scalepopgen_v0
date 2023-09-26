process CREATE_NEW_SAMPLE_MAP{

    tag { "create_new_sample_map" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/sample_info/", mode:"copy")
    container "popgen48/scalepopgen:0.1.1"

    input:
        path(sample_map)

    output:
        path ("new_sample_pop.map"), emit: new_sample_map
        path ("pop_remove_ids.1")

    script:
    
        def min_samp_sel = params.min_samples_per_pop
        def skip_pop = params.skip_pop
        def skip_sel_outgroup = params.skip_sel_outgroup
        def outgroup = params.outgroup
        
        """
        
        awk -v min_samp=${min_samp_sel} -v outgrp=${outgroup} '{if(\$2!=outgrp){pop[\$2]++;next}}END{for(i in pop){if(pop[i] <= min_samp){print i}}}' ${sample_map} > pop_remove.ids

        if [[ ${skip_pop} != "none" ]]; then cat ${skip_pop} pop_remove.ids > pop_remove_ids.1;else mv pop_remove.ids pop_remove_ids.1;fi

        if ${skip_sel_outgroup};then echo ${outgroup} >> pop_remove_ids.1;fi

        if [[ "\$(wc -l <pop_remove_ids.1)" -gt 0 ]]; then awk 'NR==FNR{pop[\$1];next}!(\$2 in pop){print \$1>>\$2".txt"}' pop_remove_ids.1 ${sample_map};else awk '{print \$1,\$2}' ${sample_map} > new_sample_pop.map;fi
        

        """ 
}
