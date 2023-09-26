process CALC_PI{

    tag { "calculating_pi" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/vcftools/pi_values/${prefix}/", mode:"copy")

    input:
        tuple val(prefix), path(vcf), path(sample_id)

    output:
        tuple val(pop), path ("${pop}_${prefix}_*"), emit: pi_out

    script:

        def args = ""
        pop = sample_id.getSimpleName()
        out_prefix = pop+"_"+prefix
        args = args +" --keep "+sample_id 
        if( params.pi_window_size > 0 ){
            args = args + " --window-pi "+ params.pi_window_size
            out_prefix = out_prefix+"_"+params.pi_window_size
            }
        if( params.pi_step_size > 0 ){
                args = args + " --window-pi-step "+ params.pi_step_size
                out_prefix = out_prefix+"_"+params.pi_step_size
            }
        if ( params.pi_window_size <= 0 && params.pi_step_size <= 0 ){
                args = args + " --site-pi "
                out_prefix = out_prefix + "_sites_pi"
            }
        
        args=args+" --out "+out_prefix

        """
        vcftools --gzvcf ${vcf} ${args}

        """ 
}
