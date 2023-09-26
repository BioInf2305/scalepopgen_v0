process GENERATE_POP_COLOR_MAP{

    tag { "generating pop color map" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/", mode:"copy")

    input:
        path(map_or_fam_file)

    output:
        path ("pop_sc_color.map"), emit: m_pop_sc_colr
    
    script:
        
        f_pop_color = params.f_pop_color

        if( f_pop_color == "none" ){


        """

        awk '{if(NF==6){pop_count[\$1]++;next}else;pop_count[\$2]++;next}END{for(pop in pop_count){print pop,pop_count[pop]}}' ${map_or_fam_file} > f_pop_count.map

        awk 'NR==FNR{color[NR]=\$1;next}{print \$1,\$2,color[FNR]}' ${baseDir}/extra/hexcolorcodes.txt f_pop_count.map > pop_sc_color.map
        

        """ 
        }

        else{
        

        """

        awk '{if(NF==6){pop_count[\$1]++;next}else;pop_count[\$2]++;next}END{for(pop in pop_count){print pop,pop_count[pop]}}' ${map_or_fam_file} > f_pop_count.map

        awk 'NR==FNR{color[\$1]=\$2;next}\$1 in color{print \$1,\$2,color[\$1]}' ${f_pop_color} f_pop_count.map > pop_sc_color.map

        """

        }
}
