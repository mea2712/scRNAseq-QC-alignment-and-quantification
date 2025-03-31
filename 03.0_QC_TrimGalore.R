rm(list=ls())
#-----------------------------------------------------------------#
args<- commandArgs(trailingOnly=TRUE)
for(i in 1:length(args)){
	assign(paste("args",i,sep=""),eval(parse(text=args[i])))
	cat(paste("args",i,sep=""),":")
	str(eval(parse(text=paste("args",i,sep=""))))
}
#------------------------------------------------------------------#
suppressMessages(library("xml2"))
suppressMessages(library("rvest"))
suppressMessages(library("dplyr"))
suppressMessages(library("stringr"))
#------------------------------------------------------------------#
cat("READ INPUT DATA\n")

fnm<-args1
thre<-args2
onm<-args3
onm1=args4

htmlfl<-read_html(fnm)
state<- htmlfl %>% html_nodes(".summary img") %>% html_attr("alt")

cat("Done-----------------------------------------------------------\n")
cat("COMPUTE FAILED TESTS\n")
nfail<-length(state[state=="[FAIL]"])

cat("Done-----------------------------------------------------------\n")
cat("WRITE OUTPUT\n")

#ifnm<-unlist(regmatches(x=fnm, gregexpr(pattern="[[:graph:]]+/trim_galore.d/",text=fnm)))
ifnm<-as.character(gsub(x=fnm, pattern="_R1_trimmed_fastqc.html",replacement="_R1_trimmed.fq"))
if(as.numeric(nfail) < as.numeric(thre)) {
	outf = file(onm, 'a')
	cat(ifnm,file=outf, append=TRUE, sep="\n")
	close(outf)
} else {
	outf = file(onm1, 'a')
	cat(ifnm,file=outf, append=TRUE, sep="\n")
	close(outf)
} 

cat("Done-------------------------------------------------------------\n")
