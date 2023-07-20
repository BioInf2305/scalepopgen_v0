process KEEP_INDI{

    tag { "keep_indi_${chrom}" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.2"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/vcftools/indi_filtered/", mode:"copy")

    input:
        tuple val(chrom), file(f_vcf), file(idx), file(f_map), file(unrel_id)

    output:
        tuple val(chrom), file("${chrom}_filt_samples.vcf.gz"), file("${chrom}_filt_samples.vcf.gz.tbi"), emit:f_chrom_vcf_idx
        path("final_kept_indi_list.txt"), emit:final_keep_list
        path("*.log")
    
    script:

        def rem_indi = params.rem_indi

        if ( (params.mind >= 0 || params.king_cutoff >= 0 ) && rem_indi != "none" ){

        """

        awk 'NR==FNR{sample_id[\$2];next}!(\$1 in sample_id){print \$1} ${rem_indi} ${unrel_id} > final_kept_indi_list.txt
        
        vcftools --gzvcf ${f_vcf} --keep filtered_indi_list.txt --recode --stdout |sed "s/\\s\\.:/\\t.\\/.:/g"|bgzip -c > ${chrom}_filt_samples.vcf.gz

        tabix -p vcf ${chrom}_filt_samples.vcf.gz

        cp .command.log ${chrom}_filt_samples.log


        """ 

        }
        
        else{
            
            if ( (params.mind >= 0 || params.king_cutoff >= 0 ) && rem_indi == "none" ){
                
            """

            vcftools --gzvcf ${f_vcf} --keep ${unrel_id} --recode --stdout |sed "s/\\s\\.:/\t.\\/.:/g"|bgzip -c > ${chrom}_filt_samples.vcf.gz
                
            tabix -p vcf ${chrom}_filt_samples.vcf.gz

            cp .command.log ${chrom}_filt_samples.log

            cat ${unrel_id} > final_kept_indi_list.txt


            """        
            
            }

            else{
            
            """

            awk 'NR==FNR{sample[\$1];next}!(\$1 in a){print \$1}' ${rem_indi} ${f_map} > final_kept_indi_list.txt

            vcftools --gzvcf ${f_vcf} --keep final_kept_indi_list.txt --recode --stdout |sed "s/\\s\\.:/\t.\\/.:/g"|bgzip -c > ${chrom}_filt_samples.vcf.gz

            tabix -p vcf ${chrom}_filt_samples.vcf.gz

            cp .command.log ${chrom}_filt_samples.log

            """            


            }
        
        }
}
