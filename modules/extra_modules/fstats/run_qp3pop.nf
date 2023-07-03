process RUN_QP3POP{

    tag { "running_Qp3pop" }
    label "oneCpu"
    container 'maulik23/scalepopgen:0.1.1'
    publishDir("${params.outDir}/fstats", mode:"copy")

    input:
        tuple val(chrom), file(plink_files)

    output:
        path("${chrom}*{.par,.3pop.out,.snp,.ind,.eigenstratgeno}")

    script:
        
	def max_chrom = params.max_chrom
	def popCombFile = params.popCombFile

	if( !params.allow_extra_chrom ){

        """

	awk '{familyId[\$1];next}END{for(id in familyId){print id}}' *.fam > family.id

	plink --bfile ${chrom} --chr-set ${max_chrom} --recode --out ${chrom} 

	awk '\$6=\$1' ${chrom}.ped > ${chrom}.1.ped

	python3 ${baseDir}/bin/createParEigenstrat.py ${chrom} convertf ${max_chrom} ${popCombFile}

	convertf -p ${chrom}.pedToEigenstraat.par

    if [[ $popCombFile == "none" ]];then 

	    ${baseDir}/bin/permuteThreepops.awk family.id > ${chrom}.qp3PopComb.txt

	    python3 ${baseDir}/bin/createParEigenstrat.py ${chrom} qp3pop ${max_chrom} ${chrom}.qp3PopComb.txt
    
    else

	    python3 ${baseDir}/bin/createParEigenstrat.py ${chrom} qp3pop ${max_chrom} ${popCombFile}
    fi
    
	qp3Pop -p ${chrom}.qp3Pop.par > ${chrom}.3pop.out


        """ 
	}
	
	else{

	"""

	awk '{familyId[\$1];next}END{for(id in familyId){print id}}' *.fam > family.id

	${baseDir}/bin/permuteThreepops.awk family.id > ${chrom}.qp3PopComb.txt

	plink --bfile ${chrom} --chr-set ${max_chrom} --allow-extra-chr --recode --out ${chrom} 

	awk '\$6=\$1' ${chrom}.ped > ${chrom}.1.ped

	python3 ${baseDir}/bin/createParEigenstrat.py ${chrom} convertf ${max_chrom} ${popCombFile}

	convertf -p ${chrom}.pedToEigenstraat.par

	python3 ${baseDir}/bin/createParEigenstrat.py ${chrom} qp3pop ${max_chrom} ${popCombFile}

	qp3Pop -p ${chrom}.qp3Pop.par > ${chrom}.3pop.out
	
	"""
	}

}
