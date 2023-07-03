process COMPUTE_EMPIRICAL_AFS{

    tag { "sweepfinder_input_${pop}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/selection/file_preparation/clr/", mode:"copy")

    input:
        tuple val( pop ), path( freqs )

    output:
        tuple val(pop), path ( "*.afs" ), emit: pop_afs

    script:
        
        """
                        
        cat ${freqs} > ${pop}_combined.freq

        SweepFinder2 -f ${pop}_combined.freq ${pop}.afs

        """ 
}
