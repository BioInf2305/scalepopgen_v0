def print_help() {
    log.info"""
    Usage: 
    nextflow run scalepopgen.nf --input ../example_plink/*.{bed,bim,fam} --outDir ../example_out_bed/ --treemix true
    nextflow run scalepopgen.nf --input ../example_vcf/chr_vcf_idx.csv --sample_map ../example_vcf/sample_pop.map --outDir ../example_out_vcf/ --treemix true
    
    --treemix [bool]         whether or not to run treemix analyis. Default = true

    --n_bootstrap [Int]      number of bootstrapping to run for treemix analyis (without migration edge). Default = 10

    --upper_limit [Int]      upper limit of random integer to set for different bootstrapping. Default = 30000

    --starting_m_value [Int] number of migration edges to begin with. Default = 1

    --ending_m_value [Int]   number of migration edges to end with. Default = 10

    --n_iter [Int]           number of iterations to be carried out with each value of "m". Default = 3

    --k_snps [Int]           description of "k_snps" --> number of block of snps in treemix analysis. Default = 500

    """
}

workflow PRINT_TREEMIX_OPTIONS{
        print_help( )
}
