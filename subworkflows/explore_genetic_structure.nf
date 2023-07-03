/* 
*subworkflow to run PCA and ADMIXTURE analysis
*/

include { REMOVE_CUSTOM_INDI as REMOVE_INDI_STRUCTURE } from '../modules/plink/remove_custom_indi'
include { APPLY_LD_FILTERS as LD_FILTER_STRUCTURE } from '../modules/plink/apply_ld_filters'
include { RUN_SMARTPCA } from '../modules/pca/run_smartpca'
include { RUN_SNPGDSPCA } from '../modules/pca/run_snpgdspca'
include { RUN_ADMIXTURE_DEFAULT } from '../modules/admixture/run_admixture_default'
include { EST_BESTK_PLOT } from '../modules/admixture/est_bestk_plot'
include { GENERATE_PONG_INPUT } from '../modules/admixture/generate_pong_input'
include { UPDATE_CHROM_IDS } from '../modules/plink/update_chrom_ids'


workflow EXPLORE_GENETIC_STRUCTURE{
    take:
        bed
    main:
	if ( params.structure_remove_indi != "none" ){
		indi_list = Channel.fromPath( params.structure_remove_indi, checkIfExists: true)
		REMOVE_INDI_STRUCTURE( bed, indi_list )
		rem_indi_filt_bed = REMOVE_INDI_STRUCTURE.out.rem_indi_bed
	}
	else{
		rem_indi_filt_bed = bed
	}
	if ( params.ld_filt ){
		LD_FILTER_STRUCTURE(rem_indi_filt_bed)
		ld_filt_bed_n = LD_FILTER_STRUCTURE.out.ld_filt_bed
	}
	else{
		ld_filt_bed_n = rem_indi_filt_bed
	}
       if( params.allow_extra_chrom){
            UPDATE_CHROM_IDS( ld_filt_bed_n )
            n1_ld_filt_bed = UPDATE_CHROM_IDS.out.update_chromids_bed
       }
      else{
            n1_ld_filt_bed = ld_filt_bed_n
        }
        if( params.run_smartpca ){
                RUN_SMARTPCA(n1_ld_filt_bed)
            }
        if( params.run_gds_pca ){
                RUN_SNPGDSPCA(n1_ld_filt_bed)		
        }
        if( params.admixture ){
           k_val = Channel.from( params.starting_k_value..params.ending_k_value )
           admixture_list = k_val.combine( n1_ld_filt_bed )
           RUN_ADMIXTURE_DEFAULT( admixture_list )
           EST_BESTK_PLOT( 
            RUN_ADMIXTURE_DEFAULT.out.log_file.collect(),
            RUN_ADMIXTURE_DEFAULT.out.pq_files.collect(),
            n1_ld_filt_bed
           )
           GENERATE_PONG_INPUT( RUN_ADMIXTURE_DEFAULT.out.log_file.collect() )
        }
}
