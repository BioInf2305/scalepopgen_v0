process EXTRACT_UNRELATED_SAMPLE_LIST{

    tag { "filter_indi_${prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.2"
    publishDir("${params.outDir}/plink/indi_filtered/", mode:"copy")

    input:
        tuple val(prefix), path(vcf)

    output:
        path("*miss"), emit: missing_indi_report optional true
        path("indi_kept.txt"), emit: keep_indi_list
        path("*.log" ), emit: log_file
        path("*king*"), emit: king_out optional true
        path("${new_prefix}_rem_indi.{bed,bim,fam}"), emit: indi_filt_bed

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = vcf[0].baseName
        is_vcf = vcf[0].getExtension() == "gz" ? true:false
        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ params.max_chrom
        if ( params.king_cutoff >= 0 ){
        
            opt_args = opt_args + " --king-cutoff " + params.king_cutoff 

            if( is_vcf ){
                opt_args = opt_args + " --vcf "+vcf
            }
            if( !is_vcf ){
                opt_args = opt_args + " --bfile "+new_prefix
            }

            if ( params.mind >= 0 ){        
                opt_args = opt_args + " --mind "+ params.mind
            }

            if ( params.allow_extra_chrom ){        
                opt_args = opt_args + " --allow-extra-chr "
            }
            if ( params.rem_indi != "none"){
                opt_args = opt_args + " --remove "+ params.rem_indi
            }
            opt_args = opt_args + " --make-bed --out "+new_prefix+"_rem_indi"
        
        
            """
            
            plink2 ${opt_args}

            mv ${new_prefix}_rem_indi.king.cutoff.in.id indi_kept.txt
                

            """ 
        }

        else{
            if( is_vcf ){
                opt_args = opt_args + " --vcf "+vcf
            }
            if( !is_vcf ){
                opt_args = opt_args + " --bfile "+new_prefix
            }
            if ( params.rem_indi != "none"){
                opt_args = opt_args + " --remove "+ params.rem_indi
            }
        
            if ( params.mind >= 0 ){        
                opt_args = opt_args + " --mind "+ params.mind
            }

            if ( params.allow_extra_chrom ){        
                opt_args = opt_args + " --allow-extra-chr "
            }
            
            opt_args = opt_args + " --make-bed --missing --out "+new_prefix+"_rem_indi"
        
            """
            
            plink2 ${opt_args}

            awk '{print \$2}' ${new_prefix}_rem_indi.fam > indi_kept.txt
                

            """ 

        }
}
