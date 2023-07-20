process PREPARE_NEW_MAP{

    tag { "preparing_new_map" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.2"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/", mode:"copy")

    input:
        path(map_f)
        path(unrel_id)

    output:
        path("new_sample_pop.map"), emit: n_map
        
    
    script:
        def rem_indi = params.rem_indi

        if ( (params.mind >= 0 || params.king_cutoff >= 0 ) && rem_indi != "none" ){

        """
        awk 'NR==FNR{sample_id[\$2];next}!(\$1 in sample_id){print \$1} ${rem_indi} ${unrel_id} > final_kept_indi_list.txt

        awk 'NR==FNR{sample_id[\$1];next}\$1 in sample_id{print}' final_kept_indi_list ${map_f} > new_sample_pop.map

        """ 

        }
        
        else{
            
            if ( (params.mind >= 0 || params.king_cutoff >= 0 ) && rem_indi == "none" ){
                
            """

                awk 'NR==FNR{sample_id[\$1];next}\$1 in sample_id{print}' ${unrel_id} ${map_f} > new_sample_pop.map


            """        
            
            }

            else{
            
            """

            awk 'NR==FNR{sample[\$1];next}!(\$1 in a){print \$1}' ${rem_indi} ${f_map} > new_sample_pop.map

            """
            }
        }
}
