process CONVERT_VCF_TO_BED{

    tag { "converting_vcf_to_bed_${chrom}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"

    input:
        tuple val(chrom), file(f_vcf)

    output:
        path("${chrom}*.{bed,bim,fam}"), emit: bed

    when:
        task.ext.when == null || task.ext.when

    script:
        new_prefix = chrom +"__"+ f_vcf.getSimpleName()
        def opt_args = ""
        opt_args = opt_args + " --chr-set "+ params.max_chrom+" --threads "+task.cpus

	if( params.allow_extra_chrom ){
                
            opt_args = opt_args + " --allow-extra-chr "

            }

        opt_args = opt_args + " --const-fid --make-bed "

        """
	plink2 --vcf ${f_vcf} ${opt_args} --out ${new_prefix}

        #new SNP id was created so that the same positions on multiple chromosome does not break the merge-bed command 

        awk 'BEGIN{OFS="\t"}{\$2=\$1"_"\$4;print}' ${new_prefix}.bim > ${new_prefix}.1.bim

        mv ${new_prefix}.1.bim ${new_prefix}.bim

        """ 
}
