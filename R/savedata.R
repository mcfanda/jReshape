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
              system2(cmd,args=afilename,stderr = T,stdout = T)     
            },
            Linux= {
              cmd<-paste("/app/bin/jamovi ",afilename)
              system(cmd,ignore.stdout = F,ignore.stderr = F)
            },
            Darwin= {
              cmd <- paste(R.home(), '../../../../../MacOS/jamovi', sep='/')
              system2(cmd,args=afilename,stderr = T,stdout = T)     
            }
    ) # end of switch
  }
  
  return(atab)
  
}