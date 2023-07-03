/* 
*subworkflow to run F-statistics based analysis, F3, F4 and D-statistics
*/

include { RUN_QP3POP } from '../modules/fstats/run_qp3pop'
include { RUN_DTRIOS } from '../modules/fstats/run_dtrios'


workflow RUN_FSTATS{
    take:
        vcf
        id
	    bed
    main:
   	if( !params.skip_threePop ){
		RUN_QP3POP(bed)
	}
    if( !params.skip_dStats ){
    	RUN_DTRIOS(vcf, id)
    }

}
