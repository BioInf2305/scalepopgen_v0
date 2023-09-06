process CALC_XPEHH{

    tag { "calculating_xpehh_${chrom}" }
    label "fourCpus"
    container "maulik23/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/selscan/xp-ehh/", mode:"copy")

    input:
        tuple val(chrom), path(t_vcf), path(r_vcf), path(r_map)

    output:
        path ("*.out"), emit: xpehh_out

    script:
        
        prefix     = t_vcf.baseName + r_vcf.baseName
        
        def args = ""

        if( params.xpehh_args != "none" ){
                args = args + " "+ params.xpehh_args
        }


        """


        selscan --xpehh ${args} --vcf ${t_vcf} --vcf-ref ${r_vcf} --map ${r_map} --out ${prefix} --threads ${task.cpus}


        """ 
        
}
