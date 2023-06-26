savedata<-function(obj,data) {
  
  if (!obj$options$create) {
    atab<-list(list(text="Action:",info="Press 'Create' when ready to save the dataset"))
    return(atab)
  }
  where<-Sys.info()["sysname"]
  afilename<-obj$options$filename
  
  if (!is.something(afilename))
    stop("Please define a filename to store the new dataset")
  if (trimws(afilename)=="")
    stop("Please define a filename to store the new dataset")
  
  aname<-basename(afilename)
  aname<-gsub(" ","_",aname,fixed = T)
  apath<-dirname(afilename)
  ext<- file_ext(aname)
  if (ext!="omv")
    aname<-paste0(aname,".omv")
  
  if (apath==".") {
    switch (where,
            Windows = {apath<-paste0("C:/Users/",Sys.getenv("USERNAME"),"/Documents")},
            Linux = {apath<-tempdir()},
            Darwin= {apath<-tempdir()}
    )
  }
  afilename<-file.path(apath,aname)
  afilename<-path.expand(afilename)
  
  if (dir.exists(apath)) 
    jmvReadWrite::write_omv(data,afilename)
  else 
    stop("Folder",apath,"does not exist")
  
  atab<-list(list(text="Filename:",info=aname),
             list(text="Folder:",info=apath),
             list(text="Pathname:",info=afilename)
  )
  

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

showdata<-function(data) {
  
  data$row<-1:dim(data)[1]
  nr<-nrow(data)
  nrs<-min(30,nr)
  nc<-ncol(data)
  ncs<-min(10,nc)
  if (nr>30) warning("There are ",nr-30," more rows in the dataset not shown here\n")
  if (nc>10) warning("There are ",nc-10," more colums in the dataset not shown here\n")
  data<-data[1:nrs,1:ncs]
  try_hard(data[nrs,]<-rep("...",nc))
  data
  
}