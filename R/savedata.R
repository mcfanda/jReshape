savedata<-function(obj,data) {
  

    jmvReadWrite:::jmvOpn(dtaFrm = data, dtaTtl =  "Untitled")
    

}

showdata<-function(obj,data) {
  
  nl<-50
  data$row<-1:dim(data)[1]
  nr<-nrow(data)
  nrs<-min(nl,nr)
  nc<-ncol(data)
  ncs<-min(10,nc)
  cols<-1:ncs
  if (nr>nl) warning("There are ",nr-nl," more rows in the dataset not shown here\n")
  if (nc>10) { warning("There are ",nc-10," more colums in the dataset not shown here\n")
    cols<-c(nc,1:ncs)
  }
  data<-data[1:nrs,cols]
  try_hard(data[nrs,]<-rep("...",nc))
  data
  
}