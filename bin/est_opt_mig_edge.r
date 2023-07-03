library("OptM")
library("optparse")
args=commandArgs(TRUE)


runOptM=function(dirName, methodName, outPrefix){
    	   outPdf=paste(outPrefix,".pdf",sep="")
	   outTsv=paste(outPrefix,".tsv",sep="")
	   results = optM(dirName, tsv = outTsv)
	   plot_optM(results, method= methodName, plot= FALSE, pdf=outPdf)
}

option_list = list(
		     make_option(c("-d", "--dir"), type="character", default=NULL, 
				               help="prefix of plink bed file", metavar="character"),
		     make_option(c("-m", "--methd"), type="character", default="Evanno", 
				      help="use one from Evanno, linear, SiZer [default= %default]", metavar="character"),
		     make_option(c("-o", "--out"), type = "character", help="output prefix", default = "OptMResults", metavar = "character")
		     ); 

opt_parser = OptionParser(option_list=option_list);

opt = parse_args(opt_parser);

if (is.null(opt$dir)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file)", call.=FALSE)
}

runOptM(opt$dir, opt$methd, opt$out)

