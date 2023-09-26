process SPLIT_VCF_BY_CHROM{

    tag { "splitting_by_chrom" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/vcftools/split_chrom_wise/", mode:"copy")
    conda "${baseDir}/environment.yml"

    input:
        path(vcf_in)

    output:
        path ("*.split.vcf.{gz,gz.tbi}"), emit: splitted_vcfs

    script:
        
        """
        awk '{if(\$0~/#/){if(\$0~/#contig/){match(\$0,/(##contig=<ID=)([^,>]+)(.*)/,a);print a[2]>"chrom.id.txt";next}else;next}else;exit 0}' ${vcf_in}

        awk '{if(NR==1){gsub("v4.3","v4.2",\$0);print;next}else;if(\$0!~/chrSet/){print}}' ${vcf_in} > plink.vcf

        while read chrom;do vcftools --vcf plink.vcf --chr \${chrom} --recode --stdout|bgzip -c > \${chrom}.split.vcf.gz;done<chrom.id.txt

        while read chrom;do tabix \${chrom}.split.vcf.gz;done<"chrom.id.txt"

        """ 
}
