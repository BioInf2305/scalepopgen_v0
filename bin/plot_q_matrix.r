library("pophelper")
library("optparse")
library("gridExtra")
args=commandArgs(TRUE)


plot_q_matrix=function(q_file, lab_file, k_val, color_file){
	total_samples = length(readLines(q_file))
	splt_samples = if(total_samples<60) total_samples else 60
    total_lpp = if(total_samples%%180 > 0) total_samples%/%180+1 else total_samples%/%180
    total_legendrow = if(total_samples%%10 > 0) total_samples%/%10+1 else total_samples%/%10
	k_val = strtoi(k_val)
	color_vec = if( color_file != "none" ) file_to_col_map(color_file) else pophelper:::getColours(k_val)
	q_list <- readQ(files=q_file,indlabfromfile=F)
	lab_f = read.delim(lab_file, header=F, stringsAsFactors=F)
	p <- plotQMultiline(qlist=q_list,showindlab=T,clustercol=color_vec, grplab=lab_f,ordergrp=TRUE, height=10,indlabsize=2.3, grplabsize = 5, lpp=total_lpp, showlegend=F, legendkeysize=8,legendtextsize=10,legendmargin=c(2,2,2,0),spl=splt_samples,exportpath=getwd())

}
file_to_col_map = function(colr_f){
	##create vector from a color file (first col)
	color_vec = c()
	con = file(colr_f, "r")
    line = readLines(con)
     for (i in 1:length(line)){
        line_split = as.list(strsplit(line[i], '\\s+')[[1]])
        color_vec[length(color_vec)+1] = line_split[1]
        }
    color_vec1 = unlist(color_vec)
    close(con)
	return (color_vec1)
}

option_list = list(
		     make_option(c("-q", "--q_file"), type="character", default=NULL, 
				               help="full path to the q vector file of ADMIXTURE", metavar="character"),
		     make_option(c("-l", "--lab_file"), type="character", default=NULL, 
				      help="label for each individual, one column for every set of labels", metavar="character"),
		     make_option(c("-k", "--k_val"), type="integer", default=NULL, 
				      help="k value corresponding to the q matrix", metavar="integer"),
		     make_option(c("-c", "--color_file"), type = "character", help="file with color codes", default = "none", metavar = "character")
		     ); 

opt_parser = OptionParser(option_list=option_list);

opt = parse_args(opt_parser);

if (is.null(opt$q_file) | is.null(opt$lab_file) | is.null(opt$k_val)){
  print_help(opt_parser)
  stop("all these arguments must be supplied: -q, -l, -k", call.=FALSE)
}

plot_q_matrix(opt$q_file, opt$lab_file, opt$k_val, opt$color_file)
