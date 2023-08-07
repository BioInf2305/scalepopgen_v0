process CALC_1_MIN_IBS_DIST{

    tag { "1_min_ibs_distance_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.2"
    publishDir("${params.outDir}/genetic_structure/interactive_plots/1_min_ibs_clustering/", mode:"copy")

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
        path("*.log")


    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = bed[0].getSimpleName()
        def max_chrom = params.max_chrom
        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ max_chrom
        
	if( params.allow_extra_chrom ){
                
            opt_args = opt_args + " --allow-extra-chr "

            }

        opt_args = opt_args + " --distance square 1-ibs --out "+new_prefix+"_1_min_ibs"

        ibs_nj_yml = params.ibs_nj_yml

	
        """
    
        plink --bfile ${new_prefix} ${opt_args}

        python3 ${baseDir}/bin/make_ibs_dist_nj_tree.py -i *.mdist -m *.mdist.id -c ${pop_sc_color} -y ${ibs_nj_yml} -o ${new_prefix}

        cp .command.log calc_1_mins_ibs_dist.log

        """ 

}
