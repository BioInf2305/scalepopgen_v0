/* 
* workflow to carry out signature of selection using phased data
*/

include { PHASING_GENOTYPE_BEAGLE } from '../modules/selection/phasing_genotpyes_beagle'
include { SPLIT_IDFILE_BY_POP as SPLIT_FOR_SELSCAN } from '../modules/selection/split_idfile_by_pop'
include { SPLIT_VCF_BY_POP } from '../modules/vcftools/split_vcf_by_pop'
include { PREPARE_MAP_SELSCAN } from '../modules/selection/prepare_map_selscan'
include { CALC_iHS } from '../modules/selscan/calc_ihs'
include { CALC_XPEHH } from '../modules/selscan/calc_xpehh'
include { NORM as NORM_iHS } from '../modules/selscan/norm'
include { NORM as NORM_XPEHH } from '../modules/selscan/norm'

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

        //chrom_anc = chrom_vcf_idx_map_anc.map{ chrom, vcf, idx, map_f, anc -> tuple(chrom, anc) }

        // input for split_vcf_by_pop //

        f_map = chrom_vcf_idx_map.map{ chrom, vcf, idx, map_f -> map_f }.unique()

        type_analysis = Channel.value('selscan')

        SPLIT_FOR_SELSCAN(
            f_map,
            type_analysis
        )

        isc = SPLIT_FOR_SELSCAN.out.iss
        
        //phase genotypes in vcf files using beagle
        if( !params.skip_phasing ){
            if( params.ref_vcf != "none" ){
            Channel
                    .fromPath( params.ref_vcf )
                    .splitCsv(sep:",")
                    .map{ i_chrom, i_vcf -> if(!file(i_vcf).exists() ){ exit 1, 'ERROR: reference vcf file for imputatation does not exist  \
                        -> ${i_vcf}' }else{tuple(i_chrom, file(i_vcf))} }
                    .set{ i_chrom_vcf }
            
                chrom_vcf_pvcf = chrom_vcf.combine(i_chrom_vcf,by:0)        
            }
            else{
                chrom_vcf_pvcf = chrom_vcf.combine(["none"])
            }
            
            n1_chrom_vcf_pvcf = chrom_vcf_pvcf.map{ chrom, vcf, pvcf ->tuple( chrom, vcf, pvcf == "none" ? []: pvcf)}

            PHASING_GENOTYPE_BEAGLE( 
                n1_chrom_vcf_pvcf
            )
            p_chrom_vcf_map = PHASING_GENOTYPE_BEAGLE.out.phased_vcf.combine(f_map)
        }
        else{
            p_chrom_vcf_map = chrom_vcf.combine(f_map)
                
        }
        p_chrom_vcf_map_isc = p_chrom_vcf_map.combine(isc)

        //preparing map file ihs and XP-EHH analysis, needed by selscan


        if( params.selscan_map != "none" ){
            Channel
                .fromPath(params.selscan_map)
                .splitCsv(sep:",")
                .map{ chrom, recombmap -> if(!file(recombmap).exists() ){ exit 1, 'ERROR: input recomb file does not exist  \
                    -> ${recombmap}' }else{tuple(chrom, file(recombmap))} }
                .set{ n1_chrom_recombmap }
        }
        else{
                n1_chrom_recombmap = PREPARE_MAP_SELSCAN( p_chrom_vcf_map_isc )
        }


        // split phased vcf file by pop --> to be used for iHS, XP-EHH, nSL

        //p_chrom_vcf_map = PHASING_GENOTYPE_BEAGLE.out.phased_vcf.combine(f_map)

        SPLIT_VCF_BY_POP(
            p_chrom_vcf_map_isc
        )

        // make pairwise tuple of splitted (based on pop id) phased vcf files 

        p_chrom_vcf = SPLIT_VCF_BY_POP.out.pop_phased_vcf.flatten().map{ p_vcf -> tuple( p_vcf.baseName.split("__")[0], p_vcf) }
        
        chrom_tvcf_rvcf = PREPARE_PAIRWISE_VCF(SPLIT_VCF_BY_POP.out.pop_phased_vcf).unique().map{ p1_vcf, p2_vcf -> tuple( p1_vcf.baseName.split("__")[0], p1_vcf, p2_vcf) }

        

        if( params.ihs ){
                
                n1_p_chrom_vcf_recombmap = p_chrom_vcf.combine(n1_chrom_recombmap, by:0)

                //n1_p_chrom_vcf_recombmap_anc = n1_p_chrom_vcf_recombmap.combine(chrom_anc, by: 0)


                CALC_iHS(
                    n1_p_chrom_vcf_recombmap
                )
                
                
               si = Channel.value('ihs') 
        

                NORM_iHS(
                    CALC_iHS.out.t_pop_ihsout.groupTuple(),
                    si
                )


        }
        if( params.xpehh ){
               chrom_tvcf_rvcf_recombmap = chrom_tvcf_rvcf.combine(n1_chrom_recombmap, by: 0)
               
                CALC_XPEHH(
                    chrom_tvcf_rvcf_recombmap
                )
                
                sx = Channel.value('xpehh') 


                NORM_XPEHH(
                    CALC_XPEHH.out.t_pop_xpehhout.groupTuple(),
                    sx
                )
        }
}
