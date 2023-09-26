process COMBINE_INDIV_SUMMARY{

    tag { "combining_indiv_summary" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/summary_stats/indiv_stats/", mode:"copy")

    input:
        path(indivreports)
        path(depthreports)

    output:
        path("genomewide_sample_stats.tsv")
        
    
    script:

        """
        python3 ${baseDir}/bin/combine_indiv_reports.py ${indivreports}
        
        cat ${depthreports} > concat_chrm_depth_reports.txt

        awk 'BEGIN{OFS="\t"}\$0!~/INDV/{depth_s = \$3*\$2;count_s = \$2;if(!(\$1 in snp_count)){snp_count[\$1]=count_s;depth_count[\$1]=depth_s;next}else{snp_count[\$1]+=count_s;depth_count[\$1]+=depth_s}}END{for(sample in snp_count){print sample, snp_count[sample], depth_count[sample]/snp_count[sample]}}' concat_chrm_depth_reports.txt > sample_depth.tsv

        awk 'BEGIN{OFS="\t"}NR==FNR{sample_depth[\$1]=\$3;next}{if(FNR==1){print \$1,\$2,\$3,\$4,\$5,\$6,\$7,"AVE_DEPTH";next}else;print \$1,\$2,\$3,\$4,\$5,\$6,\$7,sample_depth[\$1]}' sample_depth.tsv genomewide_indiv_report.tsv > genomewide_sample_stats.tsv
        
        """ 

}
