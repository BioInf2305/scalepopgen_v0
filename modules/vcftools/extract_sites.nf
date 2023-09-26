process EXTRACT_SITES{

    tag { "extract_sites_${chrom}" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/ancestral_alleles_determination/est-sfs/", mode:"copy")

    input:
        tuple val(chrom), path(vcf), path(idx), path(sample_map), path(anc_file)

    output:
        tuple val(chrom), file("${chrom}_pos_with_anc_alleles.vcf.{gz,gz.tbi}"), emit:chrom_ancvcfpos_idx
        path("*.log")
    
    script:
    
        """

        awk '{print \$1"\t"\$2}' ${anc_file} > ${chrom}_pos_with_anc_alleles.txt
        
        vcftools --gzvcf ${vcf} --positions ${chrom}_pos_with_anc_alleles.txt --recode --stdout |bgzip -c > ${chrom}_pos_with_anc_alleles.vcf.gz

        cp .command.log ${chrom}_pos_with_anc_alleles.log

        tabix -p vcf ${chrom}_pos_with_anc_alleles.vcf.gz


        """ 
}
