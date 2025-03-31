rm(list=ls())
#------------------------------------------------------#
#source("/castor/project/proj/maria.d/xxxx/code.d/xxxx.R")
#------------------------------------------------------------------------#

library("data.table")
#------------------------------------------------------------------------#

start_time<-Sys.time()
#-------------------------------------------------------------------------#

cat("READING SYSTEM VARIABLES\n")
args <-commandArgs(trailingOnly=TRUE)
for(i in 1:length(args)){
        assign(paste("args",i,sep=""),eval(parse(text=args[i])))
        cat(paste("args",i,sep=""),":\n")
        str(eval(parse(text=paste("args",i,sep=""))))
}
cat("Done",Sys.time(),"----------------------------------------------------\n")

cat("LOADING DATA\n")
# Set working directory to list files -- be sure the directory has ONLY and ALL files that will be merged, since I am not greping any pattern --
wd<-args1
#inflnm<-list.files(path=wd, pattern="*_htseq_formatted.counts")
inflnm<-list.files(path=wd)

# Load
indat<-lapply(1:length(inflnm), function(x){
	tnm<-paste(wd,inflnm[x],sep="")
	# Scan for column types and field separator to make the loading faster
	init<-read.table(tnm, nrows=1, header=TRUE)
	if(ncol(init)==1) {FS<-","}else{FS=""}
	init<-read.table(tnm, nrows=10, header=TRUE, sep=FS)
	dat_class<-sapply(init,class)
	# Read in
	temp<-read.table(tnm, colClasses=dat_class, header=TRUE, comment.char="",sep=FS)
	setDT(temp)
	setkey(temp, TRANSCRIPT)
	cat(".. loading file",x, "out of",length(inflnm),"\n")
	cat(".. .. ",tnm,"\n")
	rm(init); rm(FS); rm(dat_class)
	return(temp)
})
cat("Done",Sys.time(),"-----------------------------------------------------\n")

cat("PROCESSING DATA\n")
# Merge
# Create a function to merge
merge_f<-function(...){merge(..., by='TRANSCRIPT', all=TRUE)}
merged_dat<-Reduce(merge_f,indat)
cat(".. files merged\n")
cat("Done",Sys.time(),"-----------------------------------------------------\n")

cat("SAVING OUTPUT\n")
outdir<-wd
nm<-args2
outnm<-paste(outdir,nm,".csv",sep="")
data.table::fwrite(merged_dat, outnm, sep=",", col.names=TRUE, row.names=FALSE, quote=FALSE)

cat("DONE",Sys.time(),"-------------------------------------------------------\n")
end_time<-Sys.time()
end_time-start_time
cat("-------------------------------------------------------------------------\n")
sessionInfo()
