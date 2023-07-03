#!/usr/bin/awk -f
BEGIN{
    FS="\t"
    OFS="\t"
    header_stop=0 
}
{
    if($0~/#/){
        record[NR]=$0
        chrom["na"]
        if($0~/#CHROM/){
            header_stop=NR
            }
        next
        }
    else
        if(!($1 in chrom)){
            for(i=1;i<=header_stop;i++){
                rec=record[i]
                if(rec~/#contig/){
                    match(rec,/(##contig=<ID=)([^,>]+)(.*)/,a)
                    if(a[2]==$1){
                        print rec>>$1".split.vcf"
			print rec
                    }
                }
                else
                    print rec>>$1".split.vcf"
                    chrom[$1]
            }
            print>>$1".split.vcf"
        }
        else{
            print>>$1".split.vcf"
        }
}
