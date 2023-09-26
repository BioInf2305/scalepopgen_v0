process CONCAT_VCF{

    tag { "concate_vcf" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    //publishDir("${params.outDir}/selection/unphased_data/input", mode:"copy")

    input:
        path(vcf)

    output:
        tuple val("${file_prefix}"), path ("${file_prefix}.vcf.gz"), emit: concatenatedvcf

    script:
        file_prefix = params.concate_vcf_prefix

        """
        vcf-concat $vcf|bgzip -c > ${file_prefix}.vcf.gz

        """ 
}
