/* 
* convert chromosome-wise vcf files to merged bed file
*/

include { CONVERT_VCF_TO_BED } from "../modules/plink/convert_vcf_to_bed.nf"
include { MERGE_BED } from "../modules/plink/merge_bed"


workflow CONVERT_VCF_TO_PLINK{
    take:
        chrom_vcf_idx_map
    main:
        chrom_vcf = chrom_vcf_idx_map.map{ chrom, vcf, idx, mp -> tuple(chrom, vcf) }
        MERGE_BED(
        CONVERT_VCF_TO_BED(chrom_vcf).collect(),
        chrom_vcf_idx_map.map{ chrom, vcf, idx, mp -> mp }.unique()
        )

    emit:
        bed = MERGE_BED.out.merged_bed    
}
