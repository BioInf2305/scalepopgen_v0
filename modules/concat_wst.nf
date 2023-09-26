process CONCAT_WFST{

    tag { "calculating_pairwise_fst" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/vcftools/pairwise_fst/${prefix}/", mode:"copy")

    input:
        tuple val(prefix), path(fst_out)

    output:
        path("*allchrm_weir_fst.txt"), emit: concatenated_fst_files

    script:

        """
             awk '\$0!~/MEAN_FST/ || NR==1{print}' *.fst > ${prefix}_allchrm_weir_fst.txt

        """

}
