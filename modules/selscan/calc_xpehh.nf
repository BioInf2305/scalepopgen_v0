process CALC_XPEHH{

    tag { "calculating_xpehh_${chrom}" }
    label "fourCpus"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/selscan/xpehh/${chrom}/", mode:"copy")

    input:
        tuple val(chrom), path(t_vcf), path(r_vcf), path(r_map)

    output:
        tuple val(prefix), path ("*.out"), emit: t_pop_xpehhout

    script:
        
        prefix     = t_vcf.getSimpleName().split("__")[1] + "_"+r_vcf.getSimpleName().split("__")[1]
        out_prefix = chrom+"__"+prefix
        
        def args = ""

        if( params.xpehh_args != "none" ){
                args = args + " "+ params.xpehh_args
        }


        """


        selscan --xpehh ${args} --vcf ${t_vcf} --vcf-ref ${r_vcf} --map ${r_map} --out ${out_prefix} --threads ${task.cpus}


        """ 
        
}
