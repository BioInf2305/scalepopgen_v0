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

//
// SUBWORKFLOW: Consisting of a mix of local modules
//

include { CHECK_INPUT } from "${baseDir}/subworkflows/check_input"

include { PREPARE_KEEP_INDI_LIST  } from "${baseDir}/subworkflows/prepare_keep_indi_list"

include { FILTER_VCF } from "${baseDir}/subworkflows/filter_vcf"

include { EXPLORE_GENETIC_STRUCTURE } from "${baseDir}/subworkflows/explore_genetic_structure"

include { CONVERT_VCF_TO_PLINK } from "${baseDir}/subworkflows/convert_vcf_to_plink"

include { CONVERT_VCF_TO_PLINK as CONVERT_FILTERED_VCF_TO_PLINK } from "${baseDir}/subworkflows/convert_vcf_to_plink"

include { RUN_TREEMIX } from "${baseDir}/subworkflows/run_treemix"

include { CONVERT_BED_TO_SPLITTED_VCF } from "${baseDir}/subworkflows/convert_bed_to_splitted_vcf"

include { RUN_SEL_VCFTOOLS } from "${baseDir}/subworkflows/run_sel_vcftools"

include { PREPARE_ANC_FILES } from "${baseDir}/subworkflows/prepare_anc_files"

include { RUN_SEL_SWEEPFINDER2 } from "${baseDir}/subworkflows/run_sel_sweepfinder2"

include { RUN_SIG_SEL_PHASED_DATA } from "${baseDir}/subworkflows/run_sig_sel_phased_data"



workflow{


    if( params.help ){
            if ( params.apply_snp_filters || params.apply_indi_filters ){
                PRINT_FILTERING_OPTIONS()
                exit 0
            }
            if ( params.genetic_structure ){
                PRINT_GENSTRUCT_OPTIONS()
                exit 0
            }
            else{
                PRINT_GENERAL_OPTIONS()
                exit 0
            }
        }

    // first check if the input parameter contains ".csv"
    //  yes --> input is vcf and sample map files is required
    //  no --> input is assumed to be plink bed file 

    if( params.geo_plot_yml != "none" && params.tile_yml != "none" ){

        geo_yml = Channel.fromPath(params.geo_plot_yml)
        tile_yml = Channel.fromPath(params.tile_yml)

        PLOT_GEO_MAP(
            geo_yml,
            tile_yml
        )

    }

    if( params.input.endsWith(".csv") ) {
        
        // check input vcfsheet i.e. if vcf file exits //
    	
        CHECK_INPUT(
            params.input
        )

        // check sample map file i.e. if map file exists //

        samplesheet = Channel.fromPath( params.sample_map )
        map_file = samplesheet.map{ samplesheet -> if(!file(samplesheet).exists()){ exit 1, "ERROR: file does not exit \
                -> ${samplesheet}" }else{samplesheet} }
    
        // combine channel for vcf and sample map file //

        chrom_vcf_idx_map = CHECK_INPUT.out.chrom_vcf_idx.combine(map_file)
        is_vcf = true
        

    }
    else{

        prefix_bed = Channel.fromFilePairs(params.input, size:3)
        is_vcf = false

    }
    
    // in case of filtering the order is, first indi_filtering then sites_filtering
    // if input is vcf:
    //  indi filtering --> use plink to filter samples 
    //  sites filtering --> use vcftools to filter sites

    if ( is_vcf ){

        if( params.apply_indi_filters ){

            CONVERT_VCF_TO_PLINK( chrom_vcf_idx_map )

            PREPARE_KEEP_INDI_LIST( CONVERT_VCF_TO_PLINK.out.bed )

            chrom_vcf_idx = chrom_vcf_idx_map.map{chrom, vcf, idx, map -> tuple(chrom, vcf, idx)}

            n1_chrom_vcf_idx_map = chrom_vcf_idx.combine(PREPARE_KEEP_INDI_LIST.out.new_map)

        }
        
        else{
            n1_chrom_vcf_idx_map = chrom_vcf_idx_map
        }
        
        // prepare input channel for filter vcf    

        chrom_vcf_idx_map_indilist = n1_chrom_vcf_idx_map.combine( params.apply_indi_filters ? PREPARE_KEEP_INDI_LIST.out.indi_list : ["none"])
        
        FILTER_VCF(
          chrom_vcf_idx_map_indilist
        )

        n3_chrom_vcf_idx_map = FILTER_VCF.out.n2_chrom_vcf_idx_map 
    }

    // else input is bed:
    //  indi filtering and sites filtering --> use plink

    else{
        if( params.apply_indi_filters ){
            
            f_bed = prefix_bed.map{ prefix, bed -> bed }

            PREPARE_KEEP_INDI_LIST( f_bed )

            n2_bed = PREPARE_KEEP_INDI_LIST.out.n1_bed
            
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
            n3_chrom_vcf_idx_map = CONVERT_BED_TO_SPLITTED_VCF.out.p2_chrom_vcf_idx_map    
        }
    }
    
    // in case of pca and admixture, convert filtered vcf to bed (if input is vcf)
    // the main rationale is that all plink dependent analysis should be covered in this "if" block
    
    if ( params.genetic_structure ) {

        if( is_vcf ){
            CONVERT_FILTERED_VCF_TO_PLINK(
                n3_chrom_vcf_idx_map
            )
            n4_bed = CONVERT_FILTERED_VCF_TO_PLINK.out.bed
        }
        else{
            n4_bed = n3_bed
            }
        EXPLORE_GENETIC_STRUCTURE(
            n4_bed
        )
    }
    
    if( params.treemix ){
            RUN_TREEMIX( n3_chrom_vcf_idx_map )
        }

    if( params.sig_sel ){

        if( params.tajima_d || params.pi || params.pairwise_fst || params.single_vs_all_fst ){
                RUN_SEL_VCFTOOLS( n3_chrom_vcf_idx_map )
            }

        if( params.clr || params.ihs || params.xpehh ){
                
                PREPARE_ANC_FILES( n3_chrom_vcf_idx_map )

                if( params.clr ){
                        RUN_SEL_SWEEPFINDER2( PREPARE_ANC_FILES.out.n2_chrom_vcf_idx_map_anc )
                }
                if ( params.ihs || params.xpehh ) {
                        RUN_SIG_SEL_PHASED_DATA( PREPARE_ANC_FILES.out.n2_chrom_vcf_idx_map_anc )
                }
        }

    }
}
