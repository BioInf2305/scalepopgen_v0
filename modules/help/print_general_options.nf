def print_help() {
    log.info"""
    Usage:
    // Only general options are printed

    -- input [file]           In case of vcf, the input should be ".csv" with first column as chromosome id, second column as path to the vcf file                              and third column, path to its respective index. In case of plink, the input should be directly the path to the 
                              bed file, "*.{bim,bed,fam}"
    outDir                    = "${baseDir}/../zebu_out/" // Path to the directory, where all the outputs will be stored. If the directory is not present, it will be created
    sample_map                = "${baseDir}/input_files/sample_pop.map" //Path to the sample map file, format: first column, sample id and the second column, population id
    geo_plot_yml              = "none" //Path to the yaml file containing parameters for plotting the samples on map
    tile_yml                  = "${baseDir}/params/tiles_info.yml" // Path to the yaml file containing the info about world map to be used as map
    fasta                     = "${baseDir}/../input_files/genome.fa" // If the inputs are plink bed files, fasta file is needed to set the reference allele in the converted vcf files. If not provided, the major allelel will be set as the reference allele
    chrm_map                  = "none"
    allow_extra_chrom         = true // Set to true, if the file contains chromosome name in the form of string
    max_chrom                 = 29 // Maximum chromosomes to be allowed
    outgroup                  = "none" // Specifiy pop id to be used as an outgroup in all the analysis
    cm_to_bp                   = 1000000 // Specify how many bp should be considered as 1 cm. To be used only, when recombination map is not provided
    
    1). To see the options related to filtering of samples and sites, type "nextflow run scalepopgen.nf --help --filtering"
    2). To see the options related to pca, admixture, type "nextflow run scalepopgen.nf --help --popstruct
    3). To see the options related to treemix, type "nextflow run scalepopgen.nf --help --phylogeny"

    """.stripIndent()
}

workflow PRINT_GENERAL_OPTIONS{
        print_help( )
    }
