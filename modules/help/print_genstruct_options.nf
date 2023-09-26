def print_help() {
    log.info"""

Usage:    
    nextflow run scalepopgen.nf --input ../example_plink/*.{bed,bim,fam} --outDir ../example_out_bed/ 
    nextflow run scalepopgen.nf --input ../example_vcf/chr_vcf_idx.csv --sample_map ../example_vcf/sample_pop.map --outDir ../example_out_vcf/

 --genetic_structure [bool] setting this to "false" will skip processing this entire module, meaning all the following options will be disabled. Default: true

--runs_smartpca [bool] run PCA using the method implemented in smartpca tool of eigensoft. Default: false

--run_gds_pca [bool] run PCA using the method implemented in snprelate package of R. Default: true

--ld_filt [bool] whether or not to apply ld-based pruning of the dataset before running PCA or/and admixture analysis. Default: true.

--ld_window_size [int] window size for LD calculation (as implemented in plink). Default: 50

--ld_step_size [int] step size for LD calculation (as implemented in plink). Default: 10

--r2_value [float] r2 value of a SNP pair above which one of the SNPs will be discarded. Default: 0.01

--structure_remove_indi [file] path to the file containing list of individuals to be removed before running PCA and/or admixture. Note that this file should contain two columns: first column as population_id and second column as sample id to be removed. Default: "none".

--smartpca_param [file] path to the file containing additional/optional parameters to apply smartpca. To see the list of these parameters:https://github.com/chrchang/eigensoft/blob/master/POPGEN/README. Default: "none"

--pop_color_file [file] path to the file containing color codes of each population to be plotted. This file should contain data in two columns: first column as pop_id and second column as color name of code. If no such file is provided, random colors will be chosen. Default: "none"

--f_pop_marker [file] path to the file containing first column as population id and second column as marker shape. Available markers shape are listed in "./extra/markershapes.txt" . If no such file is provided, random marker shapes will be selected.

--pca_yml [file] path to the yaml file containing the paramterers to plot interactive PCA results. Default:"./parameters/plots/pca_params.yml". 

--fst_nj_yml [file] path to the yaml file containing the paramterers to plot interactive fst-based NJ tree. Default:"./parameters/plots/fst_nj.yml"

--ibs_nj_yml [file] path to the yaml file containing the paramterers to plot interactive ibs distance-based NJ tree. Default:"./parameters/plots/ibs_nj.yml"

--admixture [bool] run admixture analysis. Default: false

--starting_k_value [int] starting range of "k" value to run admixture analysis. Default: 1

--ending_k_value [int] ending range of "k" value to run admixture analysis. Default: 40

--cross_validation [int] cross validation to be run on the results of each "k" value of admixture. Default: 5

--termination_criteria [float] termination criteria of admixture tool. Default: 0.0001

--admixture_yml [file]  path to the yaml file containing the parameters of plotting interactive Q matrix of optimal value of "K". Default: "./parameters/plots/admixture.yml

--fst_based_nj_tree [bool] whether or not to construct NJ tree based on average fst pairwise distance between each pair of population. Default: false

--est_1_min_ibs_based_nj_tree [bool] whether or not to construct NJ tree based on average 1-IBS pairwise distance between each pair of samples. Default: false

For more details (output files and processing) on this module, refer to online documentation

    """.stripIndent()
}

workflow PRINT_GENSTRUCT_OPTIONS{
        print_help( )
    }
