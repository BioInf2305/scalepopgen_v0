process CALC_INDIV_SUMMARY{
    tag "calculating_indiv_summary" 
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/reportBed", pattern:"${chrom}.indiv.summary",mode:"copy")

    input:
        tuple val(chrom), file(plink_files)

    output:
        path("${chrom}.indiv.summary"), emit: indivSummaryReport

 
    when:
     task.ext.when == null || task.ext.when

    script:
        
        def max_chrm = params.max_chrom

		"""
        
        plink --bfile ${chrom} --chr-set ${max_chrm} --recode --out ${chrom}

        awk '{familyId[\$1];next}END{for(id in familyId){print id}}' ${chrom}.fam > fam.id

        python3 $baseDir/bin/calcBasicStatsFromPed.py -p ${chrom}.ped -b ${chrom}.bim -P fam.id -o ${chrom}

        """

}
