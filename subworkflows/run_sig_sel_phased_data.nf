/* 
* workflow to carry out signature of selection using phased data
*/

include { PHASING_GENOTYPE_BEAGLE } from '../modules/selection/phasing_genotpyes_beagle'
include { SPLIT_VCF_BY_POP } from '../modules/vcftools/split_vcf_by_pop'
include { PREPARE_MAP_SELSCAN } from '../modules/selection/prepare_map_selscan'
include { CALC_iHS } from '../modules/selscan/calc_ihs'
include { CALC_XPEHH } from '../modules/selscan/calc_xpehh'

def PREPARE_PAIRWISE_VCF( file_list_pop ){

        file1 = file_list_pop.flatten()
        file2 = file_list_pop.flatten()
        file_pairs = file1.combine(file2)
        file_pairsB = file_pairs.branch{ file1_path, file2_path ->

            samePop : file1_path == file2_path
                return tuple(file1_path, file2_path).sort()
            diffPop : file1_path != file2_path && file1_path.baseName.split("__")[0] == file2_path.baseName.split("__")[0]
                return tuple(file1_path, file2_path).sort()
        
        }
        return file_pairsB.diffPop

}

workflow RUN_SIG_SEL_PHASED_DATA{
    take:
        chrom_vcf_idx_map

    main:

        //prepare input for phasing_genotpyes_beagle//

        chrom_vcf = chrom_vcf_idx_map.map{ chrom, vcf, idx, map_f -> tuple(chrom, vcf) }

        // input for split_vcf_by_pop //

        f_map = chrom_vcf_idx_map.map{ chrom, vcf, idx, map_f -> map_f }.unique()

        
        //phase genotypes in vcf files using beagle
        if( !params.skip_phasing ){
            PHASING_GENOTYPE_BEAGLE( 
                chrom_vcf 
            )
            p_chrom_vcf_map = PHASING_GENOTYPE_BEAGLE.out.phased_vcf.combine(f_map)
        }
        else{
            p_chrom_vcf_map = chrom_vcf.combine(f_map)
                
        }

        //preparing map file ihs, nsl and XP-EHH analysis, needed by selscan


        if( params.selscan_map != "none" ){
            Channel
                .fromPath(params.selscan_map)
                .splitCsv(sep:",")
                .map{ chrom, recombmap -> if(!file(recombmap).exists() ){ exit 1, 'ERROR: input anc file does not exist  \
                    -> ${anc}' }else{tuple(chrom, file(recombmap))} }
                .set{ n1_chrom_recombmap }
        }
        else{
                n1_chrom_recombmap = PREPARE_MAP_SELSCAN( chrom_vcf )
        }


        // split phased vcf file by pop --> to be used for iHS, XP-EHH, nSL

        //p_chrom_vcf_map = PHASING_GENOTYPE_BEAGLE.out.phased_vcf.combine(f_map)

        SPLIT_VCF_BY_POP(
            p_chrom_vcf_map
        )

        // make pairwise tuple of splitted (based on pop id) phased vcf files 

        p_chrom_vcf = SPLIT_VCF_BY_POP.out.pop_phased_vcf.flatten().map{ p_vcf -> tuple( p_vcf.baseName.split("__")[0], p_vcf) }
        
        chrom_tvcf_rvcf = PREPARE_PAIRWISE_VCF(SPLIT_VCF_BY_POP.out.pop_phased_vcf).unique().map{ p1_vcf, p2_vcf -> tuple( p1_vcf.baseName.split("__")[0], p1_vcf, p2_vcf) }



        if( params.ihs ){
                
                n1_p_chrom_vcf_recombmap = p_chrom_vcf.combine(n1_chrom_recombmap, by:0)

                if(params.anc_files != "none" ){
                    Channel
                        .fromPath(params.anc_files)
                        .splitCsv(sep:",")
                        .map{ chrom, anc -> if(!file(anc).exists() ){ exit 1, 'ERROR: input anc file does not exist  \
                            -> ${anc}' }else{tuple(chrom, file(anc))} }
                        .set{ chrom_anc }
                    n2_p_chrom_vcf_recombmap_anc = n1_p_chrom_vcf_recombmap.combine(chrom_anc, by:0)
                }
                else{
                    n2_p_chrom_vcf_recombmap_anc = n1_p_chrom_vcf_recombmap.combine(["none"])
                }
                CALC_iHS(
                    n2_p_chrom_vcf_recombmap_anc.map{chrom, vcf, recomb, anc -> tuple(chrom, vcf, recomb, anc == "none"? []:anc)}
                )

        }
        if( params.xpehh ){
               chrom_tvcf_rvcf_recombmap = chrom_tvcf_rvcf.combine(n1_chrom_recombmap, by: 0)
               
                CALC_XPEHH(
                    chrom_tvcf_rvcf_recombmap
                )
        }
}
