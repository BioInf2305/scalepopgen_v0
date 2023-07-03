process MAKE_NJ_TREE{
    
    tag {"making_nj_tree"}
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/pairwiseFst", mode:"copy")

    input:
        file(pairwiseFstFiles)

    output:
        file("nj.tree")


    script:
    
    """    
    python3 ${baseDir}/bin/makeFstTree.py -i ${pairwiseFstFiles} -o nj.tree

    """
}
