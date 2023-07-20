process EXTRACT_UNRELATED_SAMPLE_LIST{

    tag { "calc_missing_${prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.2"
    publishDir("${params.outDir}/plink/indi_filtered/", mode:"copy")

    input:
        file(f_bed)

    output:
        path("*miss"), emit: missing_indi_report
        path("${prefix}_indi_kept*"), emit: missingness_filt_bed
        path("indi_kept.txt"), emit: keep_indi_list
        path("indi_kept.map"), emit: keep_indi_map
        path("*.log" ), emit: log_file
        path("*king*")

    when:
        task.ext.when == null || task.ext.when

    script:
        prefix = f_bed[0].baseName
        def max_chrom = params.max_chrom
        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ max_chrom
        if ( params.king_cutoff >= 0 ){
        
            opt_args = opt_args + " --king-cutoff " + params.king_cutoff 
        }

        if ( params.mind >= 0 ){        
            opt_args = opt_args + " --mind "+ params.mind
        }

        if ( params.allow_extra_chrom ){        
            opt_args = opt_args + " --allow-extra-chr "
        }
        opt_args = opt_args + " --make-bed --missing --out " + prefix +"_indi_kept"

        
        
        """
	
        plink2 --bfile ${prefix} ${opt_args}
            
        awk '{print \$2}' ${prefix}_indi_kept.fam > indi_kept.txt

        awk '{print \$2,\$1}' ${prefix}_indi_kept.fam > indi_kept.map


        """ 
}
