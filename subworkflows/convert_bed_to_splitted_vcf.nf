/* 
* convert plink bed file to splitted compressed chromosome-wise vcf files
*/

include { CONVERT_BED_TO_VCF } from "../modules/plink/convert_bed_to_vcf"
include { SPLIT_VCF_BY_CHROM } from "../modules/selection/split_vcf_by_chrom"
include { INDEX_VCF } from "../modules/index_vcf"
include { BGZIP_VCF } from "../modules/bgzip_vcf"


workflow CONVERT_BED_TO_SPLITTED_VCF{
    take:
        bed
    main:
        CONVERT_BED_TO_VCF(bed)
        if( params.skip_chrmwise && (!params.ihs && !params.clr && !params.xpehh) ){
            p_chrom_vcf = CONVERT_BED_TO_VCF.out.vcf.map{vcf-> tuple(vcf.baseName,vcf)}
            p_chrom_gzvcf = BGZIP_VCF(p_chrom_vcf)
            p_chrom_idx = INDEX_VCF(p_chrom_gzvcf)
            p_chrom_vcf_idx = p_chrom_gzvcf.combine(p_chrom_idx, by: 0)
            p1_chrom_vcf_idx_map = p_chrom_vcf_idx.combine(CONVERT_BED_TO_VCF.out.sample_map)
        }
        else{
        SPLIT_VCF_BY_CHROM(
            CONVERT_BED_TO_VCF.out.vcf
        )
        p_chrom_vcf_idx=SPLIT_VCF_BY_CHROM.out.splitted_vcfs.flatten().map{vcf_o_idx->tuple(vcf_o_idx.baseName.split(".split.")[0],vcf_o_idx)}.groupTuple()
        p_chrom_vcf_idx_map=p_chrom_vcf_idx.combine(CONVERT_BED_TO_VCF.out.sample_map)
        p1_chrom_vcf_idx_map = p_chrom_vcf_idx_map.map{chrom, vcf_idx, map_f -> tuple(chrom,vcf_idx[0], vcf_idx[1], map_f)}
        }
    emit:
        p2_chrom_vcf_idx_map = p1_chrom_vcf_idx_map
}
