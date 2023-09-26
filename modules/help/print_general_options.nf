def print_help() {
    log.info"""
    Usage: 
    nextflow run scalepopgen.nf --input ../example_plink/*.{bed,bim,fam} --outDir ../example_out_bed/ 
    nextflow run scalepopgen.nf --input ../example_vcf/chr_vcf_idx.csv --sample_map ../example_vcf/sample_pop.map --outDir ../example_out_vcf/

    Required arguments:

    --input [file]           In case of vcf, the input should be ".csv" with first column as chromosome id, second column as path to the vcf file and third column, path to its respective index (for example, see: ./test_files/test_input_vcf.csv). In case of plink,  the input should be directly the path to the ".bed" file with its extension, "*.{bim,bed,fam}".Note that there should ONLY be ONE SET OF PLINK binary files in the specified path.

    --outDir [dir]           Path to the directory, where all the outputs will be stored. If the directory is not present, it will be created. 

    --sample_map [file]      Path to the sample map file (for example, see: ./test_files/sample.map), format: first column as sample id and second column as population id. This is a REQUIRED argument only if the input is ".csv". Note that this file must end with the suffix ".map".


    Optional arguments:
                           
    --geo_plot_yml [file]     Path to the yaml file containing parameters for plotting the samples on a map (for example, see: parameters/plots/plot_sample_on_map.yml). Refer to online documentation for description of this yaml file

    --tile_yml [file]         Path to the yaml file containing parameters for the geographical map to be used for plotting (for example, see: parameters/plots/tiles_info.yaml). Refer to online documentation for description of this yaml file

    --f_chrom_len [file]         If the inputs are plink binary files, map file is needed to set the chromosome id and its respective size in the vcf header (for example, see: test_files/chrm_size.map).

    --f_pop_cord [file]       Path to the file containing population name as first column and its latitude, longitude as second column (for example, see: ./test_files/geo_data.txt)"

    --f_pop_color [file]      Path to the file containing population name as first column and color in hex codes as second column (for example, see:../../test_files/pop_color.txt"). If not provided, random colors will be chosen to represent each population, and this pop-color combination will be kept consistent across the plotting of the results of various analyses. 

    --fasta [file]            If the inputs are plink binary files, fasta file is needed to set the reference allele in the converted vcf files. If not provided, the major allele will be set as the reference allele for all positions for all analyses

    --allow_extra_chrom [bool] set this argument to "true" if the chromosome id contains string, default: false

    --max_chrom [int]        maximum chromosomes to be considered for the analyses. Note that the workflow only consider the autosomes. 

    --outgroup [str]         The population id to be used as an outgroup, this will be used in the following analyses:
                             1). treemix --> as a root in ML phylogenetic tree
                             2). Fst-based NJ clustering --> as a root 
                             3). selection analysis --> to determine the ancestral and derived alleles
                             For more details, read the online documentation
                            
    --cm_to_bp [int]        Specify how many bp should be considered as 1 cm. To be used only, when recombination files are not provided, default: 1000000

    For detailed options for each analysis:
        1). To see the options related to filtering of samples and sites, type "nextflow run scalepopgen.nf --help --indi_snp_filters"
        2). To see the options related to genetic structure analyses, type "nextflow run scalepopgen.nf --help --gen_struct
        3). To see the options related to treemix, type "nextflow run scalepopgen.nf --help --phylogeny"
        4). To see the options related to signatures of selection analysis, type "nextflow run scalepopgen.nf --help --signature_selection"

    """
}

workflow PRINT_GENERAL_OPTIONS{
        print_help( )
    }
