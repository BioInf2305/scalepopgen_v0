/* 
*subworkflow to estimate pairwise fst between all possible population pairs and generate NJ tree
*/
include { PREPARE_FAMILYID_FILES } from '../modules/prepare_familyid_files'
include { EST_PAIRWISE_FST } from '../modules/est_pairwise_fst'
include { MAKE_NJ_TREE } from '../modules/make_nj_tree'


def PREPARE_DIFFPOP_T( fileListPop ){

        file1 = fileListPop.flatten()
        file2 = fileListPop.flatten()
        filePairs = file1.combine(file2)
        filePairsB = filePairs.branch{ file1Path, file2Path ->

            samePop : file1Path == file2Path
                return tuple(file1Path, file2Path).sort()
            diffPop : file1Path != file2Path
                return tuple(file1Path, file2Path).sort()
        
        }
        return filePairsB.diffPop

}

workflow RUN_PAIRWISE_FST{
    take:
        vcf
	id
    main:
        prepare_familyid_files_out       = PREPARE_FAMILYID_FILES(id).toList()
        pairwise_familyid_files          = PREPARE_DIFFPOP_T( prepare_familyid_files_out ).unique()
        vcf_pairwise_familyid_files      = pairwise_familyid_files.combine(vcf)
        est_pairwise_fst_out             = EST_PAIRWISE_FST(vcf_pairwise_familyid_files).collect()
        MAKE_NJ_TREE(est_pairwise_fst_out)
}
