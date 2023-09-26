process BGZIP_VCF{

    tag { "bgzip_vcf_${chrom}" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/tabix/", mode:"copy")

    input:
        tuple val(chrom), path(vcf)

    output:
        tuple val(chrom), path ("*.gz"), emit: chrom_gzvcf
        
    
    script:

        """
        
        awk '{if(NR==1){gsub("v4.3","v4.2",\$0);print;next}else;if(\$0!~/chrSet/){print}}' ${vcf} > plink.vcf
        
        bgzip plink.vcf


        """ 
}
