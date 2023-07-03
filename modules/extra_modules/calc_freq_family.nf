process CALC_FREQ_FAMILY{
    tag "calculating_freq_family" 
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/reportBed", pattern:"${chrom}.{frq.strat, family.mafSummary.frq}",mode:"copy")

    input:
        tuple val(chrom), file(plink_files)

    output:
        path("${chrom}.frq.strat"), emit: plinkReport
        path("${chrom}.family.mafSummary.frq"), emit: mafSummary

 
    when:
     task.ext.when == null || task.ext.when

    script:
        
        def max_chrom = params.max_chrom

        if(!params.allow_extra_chrom){

		"""
        
        plink --bfile ${chrom} --chr-set ${max_chrom} --freq --family --out ${chrom}

        awk '{familyId[\$1]++;next}END{for(id in familyId){print id, familyId[id]}}' ${chrom}.fam > fam.id

        while read pop sampleCount; do awk -v id=\$pop -v sc=\${sampleCount} -v maf=0 -v sum=0 '\$3==id{maf+=\$6;sum++}END{print id,sampleCount, maf/sum}' ${chrom}.frq.strat;done<fam.id>${chrom}.family.mafSummary.frq


        """
        }

        else{

		"""
        
        plink --bfile ${chrom} --chr-set ${max_chrom} --freq --family --out ${chrom} --allow-extra-chrm

        awk '{familyId[\$1]++;next}END{for(id in familyId){print id, familyId[id]}}' ${chrom}.fam > fam.id

        while read pop sampleCount; do awk -v id=\$pop -v sc=\${sampleCount} -v maf=0 -v sum=0 '\$3==id{maf+=\$6;sum++}END{print id,sampleCount, maf/sum}' ${chrom}.frq.strat;done< fam.id > ${chrom}.family.mafSummary.frq


        """
        }

}
