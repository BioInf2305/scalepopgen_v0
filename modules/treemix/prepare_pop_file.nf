process PREPARE_POP_FILE{

    tag { "preparing_pop_file" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/treemix", mode:"copy")

    input:
        path(sample_map)

    output:
        path("pop_ids.txt"), emit: pop_file

    when:
        task.ext.when == null || task.ext.when

    script:



        """

        awk '{a[\$2]}END{for(pop in a){print pop}}' ${sample_map}  > pop_ids.txt

        """ 
}
