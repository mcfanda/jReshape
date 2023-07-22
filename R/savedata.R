savedata<-function(obj,data) {
  
  if (!obj$options$create) {
    return()
  }

  afilename<-tempfile(fileext = ".omv")
  jmvReadWrite::write_omv(data,afilename)

  atab<-list(list(text="Pathname:",info=afilename))
  
  where<-Sys.info()["sysname"]

  switch (where,
            Windows = {
              dirs<-dir("C://Program Files")
              w<-grep("jamovi",dirs,fixed=T)
              j<-dirs[w]
              cmd<-paste0('C:\\Program Files\\',j,'\\bin\\jamovi')
              arg<-paste(afilename, "--title='Untitled' --temp")
              system2(cmd,args=arg,stderr = T,stdout = T)     
            },
            Linux= {
              cmd<-paste("/app/bin/jamovi ",afilename, "--title='Untitled' --temp")
              system(cmd,ignore.stdout = F,ignore.stderr = F)
            },
            Darwin= {
              cmd <- paste(R.home(), '../../../../../MacOS/jamovi', sep='/')
              arg<-paste(afilename, "--title='Untitled' --temp")
              system2(cmd,args=arg,stderr = T,stdout = T)     
            }
    ) # end of switch
  
  
  return(atab)
  
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