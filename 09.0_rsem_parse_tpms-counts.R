rm(list=ls())
set.seed(1234)
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
	# Read in
	temp<-read.table(tnm,header=TRUE)
	return(temp)
})

cat("PROCESSING DATA\n")
# Merge
mat=do.call(cbind, indat)

cat("SAVING OUTPUT\n")
wd=args2
saveRDS(mat,file=paste(wd,".RDS",sep=""))
cat("DONE",Sys.time(),"-------------------------------------------------------\n")
sessionInfo()
