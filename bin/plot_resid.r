#!/usr/bin/env Rscript
####this function is taken directly from the Rscript ("plotting funcs.R") provided with a treemix package

args=commandArgs(TRUE)
library(RColorBrewer)

plot_resid = function(stem, pop_order, pdfOut){
	min = -0.009
	max = 0.009
	cex = 0.75
	usemax = T
	wcols = "r"
	c = read.table(gzfile(paste(stem, ".cov.gz", sep = "")), as.is = T, head = T, quote = "", comment.char = "")
	m = read.table(gzfile(paste(stem, ".modelcov.gz", sep = "")), as.is = T, head = T, quote = "", comment.char = "")
	names(c) = rownames(c)
	names(m) = rownames(m)
	o = read.table(pop_order, as.is = T, comment.char = "", quote = "")
	se = read.table(gzfile(paste(stem, ".covse.gz", sep = "")), as.is = T, head = T, quote = "", comment.char = "")
	mse = apply(se, 1, mean)
	mse = mean(mse)
	print(mse)	
	c = c[order(names(c)), order(names(c))]
	m = m[order(names(m)), order(names(m))]
	tmp = c -m 
	#tmp = m - c
	#tmp = (m-c)/m
	#print(tmp)
	toplot = data.frame(matrix(nrow = nrow(tmp), ncol = ncol(tmp)))
	for(i in 1:nrow(o)){
	        for( j in 1:nrow(o)){
			#print(paste(o[i,1], o[j,1]))
			if (o[i,1] %in% names(tmp) ==F){
				print(paste("not found", o[i,1]))
			}
			if (o[j,1] %in% names(tmp) ==F){
				print(paste("not found", o[j,1]))
			}
        	        toplot[i, j] = tmp[which(names(tmp)==o[i,1]), which(names(tmp)==o[j,1])]
        	}
	}
	#print(toplot)
	if (usemax){
		m1 = max(abs(toplot), na.rm = T)
		max = m1*1.02
		min = -(m1*1.02)	
	}
	names(toplot) = o[,1]
	toreturn = plot_resid_internal(toplot, max = max, min = min, wcols = wcols, mse = mse, o = o, cex = cex, pdfOut = pdfOut)
	return(toreturn)
}
plot_resid_internal = function(d, o = NA, max = 0.009, min = -0.009, cex =0.5, wcols = "rb", mse = NA, pdfOut){
        npop = nrow(d)
        width = 1/npop
        height = 1/npop
	colors = brewer.pal(9, "Spectral")
	colors = c("red", "orange","yellow", "white", "green", "blue", "black")
	pal = colorRampPalette(colors)
	ncol = 80
	cols = pal(ncol)
	pdf(pdfOut,width=12,height=12)
        plot("NA", xlim = c(0, 1), ylim = c(0, 1), axes = F, xlab = "", ylab = "")
        for (i in 1:npop){
                for( j in 1:i){
                        v = d[i,j]
			print(paste(i, j, v))
                        col= "white"
                        if (v < 0){
				if (wcols == "rb"){
				col = rgb(0, 0, 1, v/min)
				}
				else{
                                #col = rgb(0, 0, 1, 0.1+0.9*(v/min))
				col = cols[ncol/2-floor( (v/min)*(ncol/2))]
				#col = "white"
				}
                        }
                        else{
				if (wcols == "rb"){
				col = rgb(1, 0, 0, v/max)
				}
				else{
                                #col = rgb(1, 0, 0, 0.1+0.9*(v/max))
				col = cols[ncol/2+ceiling((v/max)*(ncol/2))]
				}
                        }
                        xmin = j/npop - 1/npop
                        xmax = j/npop
                        ymin = 1-(i/npop)
                        ymax = 1-(i/npop)+1/npop
                        rect(xmin, ymin, xmax, ymax, col = col, border = col)
                }
		tcol = "black"
		tmp = o[o[,1] == names(d)[i],]
		if (length(tmp) != 1){
			tcol = tmp[1,2]
		}
                mtext(names(d)[i], side = 2, at = 1-i/npop+0.5/npop, las = 1, cex = cex, col = tcol)
                mtext(names(d)[i], side = 1, at =  i/npop-0.5/npop, las = 3, cex = cex, col = tcol)
        }
	if ( !is.na(mse)){
                ymi = 0.5
                yma = 0.9
                w = (yma-ymi)/ncol
                xma = 0.80
		lmi = round(min/mse, digits = 1)
		lma = round(max/mse, digits = 1)
		#print(cols)
		#print(ymi+(0:ncol)*w)
                rect( rep(0.75, ncol), ymi+(0:(ncol-1))*w, rep(xma, ncol), ymi+(1:ncol)*w, col = cols, border = cols)
                text(xma+0.01, ymi, lab = paste(lmi, "SE"),  adj = 0, cex = 0.6)
                text(xma+0.01, yma, lab = paste(lma, "SE"), adj = 0, cex = 0.6)

	}
	return(d)
	dev.off()
	#image(as.matrix(d), col = cols)
}


plot_resid(args[1], args[2], args[3])
