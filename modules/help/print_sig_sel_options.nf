def print_sig_sel_options() {
    log.info"""
    Usage: 
    nextflow run scalepopgen.nf --input ../example_plink/*.{bed,bim,fam} --outDir ../example_out_bed/ 
    nextflow run scalepopgen.nf --input ../example_vcf/chr_vcf_idx.csv --sample_map ../example_vcf/sample_pop.map --outDir ../example_out_vcf/

    --sig_sel [bool]            setting this to "false" will not run this entire workflow. Default: false

    --skip_sel_outgroup [bool]  setting this to "false" will not apply the methods to identify signatures of selection on outgroup samples. Default:                                 false

    --skip_pop [file]           the path to the text file containing population IDs that will be skipped from all the analyses of this section.

    --sel_perc_cutoff [float]    cutoff to consider regions as candidates of selection. Default is 0.05, meaning that top 0.05 percentage of windows                                   will be considered candidates of selection. Note that depending on the method applied, scalepopgen will automatical                                  -ly consider the sign of scores, i.e. negative or positive. For example, in case of tajimas D, the most negative va                                  -lues will be considered, while in case of fst, the most positive values will be considered. Default: 0.05

    --manhattplot_yml [file]     provide path to the yml file for interactive manattan plot. Default: ./parameters/plots/manhattplot.yml

    --tajimas_d [bool]          whether to calculate Tajimas'D for each population using vcftools. Default: false

    --tajimasd_window_size [int] window size for Tajimas's D calculation. Default : 50000

    --pi [bool]                 whether to calculate per-SNP pi values or per-window pi values for each population using vcftools. Default: false

    --pi_window_size [int]   window size for the calculation of pi. Default: 50000

    --pi_step_size [int]    step size for the calculation of pi. Default: 0. Note that the default values will generate the non-overlapping windows

    --pairwise_fst [bool]   whether or not to calculate pairwise fst in windows or for each SNPs for every possible pair of population.Default: false

    --fst_window_size [int]    the desired window size for pairwise Fst calculation. Default: 50000

    --fst_step_size [int]      the desired step size between windows for Fst calculation. Default: -9. Any value of less than or equal to zero assume                               that window size and step size are equal. 

    --clr [bool]                 whether or not to calculate composite likelihood ratio (CLR) using sweepfinder2

    --use_precomputed_afs [bool] whether to use pre-computed empirical allele frequency spectrum to detect signatures of selection using sweepfinder2                                 enable the option "-l" in SweepFinder2.

    --anc_files [str]          in case of sweepfinder2, including the information about acestral and derived allele increases power of the analyses,                                by invoking this option it is possible to include this information. It  takes any of these three parameters: 
                                (i) "create": supplying this string as parameter will invoke the process (described in details in read me) of detect-                                   -ing ancestral alleles using the outgroup samples present in the vcf files 
                                (ii) "none": supplying this string as parameter will prepare sweepfinder2 input as not polarized.                                                    (iii). if none of the "create" or "none" is supplied, then the parameter is assumed to be the path to the csv file ha                                       -ving these two columns: chromosome id and the path to its respective space separated file containing informat                                       -ion about ancestral alleles. For reference, refer to these examples files: test_files/anc_files.csv.

    --use_recomb_map [str]     identify selective sweeps with pre-computed empirical spectrum and recombination map, option "-lr", in SweepFinder2.                                 This argument takes any of these three options: 
                                (i) if set to "default": the workflow will create a recombination rate input file assuming 1cm = 1mbp, 
                                (ii). if set to "none": the Sweepfinder2 analysis will be run without recombination map file. 
                                (iii), if it is neither "default" nor "none", then the path to the csv file having these two columns:                                                   chromosome_id,  and the path to its respective recombination map file in the format as recognized by sweepfinder2. 

    --grid_space [int]         the spacing in number of nucleotides between grid points, option "g" in SweepFinder2. Default: 50000.

    --grid_points [int]        the number of points equally spaced across the genome, option "G" in SweepFinder2. Default: -9. Note that any value                                greater than zero will carry out Sweepfinder2 analyses with --grid points and ignore the value specified in --grid space.

    --skip_phasing [bool]  setting this to false will skip phasing the data for the analyses with selscan, meaning that the workflow assumed that the                           vcf files supplied are already phased.

   --impute_status [bool] an option to impute the missing genotypes (the reference vcf file need to be provided for that), option "impute" in Beagle

    --cm_map [file]         an option to provide  a path to the csv file having these two columns: chromosome id and the path to its respective PLINK                            format genetic map with cM units, option "map" in Beagle. 

    --burnin_val [int]      the maximum number of burnin iterations, option "burnin" in Beagle. Default: 3.
     
    --iterations_val [int]  the number of iterations, option "iterations" in Beagle. Default: 12.

    --ne_val [int]          the effective population size, option "ne" in Beagle. Default: 1000000

    --ihs [bool]            whether or not to calculate iHS using selscan

    --xpehh [bool]           whether or not to calculate XP-EHH using selscan

    --selscan_map [str]        By invoking this option, it is possible to include recombination map information in selscan analysis. It takes any of                               these three parameters: 
                                (i). path to the csv file having these two columns: chromosome id and the path to its respective recombination map, 
                               (ii), "default": create map file with genetic and physical positions for each variant site using default conversion. 

    --ihs_args [str]          optional parameters that can be applied to iHS computation.To see the list of such parameters refer to the selscan docu                              -mentation. Default: --maf 0.05 --max-gap 200000

    --xpehh_args [str]      optional parameters that can be applied to XP-EHH computation. To see the list of such parameters refer to the selscan do                             -cumentation. Default: --maf 0.05 --max-gap 200000

    --norm_ihs_args [str]    provide flags and arguments to normalize population-wise ihs computations. Default: --bins 100
    
    --norm_xpehh_args [str]    provide flags and arguments to normalize pair-wise xp-ehh computations. Default: --bins 100

    
    """
}

workflow PRINT_SIG_SEL_OPTIONS{
        print_sig_sel_options( )
    }
