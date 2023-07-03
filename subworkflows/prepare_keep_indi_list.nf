include { GET_KEEP_INDI_LIST } from '../modules/plink/get_keep_indi_list'

workflow PREPARE_KEEP_INDI_LIST{
    take:
        bed
    main:
        GET_KEEP_INDI_LIST( bed )
   emit:
	indi_list = GET_KEEP_INDI_LIST.out.keep_indi_list
        new_map = GET_KEEP_INDI_LIST.out.keep_indi_map
        n1_bed = GET_KEEP_INDI_LIST.out.missingness_filt_bed
}
