process INDEX_VCF{

    tag { "index_vcf_${chrom}" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
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
