process APPLY_LD_FILTERS{

    tag { "ld_filtering_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/plink/ld_filtering/", mode:"copy")

    input:
        file(bed)

    output:
        path("${new_prefix}_ld_filtered.{bed,bim,fam}"), emit: ld_filt_bed
        path("*.log")
        path("*prune*")

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = bed[0].getSimpleName()
        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ params.max_chrom+ " --threads "+task.cpus

        
	if( params.allow_extra_chrom ){
                
            opt_args = opt_args + " --allow-extra-chr "

            }

        opt_args1 = opt_args + " --indep-pairwise "+params.ld_window_size+" "+params.ld_step_size+" "+params.r2_value
        opt_args2 = opt_args + " --extract plink2.prune.in --make-bed --out "+new_prefix+"_ld_filtered"

	
        """

        plink2 --bfile ${new_prefix} ${opt_args1}

        plink2 --bfile ${new_prefix} ${opt_args2}

        """ 

}
