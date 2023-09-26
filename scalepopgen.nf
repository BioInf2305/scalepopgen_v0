#!/usr/bin/env nextflow

nextflow.enable.dsl=2


/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULES
//

include { FILTER_SNPS_FROM_BED } from "${baseDir}/modules/plink/filter_snps_from_bed"

include { PLOT_GEO_MAP } from "${baseDir}/modules/plot_geo_map"

include { PRINT_GENERAL_OPTIONS } from "${baseDir}/modules/help/print_general_options"

include { PRINT_FILTERING_OPTIONS } from "${baseDir}/modules/help/print_filtering_options"

include { PRINT_GENSTRUCT_OPTIONS } from "${baseDir}/modules/help/print_genstruct_options"

include { PRINT_TREEMIX_OPTIONS } from "${baseDir}/modules/help/print_treemix_options"

include { PRINT_SIG_SEL_OPTIONS } from "${baseDir}/modules/help/print_sig_sel_options"

include { EXTRACT_UNRELATED_SAMPLE_LIST } from "${baseDir}/modules/plink/extract_unrelated_sample_list"

include { KEEP_INDI } from "${baseDir}/modules/vcftools/keep_indi"

include { REMOVE_INDI } from "${baseDir}/modules/vcftools/remove_indi"

include { FILTER_SITES } from "${baseDir}/modules/vcftools/filter_sites"

include { PREPARE_NEW_MAP } from "${baseDir}/modules/prepare_new_map"

include { CONCAT_VCF } from "${baseDir}/modules/vcftools/concat_vcf"

include { GENERATE_POP_COLOR_MAP } from "${baseDir}/modules/generate_pop_color_map.nf"


//
// SUBWORKFLOW: Consisting of a mix of local modules
//

include { CHECK_INPUT } from "${baseDir}/subworkflows/check_input"

include { PREPARE_INDIV_REPORT } from "${baseDir}/subworkflows/prepare_indiv_report"

include { EXPLORE_GENETIC_STRUCTURE } from "${baseDir}/subworkflows/explore_genetic_structure"

include { CONVERT_VCF_TO_PLINK as CONVERT_FILTERED_VCF_TO_PLINK } from "${baseDir}/subworkflows/convert_vcf_to_plink"

include { RUN_TREEMIX } from "${baseDir}/subworkflows/run_treemix"

include { CONVERT_BED_TO_SPLITTED_VCF } from "${baseDir}/subworkflows/convert_bed_to_splitted_vcf"

include { RUN_SEL_VCFTOOLS } from "${baseDir}/subworkflows/run_sel_vcftools"

include { PREPARE_ANC_FILES } from "${baseDir}/subworkflows/prepare_anc_files"

include { RUN_SEL_SWEEPFINDER2 } from "${baseDir}/subworkflows/run_sel_sweepfinder2"

include { RUN_SIG_SEL_PHASED_DATA } from "${baseDir}/subworkflows/run_sig_sel_phased_data"



workflow{


    if( params.help ){
            if ( params.indi_snp_filters ){
                PRINT_FILTERING_OPTIONS()
                exit 0
            }
            if ( params.gen_struct ){
                PRINT_GENSTRUCT_OPTIONS()
                exit 0
            }
            if ( params.phylogeny ){
                PRINT_TREEMIX_OPTIONS()
                exit 0
            }
            if ( params.signature_selection ){
                PRINT_SIG_SEL_OPTIONS()
                exit 0
            }
            else{
                PRINT_GENERAL_OPTIONS()
                exit 0
            }
        }

    else{

    // first check if the input parameter contains ".csv"
    //  yes --> input is vcf and sample map files is required
    //  no --> input is assumed to be plink bed file 


    if( params.input.endsWith(".csv") ){
        
        // check input vcfsheet i.e. if vcf file exits //
    	
        CHECK_INPUT(
            params.input
        )

        samplesheet = Channel.fromPath( params.sample_map )
        map_file = samplesheet.map{ samplesheet -> if(!file(samplesheet).exists() ){ exit 1, "ERROR: file does not exit or sample map does not end with .map -> ${samplesheet}" }else{samplesheet} }

    
        // combine channel for vcf and sample map file //

        chrom_vcf_idx_map = CHECK_INPUT.out.chrom_vcf_idx.combine(map_file)
        is_vcf = true

    }
    else{

        prefix_bed = Channel.fromFilePairs(params.input, size:3)
        is_vcf = false

    }

    GENERATE_POP_COLOR_MAP(
        is_vcf ? chrom_vcf_idx_map.map{chrom, vcf, idx, map_f -> map_f}.unique() : prefix_bed.map{prefix,bed -> bed[2]}
    )
    

    if ( is_vcf ){
        if( params.apply_indi_filters ){
        
            o_map = chrom_vcf_idx_map.map{chrom, vcf, idx, map_f -> map_f}.unique()

            /* --> king_cutoff and missingness filter should be based on the entire genome therefore vcf file should be concatenated first and then 
                   supply to plink. From plink module, the list of individuals to be kept is piped out and supply to keep indi module. This module will
                   then extract these sets of individuals from each chromosome file separately. Note that if custom individuals to be removed are also
                    supplied then this will be considered in extract_unrelated_sample_list module as well. 
            */      
    
            if( params.king_cutoff > 0 || params.mind > 0 ){


                vcflist = chrom_vcf_idx_map.map{chrom, vcf, idx, map_f -> vcf}.collect()

                CONCAT_VCF(vcflist)

                EXTRACT_UNRELATED_SAMPLE_LIST( CONCAT_VCF.out.concatenatedvcf )
        
                KEEP_INDI( chrom_vcf_idx_map.combine( EXTRACT_UNRELATED_SAMPLE_LIST.out.keep_indi_list ))

                PREPARE_NEW_MAP(
                    o_map,
                    EXTRACT_UNRELATED_SAMPLE_LIST.out.keep_indi_list
                )
            
                n0_chrom_vcf_idx_map = KEEP_INDI.out.f_chrom_vcf_idx.combine(PREPARE_NEW_MAP.out.n_map)
            }

            /*
                if only the individuals to be removed are supplied then there is no need to concat the file. 
            
            */

            else{
                rmindilist = Channel.fromPath( params.rem_indi )
            ril = rmindilist.map{ rmindilist -> if(!file(rmindilist).exists() ){ exit 1,"ERROR: file does not exit -> ${rmindilist}" }else{rmindilist} }
                chrom_vcf = chrom_vcf_idx_map.map{chrom, vcf, idx, map -> tuple(chrom,vcf)}
                REMOVE_INDI( chrom_vcf )
                PREPARE_NEW_MAP(
                    o_map,
                    ril
                )
                n0_chrom_vcf_idx_map = REMOVE_INDI.out.f_chrom_vcf_idx.combine(PREPARE_NEW_MAP.out.n_map)
            }
        }
        else{
            n0_chrom_vcf_idx_map = chrom_vcf_idx_map
        }
        if ( params.apply_snp_filters ){

                n_map = n0_chrom_vcf_idx_map.map{chrom, vcf, idx, map_f -> map_f}.unique()

                chrom_vcf = n0_chrom_vcf_idx_map.map{chrom, vcf, idx, map_f -> tuple(chrom, vcf)}    
                
                
                FILTER_SITES(chrom_vcf)
        
                n1_chrom_vcf_idx_map = FILTER_SITES.out.s_chrom_vcf_tbi.combine(n_map)
                    
        }
        else{
                n1_chrom_vcf_idx_map = n0_chrom_vcf_idx_map
        }
        if( params.indiv_summary ){
            PREPARE_INDIV_REPORT( n1_chrom_vcf_idx_map )
        }
        
    } 
    // else input is bed:
    //  indi filtering and sites filtering --> use plink

    else{
        if( params.apply_indi_filters ){
            
            //f_bed = prefix_bed.map{ prefix, bed -> bed }

            EXTRACT_UNRELATED_SAMPLE_LIST( prefix_bed )

            n2_bed = EXTRACT_UNRELATED_SAMPLE_LIST.out.indi_filt_bed
            
        }
        else{
            n2_bed = prefix_bed.map{ prefix, bed -> bed }
        }
        if( params.apply_snp_filters ){
        
            FILTER_SNPS_FROM_BED( n2_bed )

            n3_bed = FILTER_SNPS_FROM_BED.out.filt_sites_bed

        }
        else{
            
            n3_bed = n2_bed

        }
        if (params.treemix || params.sig_sel) {
            CONVERT_BED_TO_SPLITTED_VCF( n3_bed )
            n1_chrom_vcf_idx_map = CONVERT_BED_TO_SPLITTED_VCF.out.p2_chrom_vcf_idx_map    
        }
    }

        //plot samples on world map
        
    if( params.geo_plot_yml != "none" && params.tile_yml != "none" && params.f_pop_cord != "none" ){

        geo_yml = Channel.fromPath(params.geo_plot_yml)
        tile_yml = Channel.fromPath(params.tile_yml)

        PLOT_GEO_MAP(
            geo_yml,
            tile_yml,
            GENERATE_POP_COLOR_MAP.out.m_pop_sc_colr
        )
    }
    
    // in case of pca and admixture, convert filtered vcf to bed (if input is vcf)
    // the main rationale is that all plink dependent analysis should be covered in this "if" block

    
    if ( params.genetic_structure ) {


        if( is_vcf ){
            CONVERT_FILTERED_VCF_TO_PLINK(
                n1_chrom_vcf_idx_map
            )
            n4_bed = CONVERT_FILTERED_VCF_TO_PLINK.out.bed
        }
        else{
            n4_bed = n3_bed
            }
        EXPLORE_GENETIC_STRUCTURE(
            n4_bed,
            GENERATE_POP_COLOR_MAP.out.m_pop_sc_colr
        )
    }
    
    if( params.treemix ){
            RUN_TREEMIX( n1_chrom_vcf_idx_map )
        }
    if( params.sig_sel ){


        if( params.tajimas_d || params.pi || params.pairwise_fst || params.single_vs_all_fst ){
                RUN_SEL_VCFTOOLS( n1_chrom_vcf_idx_map )
            }

        if( params.clr || params.ihs || params.xpehh ){
                

                if( params.clr ){
                        PREPARE_ANC_FILES( n1_chrom_vcf_idx_map )
                        RUN_SEL_SWEEPFINDER2( PREPARE_ANC_FILES.out.n2_chrom_vcf_idx_map_anc )
                }
                if ( params.ihs || params.xpehh ) {
                        RUN_SIG_SEL_PHASED_DATA( n1_chrom_vcf_idx_map )
                }
        }

    }
    }
}
