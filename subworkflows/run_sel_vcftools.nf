/* 
* workflow to carry out signature of selection ( unphased data )
*/

include { SPLIT_IDFILE_BY_POP as SPLIT_MAP_FOR_VCFTOOLS } from '../modules/selection/split_idfile_by_pop'
include { CONCAT_VCF } from '../modules/vcftools/concat_vcf'
include { CALC_TAJIMA_D } from '../modules/vcftools/calc_tajima_d'
include { CALC_PI } from '../modules/vcftools/calc_pi'
include { CALC_WFST } from '../modules/vcftools/calc_wfst'
include { CALC_WFST_ONE_VS_REMAINING } from '../modules/vcftools/calc_wfst_one_vs_remaining'
include { GENERATE_INTERACTIVE_MANHATTAN_PLOT as MANHATTAN_TAJIMAS_D } from '../modules/selection/generate_interactive_manhattan_plot'
include { GENERATE_INTERACTIVE_MANHATTAN_PLOT as MANHATTAN_PI } from '../modules/selection/generate_interactive_manhattan_plot'
include { GENERATE_INTERACTIVE_MANHATTAN_PLOT as MANHATTAN_FST } from '../modules/selection/generate_interactive_manhattan_plot'


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
        
        type_analysis = Channel.value('vcftools')

        SPLIT_MAP_FOR_VCFTOOLS(
            map_f,
            type_analysis
        )

        pop_idfile = SPLIT_MAP_FOR_VCFTOOLS.out.splitted_samples.flatten()

        
        if( params.input.endsWith(".csv") ){
            if( params.skip_chrmwise ){
                CONCAT_VCF(
                    n3_chrom_vcf.map{chrom, vcf -> vcf}.collect()
                )
                n4_chrom_vcf = CONCAT_VCF.out.concatenatedvcf
            }
            else{
                n4_chrom_vcf = n3_chrom_vcf
            }
        }
        else{
            n4_chrom_vcf = n3_chrom_vcf
        }

        //each sample id file should be combine with each vcf file

        n4_chrom_vcf_popid = n4_chrom_vcf.combine(pop_idfile)

        //following module calculates tajima's d for each chromosome for each pop
        

        if( params.tajimas_d ){

            CALC_TAJIMA_D( n4_chrom_vcf_popid )

            v1_manhatin = Channel.value('tajimas_d')

            v1_windowsize = Channel.value(params.tajimasd_window_size)

            MANHATTAN_TAJIMAS_D(
                 CALC_TAJIMA_D.out.tajimasd_out.groupTuple(),
                 v1_manhatin,
                 v1_windowsize
                )
        
        }

        // following module calculates pi for each chromosome for each pop

        if ( params.pi ){

            CALC_PI( n4_chrom_vcf_popid )

            v2_manhatin = Channel.value('nucl_diversity_pi')

            v2_windowsize = params.pi_window_size > 0 ? Channel.value(params.pi_window_size) : Channel.value(1)

            MANHATTAN_PI(
                CALC_PI.out.pi_out.groupTuple(),
                v2_manhatin,
                v2_windowsize
            )
        }

        
        if ( params.pairwise_fst ){
               
                // prepare channel for the pairwise fst                


            pop_idfile_collect = pop_idfile.collect()
            

            pop1_pop2 = PREPARE_DIFFPOP_T(pop_idfile_collect).unique()


             n4_chrom_vcf_pop1_pop2 = n4_chrom_vcf.combine(pop1_pop2)
            
            CALC_WFST( n4_chrom_vcf_pop1_pop2 )
            
        }
        if( params.single_vs_all_fst ){
                
                pop1_allsample = pop_idfile.combine(SPLIT_MAP_FOR_VCFTOOLS.out.iss)

                n4_chrom_vcf_pop1_allsample = n4_chrom_vcf.combine(pop1_allsample)

                CALC_WFST_ONE_VS_REMAINING(n4_chrom_vcf_pop1_allsample)
            
                v3_manhatin = Channel.value('fst_values')

                v3_windowsize = params.fst_window_size > 0 ? Channel.value(params.fst_window_size) : Channel.value(1)

                MANHATTAN_FST(
                    CALC_WFST_ONE_VS_REMAINING.out.pairwise_fst_out.groupTuple(),
                    v3_manhatin,
                    v3_windowsize
                )

            }
}
