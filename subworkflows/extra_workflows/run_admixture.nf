/* 
*subworkflow to run admixture analysis
*/

include { REMOVE_CUSTOM_INDI as REMOVE_INDI_ADMIXTURE_ANALYSIS } from '../modules/plink/remove_custom_indi'
include { APPLY_LD_FILTERS as LD_FILTER_ADMIXTURE } from '../modules/plink/apply_ld_filters'
include { RUN_ADMIXTURE_TOOL } from '../modules/admixture/run_admixture_tool'
include { EST_BESTK_PLOT } from '../modules/admixture/est_bestk_plot'
include { GENERATE_PONG_INPUT } from '../modules/admixture/generate_pong_input'


workflow RUN_ADMIXTURE{
    take:
        filtBed
    main:
	if( params.admixture_remove_indiv != "none" ){
		indiList = Channel.fromPath( params.admixture_remove_indiv, checkIfExists: true)
		rmAdmixtureIndiBed = REMOVE_INDI_ADMIXTURE_ANALYSIS(filtBed, indiList)
		filtBedRmIndi = rmAdmixtureIndiBed
	}
	else{
		filtBedRmIndi = filtBed
	}
	if ( !params.skip_ld_filt_admixture ){
		ldThinnedBed = LD_FILTER_ADMIXTURE(filtBedRmIndi)
		filtBedRmIndiLd = ldThinnedBed.filtLdBed
	}
	else{
		filtBedRmIndiLd = filtBedRmIndi
	}
   kValue = Channel.from( params.starting_k_value..params.ending_k_value )
   admixture_list = kValue.combine( filtBedRmIndiLd )
   admixtureResults = RUN_ADMIXTURE_TOOL( admixture_list )
   EST_BESTK_PLOT( admixtureResults.logFile.collect() )
   GENERATE_PONG_INPUT( admixtureResults.logFile.collect() )
}
