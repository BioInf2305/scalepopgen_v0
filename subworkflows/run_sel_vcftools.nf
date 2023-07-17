/* 
* workflow to carry out signature of selection ( unphased data )
*/

include { SPLIT_IDFILE_BY_POP as SPLIT_MAP_FOR_VCFTOOLS } from '../modules/selection/split_idfile_by_pop'
include { CONCAT_VCF } from '../modules/vcftools/concat_vcf'
include { CALC_TAJIMA_D } from '../modules/vcftools/calc_tajima_d'
include { CALC_PI } from '../modules/vcftools/calc_pi'
include { CALC_WFST } from '../modules/vcftools/calc_wfst'
include { CALC_WFST_ONE_VS_REMAINING } from '../modules/vcftools/calc_wfst_one_vs_remaining'


/* to do 
*FWH --> always require outgroup
*/



def PREPARE_DIFFPOP_T( file_list_pop ){

        file1 = file_list_pop.flatten()
        file2 = file_list_pop.flatten()
        file_pairs = file1.combine(file2)
        file_pairsB = file_pairs.branch{ file1_path, file2_path ->

            samePop : file1_path == file2_path
                return tuple(file1_path, file2_path).sort()
            diffPop : file1_path != file2_path
                return tuple(file1_path, file2_path).sort()
        
        }
        return file_pairsB.diffPop

}



workflow RUN_SEL_VCFTOOLS{
    take:
        chrom_vcf_idx_map

    main:

        // sample map file should be processed separately to split id pop-wise

        map_f = chrom_vcf_idx_map.map{ chrom, vcf, idx, mp -> mp}.unique()

        n3_chrom_vcf = chrom_vcf_idx_map.map{ chrom, vcf, idx, map -> tuple(chrom, vcf) }

        //following module split the map file pop-wise

        SPLIT_MAP_FOR_VCFTOOLS(
            map_f
        )

        pop_idfile = SPLIT_MAP_FOR_VCFTOOLS.out.splitted_samples.flatten()


        n4_chrom_vcf = n3_chrom_vcf

        /*
        
        if( params.skip_chrmwise ){
            n4_chrom_vcf = n3_chrom_vcf
            }
        else{
            CONCAT_VCF(
                n3_chrom_vcf.map{ chrom, vcf -> vcf}.collect()
            )
            n4_chrom_vcf = CONCAT_VCF.out.concatenatedvcf
        }
        */

        //each sample id file should be combine with each vcf file

        n4_chrom_vcf_popid = n4_chrom_vcf.combine(pop_idfile)

        //following module calculates tajima's d for each chromosome for each pop

        if( params.tajima_d ){

            CALC_TAJIMA_D( n4_chrom_vcf_popid )
        
        }

        // following module calculates pi for each chromosome for each pop

        if ( params.pi ){

            CALC_PI( n4_chrom_vcf_popid )

        }

        
        if ( params.pairwise_fst ){
               
                // prepare channel for the pairwise fst                


            pop_idfile_collect = pop_idfile.collect()
            
            //SPLIT_MAP_FOR_VCFTOOLS.out.splitted_samples.view()

            //pop_idfile_collect.view()

            pop1_pop2 = PREPARE_DIFFPOP_T(pop_idfile_collect).unique()


             n4_chrom_vcf_pop1_pop2 = n4_chrom_vcf.combine(pop1_pop2)

                //following module calculates pairwise weir fst for all pairwise combination of pop
            
               //CALC_WFST( n4_chrom_vcf_pop1_pop2 ).pairwise_fst_out.groupTuple().view()
        }
        if( params.single_vs_all_fst ){
                
                pop1_allsample = pop_idfile.combine(SPLIT_MAP_FOR_VCFTOOLS.out.iss)

                n4_chrom_vcf_pop1_allsample = n4_chrom_vcf.combine(pop1_allsample)

                CALC_WFST_ONE_VS_REMAINING(n4_chrom_vcf_pop1_allsample)

                //n4_chrom_vcf_pop1_allsample.view()


            }
}
