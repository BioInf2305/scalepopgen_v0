process PREPARE_SWEEPFINDER_INPUT{

    tag { "sweepfinder_input_${chrom}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/selection/file_preparation/clr/", mode:"copy")

    input:
        tuple val( chrom ), path( vcf ), path( pop_id ), path(anc)

    output:
        tuple val(pop), path ( "${chrom}*.freq" ), emit: pop_freq
        tuple val(pop), path ( "${chrom}*.recomb" ), emit: pop_recomb

    script:
        pop = pop_id.baseName
        def args = ""
        if( params.anc_files != "none" ){
            args = args + "-a "+ anc
        }
        args = args + " -r"
        
        """
                        
        awk -v p=${pop} '{print \$1,p}' ${pop_id} > ${pop}__${chrom}__sample.map

        python ${baseDir}/bin/vcf_to_sweepfinder2_input.py -V ${vcf} -M ${pop}__${chrom}__sample.map -o ${chrom} ${args}


        """ 
}
