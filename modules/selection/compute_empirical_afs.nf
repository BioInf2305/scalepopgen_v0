process COMPUTE_EMPIRICAL_AFS{

    tag { "sweepfinder_input_${pop}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/selection/sweepfinder2/input_files/", mode:"copy")

    input:
        tuple val( pop ), path( freqs )

    output:
        tuple val(pop), path ( "*.afs" ), emit: pop_afs
        path("*.log")

    script:
        
        """
                        
        cat ${freqs} > ${pop}_combined.freq

        SweepFinder2 -f ${pop}_combined.freq ${pop}.afs

        cp .command.log sweepfinder2_${pop}.log

        """ 
}
