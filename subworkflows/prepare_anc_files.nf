/* 
* workflow to carry out signature of selection using sweepfinder2
*/

include { RUN_ESTSFS } from '../modules/selection/run_estsfs'
include { EXTRACT_SITES } from '../modules/vcftools/extract_sites'


workflow PREPARE_ANC_FILES{
    take:
        chrom_vcf_idx_map
    main:
        if( params.anc_files != "create" && params.anc_files != "none" ){
            Channel
                .fromPath(params.anc_files)
                .splitCsv(sep:",")
                .map{ chrom, anc -> if(!file(anc).exists() ){ exit 1, 'ERROR: input anc file does not exist  -> ${anc}' } else{tuple(chrom, file(anc))} }
                .set{ chrom_anc }
            chrom_vcf_idx_map_anc = chrom_vcf_idx_map.combine(chrom_anc, by:0)
            chrom_map_anc = chrom_vcf_idx_map_anc.map{chrom, vcf, idx, map, anc -> tuple(chrom, map, anc)}
            chrom_vcf_idx = EXTRACT_SITES(chrom_vcf_idx_map_anc).out.chrom_ancvcfpos_idx
            n1_chrom_vcf_idx_map_anc = chrom_vcf_idx.combine(chrom_map_anc,by:0)
            n2_chrom_vcf_idx_map_anc = n1_chrom_vcf_idx_map_anc.map{chrom,v_i,m,a -> tuple(chrom,v_i[0],v_i[1],m,a)}
        }
        if( params.anc_files == "create" ){
            chrom_anc = RUN_ESTSFS(chrom_vcf_idx_map).chrom_anc
            chrom_vcf_idx_map_anc = chrom_vcf_idx_map.combine(chrom_anc, by:0)
            chrom_map_anc = chrom_vcf_idx_map_anc.map{chrom, vcf, idx, map, anc -> tuple(chrom, map, anc)}
            chrom_vcf_idx = EXTRACT_SITES(chrom_vcf_idx_map_anc).chrom_ancvcfpos_idx
            n1_chrom_vcf_idx_map_anc = chrom_vcf_idx.combine(chrom_map_anc,by:0)
            n2_chrom_vcf_idx_map_anc = n1_chrom_vcf_idx_map_anc.map{chrom,v_i,m,a -> tuple(chrom,v_i[0],v_i[1],m,a)}
        }
        if(params.anc_files == "none" ){
                n2_chrom_vcf_idx_map_anc = chrom_vcf_idx_map.combine(["none"])
            }

    emit:
        n2_chrom_vcf_idx_map_anc = n2_chrom_vcf_idx_map_anc
}
