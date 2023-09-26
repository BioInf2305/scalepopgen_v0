process CONVERT_BED_TO_VCF{

    tag { "convert_plink_bed_to_vcf" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/plink/bed_to_vcf/", mode:"copy")

    input:
        path(bed)

    output:
        path("${prefix}.vcf"), emit:vcf
        path("sample_family.map"), emit: sample_map

    when:
     task.ext.when == null || task.ext.when

    script:
        prefix = bed[0].baseName
        def opt_args = ""
        def fasta = params.fasta
        def f_chrom_len = params.f_chrom_len
        opt_args = opt_args + " --chr-set "+ params.max_chrom+ " --threads "+task.cpus
	if( params.allow_extra_chrom ){
                
            opt_args = opt_args + " --allow-extra-chr "

            }

        if( params.fasta != "none"){
            opt_args = opt_args + " --ref-from-fa --fa "+fasta
        }
        
        opt_args = opt_args + " --recode vcf --out plink"
        
        
        """
	plink2 --bfile ${prefix} ${opt_args}

        awk '{print \$1"_"\$2,\$1}' ${prefix}.fam > sample_family.map

        if [[ "$fasta" == "none" ]]
            then
            awk 'NR==FNR{chrm_len[\$1]=\$2;next}{if(\$0~/^##contig/){match(\$0,/(##contig=<ID=)([^>]+)(>)/,a);print a[1]a[2]",length="chrm_len[a[2]]a[3];next}else{print}}' ${f_chrom_len} plink.vcf > ${prefix}.vcf
        else
            mv plink.vcf ${prefix}.vcf
        fi

        """ 
}
