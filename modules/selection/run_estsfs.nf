process RUN_ESTSFS{

    tag { "index_vcf_${chrom}" }
    label "oneCpu"
    container "popgen48/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/ancestral_alleles_determination/est-sfs/", mode:"copy")

    input:
        tuple val(chrom), path(vcf), path(idx), path(sample_map)

    output:
        tuple val(chrom), path ("*.anc"), emit: chrom_anc
        path("*.txt")
        path("${chrom}.estsfs.log")
        path("*_non_missing_sites.map")
    
    script:

        def outgroup = params.outgroup

        """
        echo ${outgroup} > ${chrom}_outgroup.txt

        python3 ${baseDir}/bin/vcf_to_est-sfs_input.py -c ${chrom} -V ${vcf} -M ${sample_map} -o ${chrom}_outgroup.txt


        est-sfs ${chrom}_config.txt ${chrom}_data.txt ${chrom}_seed.txt ${chrom}_out_sfs.txt ${chrom}_out_pvalue.txt > ${chrom}.estsfs.log

        awk 'NR==FNR{chrom[NR]=\$1;pos[NR]=\$2;major_allele[NR]=\$3;next}FNR>7{if(\$3<0.5){major_allele[\$1]==0 ? anc_allele=1 : anc_allele=0}else{anc_allele=major_allele[\$1]}anc_allele==1 ? der_allele=0:der_allele=1;print chrom[\$1],pos[\$1],anc_allele,der_allele}' ${chrom}_non_missing_sites.map ${chrom}_out_pvalue.txt > ${chrom}.anc


        """ 
}
