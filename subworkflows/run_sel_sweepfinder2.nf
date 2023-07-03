/* 
* workflow to carry out signature of selection using sweepfinder2
*/

include { SPLIT_IDFILE_BY_POP as SPLIT_FOR_SWEEPFINDER2 } from '../modules/selection/split_idfile_by_pop'
include { PREPARE_SWEEPFINDER_INPUT } from '../modules/selection/prepare_sweepfinder_input'
include { COMPUTE_EMPIRICAL_AFS } from '../modules/selection/compute_empirical_afs'
include { RUN_SWEEPFINDER2 } from '../modules/selection/run_sweepfinder2'


workflow RUN_SEL_SWEEPFINDER2{
    take:
        chrom_vcf_idx_map

    main:

        // sample map file should be processed separately to split id pop-wise

        map_f = chrom_vcf_idx_map.map{ chrom, vcf, idx, mp -> mp}.unique()

        n3_chrom_vcf = chrom_vcf_idx_map.map{ chrom, vcf, idx, map -> tuple(chrom, vcf) }

        //following module split the map file pop-wise

        SPLIT_FOR_SWEEPFINDER2(
            map_f
        )

        pop_idfile = SPLIT_FOR_SWEEPFINDER2.out.splitted_samples.flatten()

        //each sample id file should be combine with each vcf file

        n3_chrom_vcf_popid = n3_chrom_vcf.combine(pop_idfile)

        
            // read file containing paths to the ancestral allele files                

        if(params.anc_files != "none" ){
            Channel
                .fromPath(params.anc_files)
                .splitCsv(sep:",")
                .map{ chrom, anc -> if(!file(anc).exists() ){ exit 1, 'ERROR: input anc file does not exist  \
                    -> ${anc}' }else{tuple(chrom, file(anc))} }
                .set{ chrom_anc }
            n4_chrom_vcf_popid_anc = n3_chrom_vcf_popid.combine(chrom_anc, by:0)
        }
        else{
            n4_chrom_vcf_popid_anc = n3_chrom_vcf_popid.combine(["none"])
        }
        
        n5_chrom_vcf_popid_anc = n4_chrom_vcf_popid_anc.map{ chrom, vcf, popid, anc ->tuple( chrom, vcf, popid, anc == "none" ? []: anc)}    

        // prepare sweepfinder input files --> freq file and recomb file

        PREPARE_SWEEPFINDER_INPUT(
            n5_chrom_vcf_popid_anc
        )

        // group freq files and recomb files based on "pop" key

        pop_freq_M = PREPARE_SWEEPFINDER_INPUT.out.pop_freq.groupTuple()
        
        freq = pop_freq_M.map{pop, freq -> tuple(freq)}
        
        base_freq = freq.flatten().map{freqF -> tuple(freqF.baseName, freqF ) }

        pop_recomb_M = PREPARE_SWEEPFINDER_INPUT.out.pop_recomb.groupTuple()


        /// combine freq and recomb file based on user-set parameters

        if( params.use_recomb_map == "default" ){

            //first using "baseName" as key group the freq and recomb files

            recomb = pop_recomb_M.map{pop, recomb -> tuple(recomb) }

            base_recomb = recomb.flatten().map{ recombF -> tuple(recombF.baseName, recombF ) }

            base_freq_recomb = base_freq.combine( base_recomb, by:0)

        }

        if ( params.use_recomb_map != "default" && params.use_recomb_map != "none" ){
            Channel
                    .fromPath( params.use_recomb_map )
                    .splitCsv(sep:",")
                    .map{ chrom, recomb -> if(!file(recomb).exists() ){ exit 1, 'ERROR: input recomb file does not exist  \
                        -> ${recomb}' }else{tuple(chrom, file(recomb))} }
                    .set{ chrom_recomb }
                
            pop_id = pop_freq_M.map{pop, freq -> tuple(pop)}.unique()

            chrom_recomb_pop = chrom_recomb.combine(pop_id)

            f_base_recomb = chrom_recomb_pop.map{ chrom, recomb, popid -> tuple(chrom+"__"+popid, recomb) }

            base_freq_recomb = base_freq.combine(f_base_recomb, by:0)

        }
        
        if( params.use_recomb_map == "none" ){
            
            base_freq_recomb = base_freq.combine(["none"])
            
        }
        
        // compute genome-wide allele frequency spectrum, aka, "helper file" for each pop
        
        if( params.use_precomputed_afs ){
            COMPUTE_EMPIRICAL_AFS(
                pop_freq_M
            )
            //next, by splitting the "baseName" using "__" as delimiter,\
            // combine freq_recomb and afs files; "chrom" id and "pop" id should not contain "__"

            pop_freq_recomb = base_freq_recomb.map{ base, freq, recomb -> tuple(base.split("__")[1], freq, recomb)}

            pop_freq_recomb_afs = pop_freq_recomb.combine(COMPUTE_EMPIRICAL_AFS.out.pop_afs, by:0)
        }
        
        else{
                pop_freq_recomb = base_freq_recomb.map{ base, freq, recomb -> tuple(base.split("__")[1], freq, recomb)}
                
                pop_freq_recomb_afs = pop_freq_recomb.combine(["none"])
            }
        n1_pop_freq_recomb_afs = pop_freq_recomb_afs.map{ pop, freq, recomb, afs -> tuple(pop, freq, \
            recomb == "none" ? [] : recomb, afs == "none" ? [] : afs ) }
        RUN_SWEEPFINDER2(
            n1_pop_freq_recomb_afs
        )
}
