///workflow to check input for at least three different input files///
///vcfsheet, mapsheet, outgroupsheet

workflow CHECK_INPUT{

    take:
        csvsheet

    main:
        Channel
            .fromPath(csvsheet)
            .splitCsv(sep:",")
            .map{ chrom, vcf, idx -> if(!file(vcf).exists() || !file(idx).exists()){ exit 1, "ERROR: Please check input vcfsheet, either vcf file or its index does not exit \
                -> ${vcf}" }else{tuple(chrom, file(vcf), file(idx))} }
            .set{ chrom_vcf_idx }
       
        if( params.outgroup == "none" && params.anc_files == "create"){
                println("anc_files parameter is set to create but no outgroup is provided")
                exit 1
        }

    emit:
        chrom_vcf_idx = chrom_vcf_idx
}
