process VCF_TO_TREEMIX_INPUT{

    tag { "convert_vcf_to_treemix_input_${chrom}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "popgen48/scalepopgen:0.1.1"
    publishDir("${params.outDir}/treemix/input_files/chromosomewise_treemix_files", mode:"copy")

    input:
        tuple val(chrom), file(vcf), file(idx), file(map_file)

    output:
        path("*treemixIn.txt"), emit: treemix_input

    when:
        task.ext.when == null || task.ext.when

    script:
        

        """

	python3 ${baseDir}/bin/vcfToPopgen/vcf_to_treemix.py -v ${vcf} -m ${map_file} -o ${chrom} -O t


        """ 

}
