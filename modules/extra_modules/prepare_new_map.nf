process PREPARE_NEW_MAP{

	tag { "preparing_new_map" }
	label "oneCpu"
        conda "${baseDir}/environment.yml"
        container "maulik23/scalepopgen:0.1.1"

	input:
            path(bed)
            file(indi_list)

	output:
            path("${prefix}_sample.map"), emit: new_map

	when:
		task.ext.when == null || task.ext.when

	script:
            prefix = params.prefix
            def o_prefix = bed[0].baseName

        """
            awk 'NR==FNR{sample[\$1];next}\$2 in sample{print \$2,\$1}' ${indi_list} ${o_prefix}.fam \
            > ${prefix}_sample.map

        """
}
