process PLOT_GEO_MAP{

    tag { "plotting_sample_on_map" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/", mode:"copy")

    input:
        path(geo_map)
        path(tile_map)
        path(m_pop_sc_colr)

    output:
        path("*.html")
        path("geo_map_file.txt")
    
    script:

        f_pop_cord = params.f_pop_cord

        """

        awk 'BEGIN{OFS="\t"}NR==FNR{pop_cord[\$1]=\$2;next}\$1 in pop_cord{print pop_cord[\$1],\$1,\$1,\$2,\$3}' ${f_pop_cord} ${m_pop_sc_colr} > geo_map_file.txt

        python3 ${baseDir}/bin/plot_sample_info.py geo_map_file.txt ${geo_map} ${tile_map} 


        """ 
}
