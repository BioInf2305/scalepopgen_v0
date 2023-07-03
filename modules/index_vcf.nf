process INDEX_VCF{

    tag { "index_vcf_${chrom}" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.2"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/tabix/", mode:"copy")

    input:
        tuple val(chrom), path(vcf)

    output:
        tuple val(chrom), path ("*.tbi"), emit: idx_vcf
    
    script:

        """
        
        tabix ${vcf}


        """ 
}
