#!/usr/bin/bash
zcat $1 | awk '{
	FS="\t"
	OFS="\t"
	ar["R"]=0
	ar["A"]=0}
	$0!~/#/ && length($4) == 1 && length($5) == 1{
		if( $5 !~ /\./ ){
		for(i=10;i<=NF;i++){
			split($i,a,":")
			if(a[1]~/0[\/\|]0/){
				ar["R"]=ar["R"]+2
				}
			if(a[1]~/0[\/\|]1/ ||a[1]~ /1[\/\|]0/){
				ar["A"]++;ar["R"]++
				}
			if(a[1]~/1[\/\|]1/){
				ar["A"]=ar["A"]+2
				}
			}
			if(ar["R"] >= ar["A"]){
				print $1, $2, 0, 1
			}
			if(ar["A"] > ar["R"]){
				print $1, $2, 1, 0
			}

		}
		if( $5 ~ /\./ ){
				print $1, $2, 0, 0
		}
	}' > $2
