process CALC_KINGCOEFF{

	tag { "calculating_kingcoeff" }
	label "oneCpu"
        conda "${baseDir}/environment.yml"
        container "maulik23/scalepopgen:0.1.1"
        publishDir("${params.outDir}/king/results/", mode:"copy")

	input:
	    file(bed)

	output:
		path("*fastindep.in"), emit: fastindep_in
                path("*.kingcoeff.txt"), emit: kingcoeff_out

	when:
		task.ext.when == null || task.ext.when
	
    script:

        prefix = params.prefix
        def o_prefix = bed[0].baseName
	def max_chrom = params.max_chrom+1

        if( !params.allow_extra_chrom){

        """
        awk '{print \$2}' ${o_prefix}.fam > indi.id
        
        king -b ${o_prefix}.bed --kinship --degree 0 --prefix ${prefix} --sexchr ${max_chrom}

        awk 'NR==FNR{print \$2,\$4,\$8;next}FNR!=1{print \$2,\$3,\$9}' ${prefix}.kin0 ${prefix}.kin > ${prefix}.kingcoeff.txt

        python3 ${baseDir}/bin/prepare_fastindep_input.py ${prefix}.kingcoeff.txt indi.id ${prefix}.fastindep.in

        """
        }

        else{

        """
        awk '{print \$2}' ${o_prefix}.fam > indi.id

        awk -v cnt=0 '{if(!(\$1 in chrm)){chrm[\$1];cnt=cnt+1;print \$1,cnt}}' ${o_prefix}.bim > new_chrm.id
        
        awk 'NR==FNR{new_id[\$1]=\$2;next}{print new_id[\$1],\$2,\$3,\$4,\$5,\$6}' new_chrm.id ${o_prefix}.bim > ${o_prefix}.1.bim

        mv ${o_prefix}.1.bim ${o_prefix}.bim
        
        
        king -b ${o_prefix}.bed --kinship --degree 0 --prefix ${prefix} --sexchr ${max_chrom}

        awk 'NR==FNR{print \$2,\$4,\$8;next}FNR!=1{print \$2,\$3,\$9}' ${prefix}.kin0 ${prefix}.kin > ${prefix}.kingcoeff.txt

        python3 ${baseDir}/bin/prepare_fastindep_input.py ${prefix}.kingcoeff.txt indi.id ${prefix}.fastindep.in

        """

        }

}
