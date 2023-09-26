process KEEP_INDI{

    tag { "keep_indi_${chrom}" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/vcftools/indi_filtered/", mode:"copy")

    input:
        tuple val(chrom), file(f_vcf), file(idx), file(f_map), file(unrel_id)

    output:
        tuple val(chrom), file("${chrom}_filt_samples.vcf.gz"), file("${chrom}_filt_samples.vcf.gz.tbi"), emit:f_chrom_vcf_idx
        path("final_kept_indi_list.txt"), emit:final_keep_list
        path("*.log")
    
    script:


        
                
            """

            vcftools --gzvcf ${f_vcf} --keep ${unrel_id} --recode --stdout |sed "s/\\s\\.:/\t.\\/.:/g"|bgzip -c > ${chrom}_filt_samples.vcf.gz
                
            tabix -p vcf ${chrom}_filt_samples.vcf.gz

            cp .command.log ${chrom}_filt_samples.log

            cat ${unrel_id} > final_kept_indi_list.txt


            """        
            
        
}
