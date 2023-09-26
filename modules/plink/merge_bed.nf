process MERGE_BED{

    tag { "merging_bed_${new_prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir( "${params.outDir}/plink/merged_bed/" , mode:"copy")

    input:
        file(bed)
        file(m_sample)

    output:
        path("${new_prefix}.{bed,bim,fam}"), emit: merged_bed
        path("*.log"), emit: merged_bed_log

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = params.concate_vcf_prefix
        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ params.max_chrom+ " --threads "+task.cpus
	if( params.allow_extra_chrom ){
                
            opt_args = opt_args + " --allow-extra-chr "

            }
        
        """

        ls *.fam|sed 's/\\.fam//g' > prefix_list.txt

	plink2 ${opt_args} --pmerge-list prefix_list.txt bfile --make-bed --out ${new_prefix}

        awk 'NR==FNR{pop[\$1]=\$2;next}{\$1=pop[\$2];print}' ${m_sample} ${new_prefix}.fam > ${new_prefix}.1.fam

        rm ${new_prefix}.fam

        mv ${new_prefix}.1.fam ${new_prefix}.fam

        """ 
}
