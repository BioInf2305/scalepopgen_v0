process PREPARE_MAP_SELSCAN{

    tag { "preparing_selscan_map_${chrom}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/selection/phased/ihs/input/", mode:"copy")

    input:
        tuple val( chrom ), path( vcf )

    output:
        tuple val( chrom ), path ( "${prefix}.map" ), emit: chrom_selscanmap

    script:

        def cm_to_bp = params.cm_to_bp //defaul is 1000000
        prefix = vcf.baseName
        
        """
                        

         zcat ${vcf}|awk '\$0!~/#/{sum++;print \$1,"locus"sum,\$2/${cm_to_bp},\$2}' > ${prefix}.map


        """ 
}
