def print_help() {
    log.info"""
    Usage:
    // general parameters

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

    //sample-filtering parameters

    apply_indi_filters        = false // Setting this to false overrides all other sample-filtering parameters
    king_cutoff               = 0.0883 // Indivdual pair with KING relationship coefficient greater than this will be considered related, 0 --> do not estimate the coeff
    rem_indi                  = "none" // Replace this with the file name containing individuals to be removed
    mind                      = 0.1 // Samples with missing genotypes greater than this will be removed

    // sites-filtering parameters
    
    apply_snp_filters         = false // Setting this to false overrides all other sites-filtering parameters 
    remove_snps               = "none" // Replace this with the file name containing the SNPs to be removed
    maf                       = -9 // Sites with minor allele frequencies less than this will be filtered, if set to any value < 0 --> it will be ignored
    min_meanDP                = -9 // Sites with average depth (across the samples) less than this will be filtered out, set to any value < 0 --> it will be ignored
    max_meanDP                = -9 // Sites with average depth (across the samples) greater than this will be filtered out , set to any value < 0 --> it will be ignored
    hwe                       = -9 // Sites with p-value (hwe) less than this will be filtered out, set to any value < 0 --> it will be ignored
    max_missing               = 0.05 // Sites with genotypes missing more than this proportion of samples will be filtered out, set to any value < 0 --> it will be ignored
    minQ                      = 0 // Sites with base quality less than this will be filtered out
    

    //ld filter for PCA and ADMIXTURE analysis

    run_smartpca              = false // Setting this to false, will skip the PCA using smartpca of eigensoft
    run_gds_pca               = false // Setting this to false, will skip the PCA using 
    ld_filt                   = true // Apply LD-based filtering before running PCA and ADMIXTURE, setting this to false, the associated parameters (ld_window_size, ld_step_size, and r2_value) will be ignored. 
    ld_window_size            = 50 // 
    ld_step_size              = 10
    r2_value                  = 0.01
    
    structure_remove_indi     = "none"
    smartpca_param            = "none"
    pop_color_file            = "none"
    
    //admixture analysis parameters

    admixture                 = false
    starting_k_value          = 2
    ending_k_value            = 10
    method                    = "block"
    cross_validation          = 5
    termination_criteria      = 0.0001
    best_kval_method          = "global"
    pop_labels                = "none"
 
    //treemix analysis parameters

    treemix                   = false
    n_bootstrap               = 100
    upper_limit               = 600
    starting_m_value          = 1
    ending_m_value            = 15
    n_iter                    = 3
    k_snps                    = 500


   // sig selection unphased data 

   sig_sel                    = true
   tajima_d                   = false
   pi                         = false
   pairwise_fst               = false
   single_vs_all_fst          = true
   clr                        = false
   ihs                        = false
   nsl                        = false //not implemented yet
   xpehh                      = false
   skip_chrmwise              = true
   skip_phasing               = true
   skip_pop                   = "${baseDir}/../input_files/sel_rem_pop_ids.map"
   min_samples_per_pop        = 6
   sel_window_size            = 0
   tajimasd_window_size       = 50000
   fst_window_size            = 0
   fst_step_size              = 0
   pi_window_size             = 0
   pi_step_size               = 0
   anc_files                  = "none"
   grid_space                 = 50000 //option "g", user-defined space between grid-points
   grid_points                = 0 //option "G", user-defined number of equally spaced points to be tested
   use_precomputed_afs        = true //enable "-l" option
   use_recomb_map             = "default" // enable "-lr" option of sweepfinder2, other options: "default" or "none"
   selscan_map                = "none" // other option, csv file containing two column --> chrom,map_file
   ihs_params                 = "none"
   xpehh_params               = "none"
   

    //begale phasing parameters

    ref_vcf                   = "none"
    cm_map                    = "none"
    burnin_val                = 3
    iterations_val            = 3
    impute_status             = false
    ne_val                    = 1000000

    """.stripIndent()
}

workflow PRINT_HELP{
        print_help()
    }
