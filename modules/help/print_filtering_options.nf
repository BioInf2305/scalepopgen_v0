def print_help() {
    log.info"""
Usage:    
    nextflow run scalepopgen.nf --input ../example_plink/*.{bed,bim,fam} --outDir ../example_out_bed/ 
    nextflow run scalepopgen.nf --input ../example_vcf/chr_vcf_idx.csv --sample_map ../example_vcf/sample_pop.map --outDir ../example_out_vcf/

//sample-filtering parameters

 --apply_indi_filters [bool] whether or not to perform sample filtering, Note that setting this to false overrides all parameters associated with sample filtering. In other words, sample filtering will not be carried out irrespective of arguments set for --king_cutoff, --rem_indi or --mind. Default: true

 --king_cutoff [bool] King relationship coefficient value above which the pairs of individuals are considered to be related and based on this pairwise values plink2 will select the list of unrelated samples, Default: 0.08.

 --rem_indi [file] Path to the file containing the list of custom individuals to be removed from all analyses. Note that in case of vcf file, this file should consists of only one column of individual id, whereas in case of plink generated binary files, this file consists of two columns, first column corresponding population id and second column, individual id. Setting this to "none" will disable this flag. Default:"none"
 
  --mind [float] samples with missing genotypes greater than this will be removed. Setting this to negative value will disable this parameter. Default: 0.10. 

// sites-filtering parameters
    
 --apply_snp_filters [bool] setting this to false overrides all other sites-filtering parameters. In other words, sites-filtering will not be carried out irrespective of arguments set for --remove_snps,  --maf, --min_meanDP, --max_meanDP, --hwe, --max_missing, --minQ. Note that depending on the input files, these parameters will be applied. For example, depth-related information and SNP quality information are not available (of course) for plink bed files and therefore, these parameters will be ignored in that case. However, parameters like max_missing, hwe and maf are applied to vcf as well as to plink-bed files. Default: true

--remove_snps [file] path to the file containing SNP ids to be removed in case of plink-bed files, whereas in case of vcf file, this file should contain two columns: first col, chromsome_id and second col, positions to be removed. Setting this to "none" will disable this flag. Default: "none"

--maf [float] sites with minor allele frequencies less than this will be filtered, if set to any value < 0, this filter will be ignored. Default: 0.01

--min_meanDP [float] sites with average depth (across the samples) less than this will be filtered out, set to any value < 0 --> it will be ignored. Default: -9

--max_meanDP [float] sites with average depth (across the samples) greater than this will be filtered out , set to any value < 0 --> it will be ignored. Default: -9

--hwe [float] sites with p-value (hwe) less than this will be filtered out, set to any value < 0 --> it will be ignored. Default: -9

--max_missing [float] sites with genotypes missing more than this proportion of samples will be filtered out, set to any value < 0 --> it will be ignored. Default: -9

--minQ [Int] sites with SNP quality less than this will be filtered out, set to any value < 0 --> it will be ignored. Default:-9
    
    """.stripIndent()
}

workflow PRINT_FILTERING_OPTIONS{
        print_help( )
    }
