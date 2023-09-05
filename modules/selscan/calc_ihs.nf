process CALC_iHS{

    tag { "calculating_iHS_${chrom}" }
    label "fourCpus"
    container "maulik23/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/phased/single_pop/iHS/results/", mode:"copy")

    input:
        tuple val(chrom), path(f_vcf), path(f_map), path(anc)

    output:
        path ("*.ihs.out"), emit: iHS_out

    script:
        
        prefix     = f_vcf.baseName
        f_prefix   = anc==[] ? prefix + "_no_anc" : prefix + "_anc"
        def args = ""

        if( params.ihs_args != "none" ){
                args = args + " "+ params.ihs_args
        }

        if(anc == [] ){

        """

        selscan --ihs ${args} --vcf ${f_vcf} --map ${f_map} --out ${f_prefix} --threads ${task.cpus}

        """ 
        }
        
        else{

        """

        selscan --ihs ${args} --vcf ${f_vcf} --map ${f_map} --out ${prefix} --threads ${task.cpus}

        awk 'NR==FNR{a[\$2]=\$3;next}{if(a[\$2]==0){iHS=log(\$4/\$5)/log(10)}if(a[\$2]!=0){iHS=log(\$5/\$4)/log(10)}print \$1,\$2,\$3,\$4,\$5,iHS}' ${anc} ${prefix}.ihs.out > ${f_prefix}.ihs.out


        """

        }
}
