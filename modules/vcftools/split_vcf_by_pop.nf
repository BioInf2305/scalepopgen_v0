process SPLIT_VCF_BY_POP{

    tag { "split_vcf_by_pop_${chrom}" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/inputs/phased/", mode:"copy")

    input:
        tuple val(chrom), file(vcf), file(sample_map)

    output:
        path("*phased.vcf.gz"), emit: pop_phased_vcf
    
    script:
        
    
        """

        awk '{print \$1 >>\$2"_id.txt"}' ${sample_map}

        for fn in \$(ls *_id.txt);
            do
                vcftools --gzvcf ${vcf} --keep \${fn} --recode --stdout |bgzip -c > ${chrom}__\$(basename \$fn _id.txt)_phased.vcf.gz
            done

        """ 
}
