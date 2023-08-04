#!/usr/bin/Rscript

library("ggplot2")
library("lattice")
library("optparse")
library("RColorBrewer")

args=commandArgs(TRUE)


run_pca=function(stem,chr,colr){
    library("SNPRelate")
    bed_b.fn=paste(stem,".bed",sep="")
    bed_f.fn=paste(stem,".fam",sep="")
    bed_bi.fn=paste(stem,".bim",sep="")
    gds.fn = paste(stem,".gds", sep="")
    eigenvect_out = paste(stem,".eigenvect", sep="")
    varprop_out = paste(stem,".varprop",sep="")
    jpg_out = paste(stem,".jpeg",sep="")
    #convert bed to gds format
    snpgdsBED2GDS(bed_b.fn,bed_f.fn,bed_bi.fn,family=TRUE,option = snpgdsOption(autosome.end=as.numeric(chr)), gds.fn)
    genofile=snpgdsOpen(gds.fn)
    pca=snpgdsPCA(genofile,num.thread=1,autosome.only=FALSE)
    sample.id=pca$sample.id
    #extract first and second eigenvectors values
    EV1=pca$eigenvect[,1]
    EV2=pca$eigenvect[,2]
    tab=data.frame(sample.id,pca$eigenvect, stringsAsFactors=FALSE)
    tab1=data.frame(pca$varprop)
    pop.id=read.gdsn(index.gdsn(genofile,"sample.annot/family"))
    unique.pop.id = unique(pop.id)
    if(colr == "NA"){
	#n_col = length(unique.pop.id)
    	write.table(tab,eigenvect_out,sep="\t",row.names=FALSE,quote=FALSE)
    	write.table(tab1,varprop_out,sep="\t",row.names=FALSE,quote=FALSE)
    	#qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
	##generate random color vector
	#col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
	#pop.colors=sample(col_vector, n_col)
    }
    else{
	    ##take colour names from the user provided file
	    pop.colors = file_to_col_map(colr)
    jpeg(jpg_out,width=6,height=6,unit='in',res=300)
    print({ggplot(tab,aes(x=EV1,y=EV2,colour=pop.id))+geom_point(size=1)+scale_colour_manual(values=pop.colors)+theme(legend.key.height= unit(0.05, 'in'),
        legend.key.width= unit(0.05, 'in'),legend.text = element_text(size=4))+guides(colour = guide_legend(ncol = 1))})
    dev.off()
    write.table(tab,eigenvect_out,sep="\t",row.names=FALSE,quote=FALSE)
    write.table(tab1,varprop_out,sep="\t",row.names=FALSE,quote=FALSE)
    }
 }


file_to_col_map = function(colr_f){
        ##separate vector for popname (first col) and color (second col)
        pop_vec = c()
        color_vec = c()
        con = file(colr_f, "r")
        line = readLines(con)
        for (i in 1:length(line)){
            line_split = as.list(strsplit(line[i], '\\s+')[[1]])
            if ( length(line_split) == 2 ) {
                pop_vec[length(pop_vec)+1] = line_split[1]
            color_vec[length(color_vec)+1] = line_split[2]
            }
        }
        pop.colors = setNames(color_vec, pop_vec)
        close(con)
        return (pop.colors)
}


option_list = list(
		     make_option(c("-b", "--bed"), type="character", default=NULL, 
				               help="prefix of plink bed file", metavar="character"),
             make_option(c("-C", "--chr"), type = "integer", default=NULL, help="total number of autosomal chromosome", metavar= "character"),
		       make_option(c("-c", "--colr"), type="character", default="NA", 
				                 help="file name describing popname (column1) and color (column2) [default= %default], the columnns should be space separated", metavar="character")
		       ); 

opt_parser = OptionParser(option_list=option_list);

opt = parse_args(opt_parser);

if (is.null(opt$bed)){
  print_help(opt_parser)
  stop("At least two arguments must be supplied(-b and -C)", call.=FALSE)
}

run_pca(opt$bed, opt$chr, opt$colr)
