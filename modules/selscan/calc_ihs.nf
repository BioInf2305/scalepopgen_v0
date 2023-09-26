process CALC_iHS{

    tag { "calculating_iHS_${chrom}" }
    label "fourCpus"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/selscan/ihs/${chrom}", mode:"copy")

    input:
        tuple val(chrom), path(f_vcf), path(f_map)

    output:
        tuple val(pop_id), path ("*.ihs.out"), emit: t_pop_ihsout

    script:
        
        prefix     = f_vcf.getSimpleName()
        chrom = prefix.split("__")[0]
        pop_id = prefix.split("__")[1]
        def args = ""

        if( params.ihs_args != "none" ){
                args = args + " "+ params.ihs_args
        }


        """

        selscan --ihs ${args} --vcf ${f_vcf} --map ${f_map} --out ${prefix} --threads ${task.cpus}

        """ 
        
}
