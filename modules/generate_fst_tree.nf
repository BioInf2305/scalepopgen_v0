process GENERATE_FST_TREE{

    tag { "generate_fst_genomewide" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/", mode:"copy")

    input:
        path(fstoutfiles)

    output:
        path ("global_fst_based_nj*")
        
    
    script:
        def args = ""
        if (params.outgroup != "none" && !params.skip_sel_outgroup ){
                args = args + " -r "+params.outgroup
        }
        args = args + " -o global_fst_based_nj"

        """

        python3 ${baseDir}/bin/make_fst_tree.py -i ${fstoutfiles} ${args}
        

        """ 
}
