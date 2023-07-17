savedata<-function(obj,data) {
  
  if (!obj$options$create) {
    atab<-list(list(text="Action:",info="Press 'Create' when ready to save the dataset"))
    return(atab)
  }
  where<-Sys.info()["sysname"]

  afilename<-tempfile(fileext = ".omv")
  jmvReadWrite::write_omv(data,afilename)

  atab<-list(list(text="Pathname:",info=afilename))
  

  if (obj$options$open) {
    
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
  }
  
  return(atab)
  
}

showdata<-function(obj,data) {
  
  nl<-50
  data$row<-1:dim(data)[1]
  nr<-nrow(data)
  nrs<-min(nl,nr)
  nc<-ncol(data)
  ncs<-min(10,nc)
  if (nr>nl) warning("There are ",nr-nl," more rows in the dataset not shown here\n")
  if (nc>10) warning("There are ",nc-10," more colums in the dataset not shown here\n")
  data<-data[1:nrs,1:ncs]
  try_hard(data[nrs,]<-rep("...",nc))
  data
  
}