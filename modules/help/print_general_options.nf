def print_help() {
    log.info"""
    Usage: 
    nextflow run scalepopgen.nf --input ../example_plink/*.{bed,bim,fam} --outDir ../example_out_bed/ 
    nextflow run scalepopgen.nf --input ../example_vcf/chr_vcf_idx.csv --sample_map ../example_vcf/sample_pop.map --outDir ../example_out_vcf/

    Required arguments:

    --input [file]           In case of vcf, the input should be ".csv" with first column as chromosome id, second column as path to the vcf file and third column, path to its respective index (for example, see: example/input_vcf.csv). In case of plink,  the input should be directly the path to the ".bed" file with its extension, "*.{bim,bed,fam}".Note that there should ONLY be ONE SET OF PLINK binary files in the specified path.

    --sample_map [file]      Path to the sample map file (for example, see: example/sample_pop.map), format: first column as sample id and second column as population id. This is a REQUIRED argument only if the input is ".csv". Note that this file must end with the suffix ".map".

    --outDir [dir]           Path to the directory, where all the outputs will be stored. If the directory is not present, it will be created. 

    Optional arguments:
                           
    --geo_plot_yml [file]     Path to the yaml file containing parameters for plotting the samples on a map (for example, see: example/plot_sample_on_map.yaml). Refer to doc/plot_map.md for description of this yaml file

    --tile_yml [file]         Path to the yaml file containing parameters for the geographical map to be used for plotting (for example, see: example/tiles_info.yaml). Refer to doc/plot_map.md for description of this yaml file

    --fasta [file]            If the inputs are plink binary files, fasta file is needed to set the reference allele in the converted vcf files. If not provided, the major allele will be set as the reference allele for all positions for all analyses

    --chrm_map [file]         If the inputs are plink binary files, map file is needed to set the chromosome id and its respective size in the vcf header (for example, see: plink_example/chrm_size.map). If not provided, the greatest coordinate for each chromosome will be considered its total size.

    --allow_extra_chrom [bool] set this argument to "true" if the chromosome id contains string, default: false

    --max_chrom [int]        maximum chromosomes (including sex chromosomes) to be considered for the analyses. 

    --outgroup [str]         The population id to be used as an outgroup, this will be used in the following analyses:
                             1). treemix --> as a root in ML phylogenetic tree
                             2). Fst-based NJ clustering --> as a root 
                             3). selection analysis --> to determine the ancestral and derived alleles
                             For more details, read the online documentation
                            
    --cm_to_bp [int]        Specify how many bp should be considered as 1 cm. To be used only, when recombination files are not provided, default: 1000000

    For detailed options for each analysis:
        1). To see the options related to filtering of samples and sites, type "nextflow run scalepopgen.nf --help --apply_indi_filters" or "nextflow run scalepopgen --help --apply_snp_filters"
        2). To see the options related to pca, admixture, type "nextflow run scalepopgen.nf --help --popstruct
        3). To see the options related to treemix, type "nextflow run scalepopgen.nf --help --phylogeny"

    """
}

workflow PRINT_GENERAL_OPTIONS{
        print_help( )
    }
