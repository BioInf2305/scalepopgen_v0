process PHASING_GENOTYPE_BEAGLE {

   tag { "phasing_${chrom}" }
   label "eightCpus"
   conda "${baseDir}/environment.yml"
   container "popgen48/scalepopgen:0.1.1"
   publishDir("${params.outDir}/selection/phasing/beagle/", mode:"copy")

   input:        
     tuple val(chrom), path(vcfIn), path(pvcf)

   output:        
     tuple val(chrom), file("*.phased.vcf.gz"), emit: phased_vcf
     path("*.log")

   script:     
        args = ""
        def mem_per_thread = task.memory.toMega()-300
        if( params.ref_vcf != "none"){
                args = args +" ref="+pvcf
            }
        if( params.cm_map != "none"){
                args = args+" map="+params.cm_map
            }
       args = args +" burnin="+params.burnin_val+" iterations="+params.iterations_val+" impute="+params.impute_status+" ne="+params.ne_val


   """

    beagle "-Xmx${mem_per_thread}m" ${args} gt=${vcfIn} out=${chrom}.phased nthreads=${task.cpus}


   """
}
