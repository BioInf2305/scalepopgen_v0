process RUN_FASTINDEP{

	tag { "running_fastindep" }
	label "oneCpu"
        conda "${baseDir}/environment.yml"
        container "maulik23/scalepopgen:0.1.1"
        publishDir("${params.outDir}/fastindep/", mode:"copy")

	input:
            path(fastindep_in)
            path(bed)

	output:
            path("${prefix}.unrelated_samples.id"), emit: unrel_indi_id

	when:
		task.ext.when == null || task.ext.when

	script:
            prefix = params.prefix
            def o_prefix = bed[0].baseName
	    def n_runs = params.fastindep_n_runs
            def cutoff = params.rel_coeff_cutoff

        """
        $baseDir/bin/FastIndep/fastindep -t ${cutoff} -n ${n_runs} -i ${fastindep_in} -o fastindep.out

        awk -v count=0 '\$1~/Set/ && count==0{count++;sample=\$4;for(i=5;i<=NF;i++){sum++;print \$i};if(sample!=sum){err = 1;exit}}END{exit err}' fastindep.out > unrelated_samples.id

        wcl=`wc -l unrelated_samples.id`

        flc="\$(echo \$wcl| cut -d " " -f1)"

        if [[ \$flc -gt 0 ]]
            then 
                awk '{print \$1}' unrelated_samples.id > ${prefix}.unrelated_samples.id
        else
            awk '{print \$2}' ${o_prefix}.fam > ${prefix}.unrelated_samples.id
        fi


         """
}
