process SPLIT_VCF_BY_POP{

    tag { "split_vcf_by_pop_${chrom}" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/selscan/input_files/", mode:"copy")

    input:
        tuple val(chrom), path(vcf), path(sample_map), path(isc)

    output:
        path("*phased.vcf.gz"), emit: pop_phased_vcf
    
    script:
        
    
        """
        awk 'NR==FNR{sample[\$1];next}\$1 in sample{print}' ${isc} ${sample_map} > ${chrom}_keep_selscan.map 

        awk '{print \$1 >>\$2"_id.txt"}' ${chrom}_keep_selscan.map

        for fn in \$(ls *_id.txt);
            do
                vcftools --gzvcf ${vcf} --keep \${fn} --recode --stdout |bgzip -c > ${chrom}__\$(basename \$fn _id.txt)__phased.vcf.gz
            done

        """ 
}
