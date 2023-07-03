process CALC_XPEHH{

    tag { "calculating_xpehh_${chrom}" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/phased/multi_pop/xp-ehh/results/", mode:"copy")

    input:
        tuple val(chrom), path(t_vcf), path(r_vcf), path(r_map)

    output:
        path ("*.out"), emit: xpehh_out

    script:
        
        prefix     = t_vcf.baseName + r_vcf.baseName
        
        def args = ""

        if( params.xpehh_params != "none" ){
                args = args + " "+ params.xpehh_params
        }


        """


        selscan --xpehh ${args} --vcf ${t_vcf} --vcf-ref ${r_vcf} --map ${r_map} --out ${prefix}


        """ 
        
}
