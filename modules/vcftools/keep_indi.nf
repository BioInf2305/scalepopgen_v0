process KEEP_INDI{

    tag { "keep_indi_${chrom}" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.2"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/vcftools/indi_filtered/", mode:"copy")

    input:
        tuple val(chrom), file(f_vcf), file(indi_list)

    output:
        tuple val(chrom), file("${chrom}_filt_samples.vcf.gz"), emit:filt_chrom_vcf
        path("*.log")
    
    script:
    
        """
        
        vcftools --gzvcf ${f_vcf} --keep ${indi_list} --recode --stdout |bgzip -c > ${chrom}_filt_samples.vcf.gz

        cp .command.log ${chrom}_filt_samples.log


        """ 
}
