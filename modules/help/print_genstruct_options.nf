def print_help() {
    log.info"""

Usage:    
    nextflow run scalepopgen.nf --input ../example_plink/*.{bed,bim,fam} --outDir ../example_out_bed/ 
    nextflow run scalepopgen.nf --input ../example_vcf/chr_vcf_idx.csv --sample_map ../example_vcf/sample_pop.map --outDir ../example_out_vcf/

 --genetic_structure [bool] setting this to "false" will skip processing this entire module, meaning all the following options will be disabled. Default: true

--runs_smartpca [bool] run PCA using the method implemented in smartpca tool of eigensoft. Default: false

--run_gds_pca [bool] run PCA using the method implemented in snprelate package of R. Default: true

--ld_filt [bool] apply ld filtering before running PCA or/and admixture analysis. Settting this to Default: true. 

--ld_window_size [int] window size for LD calculation (as implemented in plink). Default: 50

--ld_step_size [int] step size for LD calculation (as implemented in plink). Default: 10

--r2_value [float] r2 value of a SNP pair above which one of the SNPs will be discarded. Default: 0.01

--structure_remove_indi [file] path to the file containing list of individuals to be removed before running PCA and/or admixture. Note that this file should contain two columns: first column, population_id and second column, sample id to be remvoed. Default: "none".

--smartpca_param [file] path to the file containing additional/optional parameters to apply smartpca. To see the list of these parameters: . Default: "none"

--pop_color_file [file] path to the file containing color codes of each population to be plotted. This file should contain data in two columns: first column, pop_id, and second column, color name of code. If no such file is provided. Random colors will be chosen. Default: "none"

--admixture [bool] whether to run admixture analysis. Default: false

--starting_k_value [int] starting range of "k" value to run admixture analysis. Default: 1

--ending_k_value [int] ending range of "k" value to run admixture analysis. Default: 40

--cross_validation [int] cross validation to be run on the results of each "k" value of admixture. Default: 5

--termination_criteria [float] termination criteria of admixture tool. Default: 0.0001

--pop_labels [file] any additional pop label to be plotted along with provided pop label in admixture results to be plotted. This file should contain data in two columns: first column, additional_pop_id, and second column, pop_id, mentioned in map (in case of vcf input) or fam (in case of plink binary input) file.  Default: "none"

For more details (output files and processing) on this module, refer to readme/explore_genetic_structure.md

    """.stripIndent()
}

workflow PRINT_GENSTRUCT_OPTIONS{
        print_help( )
    }
