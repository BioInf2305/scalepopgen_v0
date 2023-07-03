process PLOT_GEO_MAP{

    tag { "plotting_sample_on_map" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.2"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/", mode:"copy")

    input:
        path(geo_map)
        path(tile_map)

    output:
        path ("*.html")
    
    script:

        """
        
        python3 ${baseDir}/bin/plot_sample_info.py ${geo_map} ${tile_map}


        """ 
}
