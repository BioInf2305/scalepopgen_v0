#!/usr/bin/env nextflow

process beaglePhasing {
   publishDir(params.OUTPUT4, pattern: '*.phased.{vcf.gz}')
   tag { "${chrm}_phased" }
   label "fourCpus"

   input:        
    tuple val(chrm),path(vcfFiles)

   output:        
    tuple val(chrm), file ("*.phased.vcf.gz")

   script:     
    def (vcfFile, vcfIndex)=vcfFiles
   """

java -Xmx30g -jar ~/software/populationGenomics/beagle_5.1/beagle.jar gt=${vcfFile} out=${chrm}.phased nthreads=${task.cpus} window=10 impute=false


   """
}


workflow GENOTOPHASE {
    take:
        filteredVcfs
    main:
        filteredVcfs.view()
        rawVcfTup=beaglePhasing(filteredVcfs)
    emit:
        rawVcfTup
}
