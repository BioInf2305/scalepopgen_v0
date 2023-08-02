process CALC_PAIRWISE_FST{

    tag { "ld_filtering_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.2"
    publishDir("${params.outDir}/plink/fst_summary/", mode:"copy")

    input:
        path(bed)
        path(m_pop_sc_col)
        

    output:
        path("*.log")
        //path("*.intree")
        //path("*.nj.tree")
        path("*.fst.summary")

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = bed[0].baseName
        def max_chrom = params.max_chrom
        def opt_arg = ""
        opt_arg = opt_arg + " --chr-set "+ max_chrom
        
	if( params.allow_extra_chrom ){
                
            opt_arg = opt_arg + " --allow-extra-chr "

            }

        opt_arg = opt_arg + " --within "+new_prefix+".cluster --fst CATPHENO method=wc --out "+new_prefix

	
        """

        awk '{print \$1,\$2,\$1}' ${new_prefix}.fam > ${new_prefix}.cluster

        plink2 --bfile ${new_prefix} ${opt_arg}

        cp .command.log ${new_prefix}.log


        """ 

}
