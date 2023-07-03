/* 
* vcf filtering --> keep related individuals and filter sites based on user-defined criteria
*/

include { KEEP_INDI } from "../modules/vcftools/keep_indi"
include { FILTER_SITES } from "../modules/vcftools/filter_sites"
include { INDEX_VCF } from "../modules/index_vcf"


workflow FILTER_VCF {
    take:
        chrom_vcf_idx_map_indilist
    main:
        chrom_mp = chrom_vcf_idx_map_indilist.map{chrom, vcf, idx, mp, indi_list -> tuple(chrom,mp) }
        chrom_idx = chrom_vcf_idx_map_indilist.map{ chrom, vcf, idx, mp, indi_list -> tuple(chrom, idx) }
        if( params.apply_indi_filters ){
            chrom_vcf_indilist = chrom_vcf_idx_map_indilist.map{chrom, vcf, idx, mp, indi_list -> tuple(chrom, vcf, indi_list)}
            KEEP_INDI(
                chrom_vcf_indilist
            )
            n1_chrom_vcf = KEEP_INDI.out.filt_chrom_vcf
        }
        else{            
            n1_chrom_vcf = chrom_vcf_idx_map_indilist.map{chrom, vcf, idx, mp, indi_list -> tuple(chrom, vcf)}
        }   
        if( params.apply_snp_filters ){
            FILTER_SITES(n1_chrom_vcf)
            n2_chrom_vcf = FILTER_SITES.out.sites_filt_vcf
        }
        else{
            n2_chrom_vcf = n1_chrom_vcf
        }
        if( params.apply_indi_filters || params.apply_snp_filters ){
            n1_chrom_idx = INDEX_VCF(n2_chrom_vcf)
        }
        else{
            n1_chrom_idx = chrom_idx
        }
        n2_chrom_vcf_idx = n2_chrom_vcf.combine(n1_chrom_idx, by:0)
        n2_chrom_vcf_idx_map = n2_chrom_vcf_idx.combine(chrom_mp, by:0)
    emit:
        n2_chrom_vcf_idx_map = n2_chrom_vcf_idx_map
}
