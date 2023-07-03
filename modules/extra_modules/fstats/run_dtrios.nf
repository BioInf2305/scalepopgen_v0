process RUN_DTRIOS{

    tag { "run_dTrios" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/fstats", pattern:"*{BBAA.txt,.vcf}",mode:"copy")

    input:
        tuple val(chrom), file(vcfIn)
        file(idFile)

    output:
        path("*{BBAA.txt,.vcf}")

    when:
	task.ext.when == null || task.ext.when

    script:
        
	def outgroup = params.outgroup
	def jkBlock  = params.jkBlock

        """


	sed -i 's/${outgroup}/Outgroup/g' ${idFile}


	Dsuite Dtrios -o ${chrom} -k ${jkBlock} ${vcfIn} ${idFile}


        """ 

}
