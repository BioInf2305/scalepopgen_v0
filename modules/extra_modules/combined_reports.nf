process COMBINED_REPORTS{
    tag "combining_reports" 
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/reportBed", pattern:"pop.summary",mode:"copy")

    input:
        file(freq_out)
        file(het_out)

    output:
        path("pop.summary")

 
    when:
     task.ext.when == null || task.ext.when

    script:
        

		"""
    
        awk 'NR==FNR{maf[\$1] = \$3;sampleCount[\$1]=\$2;next}{print \$1, sampleCount[\$1], maf[\$1], \$2, \$3}' ${freq_out} ${het_out} > pop.summary

        """

}
