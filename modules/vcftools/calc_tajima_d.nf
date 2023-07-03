process CALC_TAJIMA_D{

    tag { "calculating_tajima_d" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/unphased_data/tajima_d/${prefix}/", mode:"copy")

    input:
        tuple val(prefix), path(vcf), path(sample_id)

    output:
        tuple val(pop), path ("${pop}_${prefix}_${window_size}*"), emit: tajimad_out

    script:
        
        
        pop = sample_id.baseName

        window_size = params.tajimasd_window_size

        """

        vcftools --gzvcf ${vcf} --keep ${sample_id} --TajimaD ${window_size} --out ${pop}_${prefix}_${window_size}


        """ 
}
