process CONCAT_VCF{

    tag { "concate_vcf" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    //publishDir("${params.outDir}/selection/unphased_data/input", mode:"copy")

    input:
        path(vcf)

    output:
        tuple val("all_chrom_concatenated"), path ("all_chrm_concatenated.vcf.gz"), emit: concatenatedvcf

    script:
        

        """
        vcf-concat $vcf|bgzip -c > all_chrm_concatenated.vcf.gz

        """ 
}
