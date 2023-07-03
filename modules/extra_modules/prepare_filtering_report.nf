process PREPARE_FILTERING_REPORT{
    tag "preparing_filtering_report" 
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/finalPlink", pattern:"${chrom}_filtered.{bed,bim,fam}",mode:"copy")

    input:
        tuple val(chrom), file(plink_files)
	tuple val(filtChrom), file(filtered_plink_files)
	path(filteredLog)

    output:
        tuple val("${chrom}_filtered"), path("${chrom}_filtered.{bed,bim,fam}", emit: filteredBed
	path("${chrom}_filtered.log"), emit: filteredLog
 
    when:
     task.ext.when == null || task.ext.when

    script:
	def skip_filterPlink = params.filterPlink
	def skip_rmRelatedIndiv = params.rmRelatedIndiv
	def relatednessMeasure = params.relatednessMeasure
	def relatednessCoeff = params.relatednessCoeff
	def nRuns            = params.nRuns
	def removeIndiv      = params.removeIndiv
	def removeSnps       = params.removeSnps
	def input            = params.input
        def geno = params.geno
        def mind = params.mind
        def maf  = params.maf
        def max_chrom = params.max_chrom
        
	"""
	python3 ${bin}/
	
	plink --bfile ${chrom} --out ${chrom}_filtered --chr-set ${max_chrm} --mind ${mind_filtering} --geno ${geno_filtering} --maf ${maf_filtering} --make-bed


	""" 
}
