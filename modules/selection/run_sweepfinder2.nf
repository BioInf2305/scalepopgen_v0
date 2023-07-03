process RUN_SWEEPFINDER2{

    tag { "sweepfinder_input_${pop}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/selection/results/clr/", mode:"copy")

    input:
        tuple val( pop ), path( freqs ), path( recomb ), path( afs )

    output:
        path ( "${out_prefix}*" )

    script:
        def args = ""
        out_prefix = freqs.baseName
        if ( !params.use_precomputed_afs && params.use_recomb_map == "none" ){
            if ( params.grid_points > 0 ){
                args = " -s "+ params.grid_points + " "+freqs
            }
            else{
                args = " -sg " + params.grid_space + " "+freqs
            }
        }
        if ( params.use_precomputed_afs && params.use_recomb_map == "none" ){
            if ( params.grid_points > 0 ){
                args = " -l "+ params.grid_points + " "+ freqs + " "+ afs
            }
            else{
                args = " -lg " + params.grid_space + " "+ freqs + " "+ afs
            }
        }
        if ( params.use_precomputed_afs && params.use_recomb_map != "none" ){
            if ( params.grid_points > 0 ){
                args = " -lr "+ params.grid_points + " "+ freqs + " "+ afs + " "+ recomb
            }
            else{
                args = " -lrg " + params.grid_space + " "+ freqs + " "+ afs + " "+ recomb
            }
        }
        
        """
            SweepFinder2 ${args} ${out_prefix}.out

        """ 
}
