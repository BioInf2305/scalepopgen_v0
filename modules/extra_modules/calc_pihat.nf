process CALC_PIHAT{

	tag { "calculating_pihat" }
	label "oneCpu"
        conda "${baseDir}/environment.yml"
        container "maulik23/scalepopgen:0.1.1"
        publishDir("${params.outDir}/keep_indi_list/", mode:"copy")

	input:
	    file(bed)

	output:
	    path("*fastindep.in"), emit: fastindep_in
            path("*pihat.txt"), emit: pihat_out

	when:
	    task.ext.when == null || task.ext.when

	script:
            def o_prefix = bed.baseName
            prefix = params.prefix
            def max_chrom = params.max_chrom
            def opt_arg = ""
            opt_arg = opt_arg + " --chr-set "+ max_chrom
            if( params.allow_extra_prefix ){
                    
                opt_arg = opt_arg + " --allow-extra-chr "

                }

            opt_arg = opt_arg + " --genome "


            """
            awk '{print \$1"_"\$2}' ${o_prefix}.fam > indi.id

            plink --bfile ${prefix} ${opt_arg}

            awk '{print \$1"_"\$2,\$3"_"\$4,\$10}' plink.genome > ${prefix}.pihat.txt

            python3 ${baseDir}/bin/prepareFastindepInput.py ${prefix}.pihat.txt indi.id ${prefix}.fastindep.in

            """
}
