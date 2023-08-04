process CALC_1_MIN_IBS_DIST{

    tag { "1_min_ibs_distance_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.2"
    publishDir("${params.outDir}/plink/1_min_ibs_clustering/", mode:"copy")

    input:
        path(bed)
        path(pop_sc_color)

    output:
        path("*.mdist")
        path("*.mdist.id")
        path("*.html")
        path("*.svg")
        path("polyphyletic_pop_list.txt")
        path("*.ibs.dist")


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

        opt_arg = opt_arg + " --distance square 1-ibs --out "+new_prefix+"_1_min_ibs"

        ibs_nj_yml = params.ibs_nj_yml

	
        """
    
        plink --bfile ${new_prefix} ${opt_arg}

        python ${baseDir}/bin/make_ibs_dist_nj_tree.py -i *.mdist -m *.mdist.id -c ${pop_sc_color} -y ${ibs_nj_yml} -o ${new_prefix}


        """ 

}
