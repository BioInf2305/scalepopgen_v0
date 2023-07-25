include { CALC_INDIV_SUMMARY } from '../modules/plink/calc_indiv_summary'
include { COMBINE_INDIV_SUMMARY } from '../modules/combine_indiv_summary'

workflow PREPARE_INDIV_REPORT{
    take:
        chrom_vcf_idx_map
    main:
        CALC_INDIV_SUMMARY(chrom_vcf_idx_map)
        COMBINE_INDIV_SUMMARY(
            CALC_INDIV_SUMMARY.out.samplesummary.collect(),
            CALC_INDIV_SUMMARY.out.sampledepthinfo.collect()
        )
}
