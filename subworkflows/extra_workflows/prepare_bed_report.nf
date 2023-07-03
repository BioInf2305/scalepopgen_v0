include { CALC_FREQ_FAMILY } from '../modules/plink/calc_freq_family'
include { CALC_HWE_FAMILY } from '../modules/plink/calc_hwe_family'
include { CALC_INDIV_SUMMARY } from '../modules/calc_indiv_summary'
include { COMBINED_REPORTS } from '../modules/combined_reports'

workflow PREPARE_BED_REPORT{
    take:
        bed

    main:
        mafReport = CALC_FREQ_FAMILY(bed)
        hweReport = CALC_HWE_FAMILY(bed)
        indivReport = CALC_INDIV_SUMMARY(bed)
        COMBINED_REPORTS(mafReport.mafSummary, hweReport.heteroSummary)
}
