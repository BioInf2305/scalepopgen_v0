process REMOVE_INDI{

    tag { "remove_indi_${chrom}" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/vcftools/indi_filtered/", mode:"copy")

    input:
        tuple val(chrom), path(f_vcf)

    output:
        tuple val(chrom), path("${chrom}_filt_samples.vcf.gz"), path("${chrom}_filt_samples.vcf.gz.tbi"), emit:f_chrom_vcf_idx
        path("*.log")
    
    script:
        
            rem_indi = params.rem_indi
                
            """
            awk '{print \$2}' ${rem_indi} > remove_indi_list.txt
            
            vcftools --gzvcf ${f_vcf} --remove remove_indi_list.txt --recode --stdout |sed "s/\\s\\.:/\t.\\/.:/g"|bgzip -c > ${chrom}_filt_samples.vcf.gz
                
            tabix -p vcf ${chrom}_filt_samples.vcf.gz

            cp .command.log ${chrom}_filt_samples.log



            """        
            
}
