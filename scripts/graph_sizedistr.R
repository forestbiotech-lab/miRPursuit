#!/usr/bin/env Rscript

#
#  Used to make plots from fasta/fastq files.
#


#Call graph_sizedistr.R [file1] [file2] [Identifier] [Fastq/Fasta counts for lib  Can't this be infered?????]
#Call graph_sizedistr.R [file1 (TSV Profile)] [Path where to save]
args <- commandArgs(trailingOnly = TRUE)
#Read from size.distr Ignores two rows (Firs should be converted to the colnames)
#Structure size\tNum\tSiz\tNum #First row MUST have raw  (FASTQ lib total)

#Reads data in first file
file1=read.table(args[1], sep="\t",skip=0,row.names=1,header=T)
#
lastRow1=length(file1[,1])



if(length(args)==4){
  ##This is for pair-wise comparison !!!Not implemented - Must be overhauled Out-dated!!
  file2=read.table(args[2], sep="\t",skip=1,row.names=1,header=T)

  ##############################
  #Description for file names unique identifier
  identifier=args[3]
  #need the total lib size ##Must be tabs
  libtotal=read.table(args[4],sep="\t",header=T,row.names=1)
  print(libtotal)
  	
#Combine column-wise the two files from size-fasta.py
  datum=cbind(file1,file2[,1])
  
  #Set name for new column of datum
  colnames(datum)[2]=colnames(file2)[1]
  libsize=cbind(datum[,1]/libtotal[colnames(datum)[1],"Total"],datum[,2]/libtotal[colnames(datum)[2],"Total"])
  libsize=libsize*100
  #Dynamic get of libtotal based on collabel done.	
  colnames(libsize)=colLabels

}else{
  #Other options then 4 is not completed
  identifier=colnames(file1)[1]
  libsize=sum(file1[,1])
  matrix=file1[,1]*100/libsize
  matrix=as.matrix(matrix)

#  libsize=cbind(libsize,libsize)
  colnames(matrix)=colnames(file1)
  rownames(matrix)=rownames(file1)
}

#rownames(libsize)=rownames(data)


xlab="Sequence length (bp)"
ylab="Percentage of reads (%)"
main=paste0("Sequence length distribution - ",identifier)
sub="Sequences with size between 18-26"

#Create plotMAtrix with specific interval
mat=matrix[19:27,]
print(mat)

log="n"
if(length(args)==4){
  col=c("Green","Brown") #The colours for each series
}else{
  col=c("Green")
}
########
#Legend#
########
lty=c(1,1) # gives the legend appropriate symbols (lines)
lwd=c(2.5,2.5) #gives the legend lines the correct width
#Window scaling
yy=c(min(mat),max(mat))
xx=c(min(names(mat)),max(names(mat)))


#chartFile=paste0("chart_",identifier,"_size_distr.png")
#png(chartFile)
#plot(xx,yy,type="n",xlab=xlab,ylab=ylab,main=main,sub=sub)
#lines(mat,(names(mat)),col="green",lwd=2.5)
#if(length(args)==4){
#  lines(colnames(mat),(mat[2,]),col="brown",lwd=2.5)
#}else{
#  lines((mat),names(mat),col="brown",lwd=2.5)
#}
#legend(18,16,c("Leaves","Phellem"), # places a legend at the appropriate place c(“Health”,”Defence”), # puts text in the legend
#lty=lty,lwd=lwd,col=col)
#dev.off()

barplotFile=paste0(args[2],"Barplot-",identifier,"-size-distr.png")
png(barplotFile)
if(length(args)==4){
  barplot(mat,beside=TRUE,legend.text=TRUE,names.arg=colnames(mat),col=col,xlab=xlab,ylab=ylab,main=main,sub=sub)
}else{
  barplot(mat,beside=FALSE,legend.text=rownames(mat)[1],names.arg=colnames(mat),col=col,xlab=xlab,ylab=ylab,main=main,sub=sub)
}
dev.off()