data(iris)
head(iris)
data<-iris[,1:3]
#names(data)<-gsub(".","",names(data),fixed = T)
dim(data)
ff<-names(data)
ff

datax<-data.frame(a1=1:10,a2=21:30,a3=31:40,a4=41:50)
n<-dim(datax)[1]
ff<-c("a1","a2","a3")

ld<-reshape(datax,varying=c("a1","a2"),direction="long",v.names=c("dep1"))
atab<-table(ld[["id"]])
atab<-as.data.frame(atab)
lapply(atab, function(a) a)
reshape(datax,varying=list(c("a1","a2"),c("a3","a4")),direction="long",v.names=c("dep1","dep2"))

qq<-reshape(datax,varying=list(c("a1","a2","a3","a4")),direction="long",v.names=c("dep1"),timevar = c("time1"))
qq
dim(qq)

z<-expand.grid(1:2,1:2)
dd<-as.data.frame(do.call(rbind,lapply(1:n,function(i) z)))
dim(dd)
dd
rdata<-reshape(datax,varying=ff,direction="long",v.names="dep")

rdata$time<-factor(rdata$time)
levels(rdata$time)<-ff
head(rdata)
rdata<-rdata[order(rdata$id),]
head(rdata)
head(iris)
dim(rdata)
table(rdata$time)
library(reshape2)
reshapeLong
sum(table(data$Sepal.Length))
sum(table(data$Petal.Length))
