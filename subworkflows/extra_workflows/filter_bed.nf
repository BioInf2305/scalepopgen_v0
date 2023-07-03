include { UPDATE_FAMILY_IDS } from '../modules/plink/update_family_ids'
include { REMOVE_CUSTOM_INDI as REMOVE_INDI_ALL_ANALYSIS } from '../modules/plink/remove_custom_indi'
include { REMOVE_CUSTOM_SNPS as REMOVE_SNPS_ALL_ANALYSIS } from '../modules/plink/remove_custom_snps'
include { APPLY_MISSING_MAF_FILTERS } from '../modules/plink/apply_missing_maf_filters'
//include { PREPARE_FILTERING_REPORT } from '../modules/plink/prepare_filtering_report.nf'

workflow FILTER_BED {
    take:
        bed
    main:
        if (params.new_family_ids != "none"){
                update_family_ids_out = UPDATE_FAMILY_IDS(bed, params.new_family_ids)
                bedFilter1 = update_family_ids_out
            }
        else{
                bedFilter1 = bed
            }
        if( params.remove_indiv != "none" ){
		    indiList = Channel.fromPath( params.remove_indiv, checkIfExists: true)
            removedCustIndi = REMOVE_INDI_ALL_ANALYSIS(bedFilter1, indiList)
            bedFilter2 = removedCustIndi
        }
        else{
            bedFilter2 = bedFilter1
        }
        if(params.remove_snps != "none"){
                removedCustSnps = REMOVE_SNPS_ALL_ANALYSIS(bedFilter2)
                bedFilter3 = removedCustSnps
        }
        else{
            bedFilter3 = bedFilter2
        }
        appliedMissMafFilters = APPLY_MISSING_MAF_FILTERS(bedFilter3)
        //PREPARE_FILTERING_REPORT(bed, appliedMissMafFilters.filteredBed, appliedMissMafFilters.log)

   emit:
	bedFile = appliedMissMafFilters
}
