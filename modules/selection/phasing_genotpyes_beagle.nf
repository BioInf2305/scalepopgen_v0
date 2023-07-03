process PHASING_GENOTYPE_BEAGLE {

   tag { "phasing_${chrom}" }
   label "fourCpus"
   conda "${baseDir}/environment.yml"
   container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/phasing/", mode:"copy")

   input:        
     tuple val(chrom), path(vcfIn)

   output:        
     tuple val(chrom), file("*.phased.vcf.gz"), emit: phased_vcf

   script:     
        args = ""
        def mem_per_thread = task.memory.toMega()-300
        if( params.ref_vcf != "none"){
                args = args +" ref="+params.ref_vcf
            }
        if( params.cm_map != "none"){
                args = args+" map="+params.cm_map
            }
       args = args +" burnin="+params.burnin_val+" iterations="+params.iterations_val+" impute="+params.impute_status+" ne="+params.ne_val


   """

    beagle "-Xmx${mem_per_thread}m" ${args} gt=${vcfIn} out=${chrom}.phased nthreads=${task.cpus}

   """
}
