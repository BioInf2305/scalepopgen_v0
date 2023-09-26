## scalepopgen: sample and site filtering, vcf statistics, plotting samples' location on geographical map
The workflow incorporates plink2 (v 2.00a3.7) and vcftools (v 0.1.16) to carry out sample and site filtering. This can be carried out with the argument ```apply_indi_filters = true```, and ```apply_snp_filters = true```. The filtering process depends on the format of the input files. If the input is plink binary file then both the processes, sample and site filtering,  will be done using [PLINK](https://www.cog-genomics.org/plink/2.0/), if the provided inputs are vcf files, then along with plink2 [VCFtools](https://vcftools.github.io/index.html) will also be used. 

Options for sample filtering:
 - removing samples according to the threshold of calculated kinship coefficient  
 - removing samples according to the amount of missing genotypes
 - removing user-defined samples

The site filtering options depend on the input format as mentioned before. For the VCF input all listed options are available, while in the case of PLINK binary files the workflow considers only the first four options:
 - filtering based on minor allele frequency threshold
 - filtering according to the Hardy-Weinberg equilibrium exact test
 - filtering SNPs according to the amount of missing information 
 - removing user-defined SNPs
 - filtering SNPs based on min and max average depths
 - filtering SNPs based on quality score threshold

## Description of the parameters:
```king_cutoff```: samples with relationship coefficient greater than this will be removed \
```rem_indi```:  the name of text file containing individuals to be removed \
```mind```: samples with missing genotypes greater than the threshold selected here will be removed \
```indiv_summary```: if set to true it will calculate sample-based summary statistics from VCF files, after individual- and site-based filtering \
```remove_snps```: the name of text file containing names of SNPs that will be removed \
```maf```: SNPs with minor allele frequencies less than the threshold specified here will be removed \
```min_meanDP```: SNPs with average depth (across the samples) less than the threshold specified here will be removed (only for the VCF inputs) \
```max_meanDP```: SNPs with average depth (across the samples) greater than the threshold specified here will be removed (only for the VCF inputs) \
```hwe```: SNPs with HWE p-values of less than the threshold specified here will be removed \
```max_missing```: SNPs, for which the proportion of missing genotypes exceeded this threshold, will be removed \
```minQ```: SNPs with base quality less than specified here will be removed (only for the VCF inputs) 

## Overview of the filtering processes:
First, samples filtering will be carried out followed by site filtering. In case of vcf input, the processes run as follows
1) input vcf files are concatenated using vcf_concat of vcftools
2) concatenated vcf file is supplied to plink2 to get the list of individuals that satisfy the missing genotypes and kinship coefficient threshold
3) using vcftools, the new vcf files are created keeping the individuals from the step 2
4) new sample map file is also created keeping the individuals from the step 2
5) vcftool is used to filter the sites based on the user-defined options

> **Note:** In order to optimize the workflow, if only the list of individuals to be removed is supplied and the other two options of sample filtering are disabled (```--king_cutoff 0``` and ```--mind 0```), then steps 1, 2 and 3 will not be carried out, instead vcftools will be directly used to remove these samples. In case of plink binary input, plink2 is first used to filter samples followed by sites filtering. 

## Validation and test-run of the sub-workflow:
For workflow validation, we have downloaded publicly available samples (see map below) with whole genome sequences from NCBI database (Alberto et al., 2018; Grossen et al., 2020; Henkel et al., 2019). We included domestic goats (*Capra hircus*) represented by various breeds from Switzerland. In addition to them, we also included Alpine ibex (*C. ibex*) and Bezoar wild goat (*C. aegagrus*). Since we need an outgroup when performing some of the analyses, we also added Urial sheep (*Ovis vignei*). We will use variants from chromosome 28 and 29 of, all together, 85 animals.

![plot](../../images/Sample_info.png)
Geographic map of samples used for the testing and validation purpose

 <font size="2">Alberto et al. (2018). Convergent genomic signatures of domestication in sheep and goats. *Nature communications*, https://doi.org/10.1038/s41467-018-03206-y \
Grossen et al. (2020). Purging of highly deleterious mutations through severe bottlenecks in Alpine ibex. *Nature communications*, https://doi.org/10.1038/s41467-020-14803-1 \
Henkel et al. (2019). Selection signatures in goats reveal copy number variants underlying breed-defining coat color phenotypes. *PLoS genetics*, https://doi.org/10.1371/journal.pgen.1008536
 </font>

### 1. Required input data files
The input data should be in the **VCF** or **PLINK binary** format files. 

All VCF files need to be splitted by the chromosomes and indexed with tabix. Please check */test_files/test_input_vcf.csv* or the example below, where, in our case, we inserted the link to the cloud stored data. The first information in each row of input file is chromosome id, next is path/to/the/file.vcf.gz and the last is path/to/the/file.vcf.gz.tbi. Please note that the chromosome id must not contain any punctuation marks.
```
chr28,https://data.cyverse.org/dav-anon/iplant/home/maulik88/28_filt_samples.vcf.gz,https://data.cyverse.org/dav-anon/iplant/home/maulik88/28_filt_samples.vcf.gz.tbi
chr29,https://data.cyverse.org/dav-anon/iplant/home/maulik88/29_filt_samples.vcf.gz,https://data.cyverse.org/dav-anon/iplant/home/maulik88/29_filt_samples.vcf.gz.tbi
```
In addition to the VCF input format, it is also necessary to prepare a sample map file of individuals and populations. Sample map has two tab-delimited columns: in the first column are individual IDs and in the second are population IDs as demonstrated on the example below. It is also important that the name of the file ends with ".map".
```
SRR8437780ibex	AlpineIbex
SRR8437782ibex	AlpineIbex
SRR8437783ibex	AlpineIbex
SRR8437791ibex	AlpineIbex
SRR8437793ibex	AlpineIbex
SRR8437799ibex	AlpineIbex
SRR8437809ibex	AlpineIbex
SRR8437810ibex	AlpineIbex
SRR8437811ibex	AlpineIbex
SRX5250055_SRR8442974	Appenzell
SRX5250057_SRR8442972	Appenzell
SRX5250124_SRR8442905	Appenzell
SRX5250148_SRR8442881	Appenzell
SRX5250150_SRR8442879	Appenzell
SRX5250151_SRR8442878	Appenzell
SRX5250153_SRR8442876	Appenzell
SRX5250155_SRR8442874	Appenzell
SRX5250156_SRR8442873	Appenzell
SRX5250157_SRR8442872	Appenzell
340330_T1	Bezoar
340331_T1	Bezoar
340334_T1	Bezoar
340340_T1	Bezoar
340345_T1	Bezoar
340347_T1	Bezoar
340426_T1	Bezoar
470100_T1	Bezoar
470104_T1	Bezoar
470106_T1	Bezoar
...
454948_T1	Urial
ERR454947urial	Urial
SRR12396950urial	Urial
```
For the Plink binary input, user need to specify the path to the BED/BIM/FAM files in the section of general parameters:
```input= "path/to/the/files/*.{bed,bim,fam}"```

### 2. Optional input data files
This module enables to remove samples of you choice with option ```rem_indi```. You have to prepare a space/tab-delimited text file with population IDs in the first column and sample IDs in the second column as stated in [PLINK](https://www.cog-genomics.org/plink/2.0/filter#sample) (option --remove) documentation:
```
Grigia SRX7715567_SRR11076301
Grigia SRX7715568_SRR11076300
Grigia SRX7715579_SRR11076289
```
Similarly, you can also prepare a file with the SNPs that should be removed. The appearance of the file depends on the input formats. For the VCF input, we used option ```--exclude-positions``` of [VCFtools](https://vcftools.sourceforge.net/man_latest.html), which expect a text file with a tab-separated chromosome and position of the SNP in each line:
```
NC_030835.1	1460
NC_030835.1	1498
NC_030835.1	2140
NC_030835.1	2158
NC_030835.1	2173
NC_030835.1	44663424
NC_030835.1	44663455
NC_030835.1	44664291
NC_030835.1	44664392
NC_030835.1	44664464
NC_030836.1	1510
NC_030836.1	1525
NC_030836.1	1558
NC_030836.1	1593
NC_030836.1	1595
NC_030836.1	51331074
NC_030836.1	51331096
NC_030836.1	51331185
NC_030836.1	51331237
NC_030836.1	51331522
```
With this tool we also have an option to draw a geographic map with sample origin. For that we need to provide two files. In the first one we write down population ID in the first column and comma separated latitude and longitude in second column. Please check *test_files/geo_data.txt* or the example below:
```Bezoar	32.662864436650814,51.64853259116807
Urial	34.66031157,53.49391737
AlpineIbex	46.48952713,9.832698605
ChamoisColored	46.620927266181674,7.345747305114329
Appenzell	47.33229709563813,9.401363933224248
Booted	47.426361052956736,9.384330852599533
Peacock	46.321661051197026,8.804738507288173
Toggenburg	47.358160245764715,9.01070577172017
Grigia	46.24935612558498,8.700996940189137
Saanen	46.9570926960748,8.205509946726016
```
In the second file, we will specify the hex codes of colors that will represent each population. Please check *test_files/pop_color.txt* or the example below:
```AlpineIbex	#008000
Appenzell	#ff5733
Booted	#0000FF
ChamoisColored	#d6b919
Grigia	#aee716
Peacock	#16e7cc
Saanen	#75baf3
Urial	#A52A2A
Toggenburg	#da4eed
Bezoar	#FFA500
```
The last file is not obligatory as the tool can choose random colors, while the first one with coordinates is necessary for map plotting.

### 3. Setting the parameters
At the beginning, we have to specify some of the general parameters, which can be found in the first tab of GUI (**general_param**): \
```input```: path to the .csv input file for the VCF format or names of the PLINK binary files \
```outDir```: the name of the output folder \
```sample_map```: path to the file with the suffix ".map" that have listed individuals and populations as addition to VCF input \
```concate_vcf_prefix```: file prefix of the genome-wise merged vcf files \
```geo_plot_yml```: path to the yaml file containing parameters for plotting the samples on a map \
```tile_yml```: path to the yaml file containing parameters for the geographical map to be used for plotting \
```f_chrom_len```: path to the file with chromosomes' length for the Plink binary inputs \
```f_pop_cord```: path to the file with geographical locations for map plotting \
```f_pop_color```: path to the file with specified colors for map plotting \
```fasta```: the name of the reference genome fasta file that will be used for converting in case of PLINK input \
```allow_extra_chrom```: set to true if the input contains chromosome name in the form of string \
```max_chrom```: maximum number of chromosomes \
```outgroup```: the population ID of the outgroup \
```cm_to_bp```: the number of base pairs that corresponds to one cM

When we have filled in all the general parameters, we can move to the tab **globalfilt_params** dedicated to site- and sample-based filtering (***/parameters/process/globalfilt_params.config**), where we specify parameters described at the beginning of this documentation. At the end, save the parameters as yml file.

After setting all parameters and exporting them as yml file, we are ready to start the workflow. Choose any profile, we prefer mamba, and set the maximum number of processes, 10 in our case, that can be executed in parallel by each executor. From within the **scalepopgen** folder, execute the following command:
```
nextflow run scalepopgen.nf  -params-file filtering.yml -profile mamba -qs 10
```
You can check all the other command running options with the option help :
```
nextflow run scalepopgen.nf -help
```
After the filtering is done successfully, the command line output is looking like this:
```
N E X T F L O W  ~  version 23.04.1
Launching `scale_popgen.nf` [jolly_stone] DSL2 - revision: c7f30377b6
executor >  slurm (10)
[f3/c7400b] process > GENERATE_POP_COLOR_MAP (generating pop color map)                                  [100%] 1 of 1 ✔
[d9/c1a6d2] process > CONCAT_VCF (concate_vcf)                                                           [100%] 1 of 1 ✔
[53/b7fe9e] process > EXTRACT_UNRELATED_SAMPLE_LIST (filter_indi_goats)                                  [100%] 1 of 1 ✔
[16/35f355] process > KEEP_INDI (keep_indi_CHR29)                                                        [100%] 2 of 2 ✔
[a2/1cb2ab] process > PREPARE_NEW_MAP (preparing_new_map)                                                [100%] 1 of 1 ✔
[61/bd92b1] process > FILTER_SITES (filter_sites_CHR29)                                                  [100%] 2 of 2 ✔
[d3/bb393a] process > PREPARE_INDIV_REPORT:CALC_INDIV_SUMMARY (calculating_chromosomewise_summary_CHR29) [100%] 2 of 2 ✔
[b5/f0c4d1] process > PREPARE_INDIV_REPORT:COMBINE_INDIV_SUMMARY (combining_indiv_summary)               [100%] 1 of 1 ✔
[81/305c0e] process > PLOT_GEO_MAP (plotting_sample_on_map)                                              [100%] 1 of 1 ✔
Completed at: 07-Aug-2023 16:53:44
Duration    : 23m 5s
CPU hours   : 0.3
Succeeded   : 12
```

### 4. Description of the outputs generated by this sub-workflow:
The scheme of output files differs according to the input formats. In the case of VCF input it will look like this:
<img src="../../images/filter_dir.png" alt="folder"></p>

The workflow will start with sample-based filtering. After that it will take the sample-filtered files and perform SNP-based filtering. We can find the final filtered files in the folder **./vcftools/sites_filtered**. Based on the remaining samples this tool will also update the sample map file: **new_sample_pop.map**. In the general parameters we customize fields for plotting the geographic map, which can be found in the output folder as **goats.html**.


If your input is in PLINK format, the filtered files will be stored only in a folder **\${output directory}/plink/**. Similar as with VCF, inside you will find a subfolder **./indi_filtered/**, in which is the same content as specified above. In addition, there is also a subfolder **./sites_filtered/**.

> **Note:** The output folders also contains the  **\*.log** files of the programs PLINK and VCFtools.

### 5. Generating the geographical map without running the workflow
For generating the geographic map of samples (without re-running the workflow), one can either use **geo_map_file.txt** generated by the workflow or prepare a tab-delimited file in the similar format. Run the python script with the following command: 
```
python3 plot_sample_info.py geo_map_file.txt plot_sample_on_map.yml tiles_info.yml
```

The python script is located in the bin folder of scalepopgen. The yaml files are located in the folder "/parameters/plots/". The parameters of the yaml files are described below:
```
tile: the name of the tiles to be used for plotting. Default: "world_gray_canvas". Note that the attributes of this tile should be present in tiles_info.yml 
marker_prop: in case you want to plot the area of the circle proportional to the sample size, specify the value here 
const_radius : radius of the circle to be plotted 
zoom_level : zoom level of the map to be plotted 
overlap_cordi: if the coordinates of the samples are overlappin, the value should be boolean, True or False
shift_cordi: if the coordinates are overlapping, shift the coordinates by this value. 
show_label: whether or not the label should be shown in the map, the value should be boolean, True or False 
label_loc : if the label to be displayed near the circle set to be true, specify the location from the circle 
label_size: size of the label to be plotted 
show_legend: Whether or not to plot the legend 
display_sample_size: whether or not to display the sample size along with the pop label in the legend, the value should be boolean 
display_popup: Whether or not to pop-up the information, the value should be boolean 
output_prefix: prefix of the output html file
```
## References
Please cite the following papers if you use this sub-workflow in your study:

[1] Danecek, P., Auton, A., Abecasis, G., Albers, C. A., Banks, E., DePristo, M. A., Handsaker, R. E., Lunter, G., Marth, G. T., Sherry, S. T., McVean, G., Durbin, R., & 1000 Genomes Project Analysis Group (2011). The variant call format and VCFtools. _Bioinformatics (Oxford, England)_, _27_(15), 2156–2158. https://doi.org/10.1093/bioinformatics/btr330

[2] Purcell, S., Neale, B., Todd-Brown, K., Thomas, L., Ferreira, M. A., Bender, D., Maller, J., Sklar, P., de Bakker, P. I., Daly, M. J., & Sham, P. C. (2007). PLINK: a tool set for whole-genome association and population-based linkage analyses. _American journal of human genetics_, _81_(3), 559–575. https://doi.org/10.1086/519795

[3] Di Tommaso, P., Chatzou, M., Floden, E. et al. Nextflow enables reproducible computational workflows. Nat Biotechnol 35, 316-319 (2017). https://doi.org/10.1038/nbt.3820

## License

MIT

