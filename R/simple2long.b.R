
# This file is a generated template, your changes will not be overwritten

simple2longClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "simple2longClass",
    inherit = simple2longBase,
    private = list(
      # this is a list that contains all the SmartTables
      .tables=list(),
      .runcreate=FALSE,
      .rdata=NULL,
      .time="time",
      .on=NULL,
      .ov=NULL,
      .nn=NULL,
      .nv=NULL,
      .init= function() {
        
        if (!is.something(self$options$colstorows)) {
          self$results$help$setContent(HELP_simple2long)
          return()
        } else
          self$results$help$setContent("  ")
        

        atable<-SmartTable$new(self$results$store)
        atable$initSource=list(list(x=0))
        private$.tables[["store"]]<-atable
        
        jinfo("MODULE: init phase started")
        # set up the coefficients SmartTable
        atable<-SmartTable$new(self$results$info)
        private$.tables[["info"]]<-atable
        atable<-SmartTable$new(self$results$save)
        private$.tables[["save"]]<-atable
        atable<-SmartTable$new(self$results$features)
        private$.tables[["features"]]<-atable
        
        
        lapply(private$.tables,function(x) x$initTable())          
        
        
      },
      .run = function() {
    
        jinfo("MODULE: run phase started")

        if (!is.something(self$options$colstorows))
          return()
        
        private$.reshape()
        private$.tables[["info"]]$runSource<-private$.infotable
        private$.tables[["save"]]$runSource<-private$.savedata
        private$.tables[["features"]]$runSource<-private$.features

        lapply(private$.tables,function(x) x$runTable())          
        
        showdata<-private$.rdata
        showdata<-showdata[1:30,1:min(ncol(showdata),10)]
        self$results$showdata$setContent(showdata)

        },
      .infotable=function() {
        atab<-list()
        ladd(atab)<-list(text="Original N",var=private$.on)
        ladd(atab)<-list(text="New N",var=private$.nn)
        ladd(atab)<-list(text="# of original variables",var=private$.ov)
        ladd(atab)<-list(text="# of new varariables",var=private$.nv)
        ladd(atab)<-list(text="Cols to rows",var=length(self$options$colstorows))
        ladd(atab)<-list(text="Fixed variables",var=length(self$options$covs))
        
        return(atab)
      },
      .savedata=function() {


        
        if (!self$options$create) {
          atab<-list(list(text="Action:",info="Press 'Create' when ready to save the dataset"))
          return(atab)
        }

        where<-Sys.info()["sysname"]
        afilename<-self$options$filename
        
        if (!is.something(afilename))
          stop("Please define a filename to store the new dataset")
        if (trimws(afilename)=="")
          stop("Please define a filename to store the new dataset")

        aname<-basename(afilename)
        aname<-gsub(" ","_",aname,fixed = T)
        apath<-dirname(afilename)
        ext<- file_ext(aname)
        if (ext!="csv")
          aname<-paste0(aname,".csv")
        
        if (apath==".") {
          switch (where,
            Windows = {apath<-paste0("C:/Users/",Sys.getenv("USERNAME"),"/Documents")},
            Linux = {apath<-tempdir()}
          )
        }
        afilename<-file.path(apath,aname)
        afilename<-path.expand(afilename)

        if (dir.exists(apath)) 
            write.csv(private$.rdata,file = afilename,row.names = FALSE,sep = ";")
        else 
            stop("Folder",apath,"does not exist")

        atab<-list(list(text="Filename:",info=aname),
                   list(text="Folder:",info=apath),
                   list(text="Pathname:",info=afilename)
        )
        
        
        
        if (self$options$open) {

         switch (where,
           Windows = {
             dirs<-dir("C://Program Files")
             w<-grep("jamovi",dirs,fixed=T)
             j<-dirs[w]
             cmd<-paste0('C:\\Program Files\\',j,'\\bin\\jamovi')
             system2(cmd,args=afilename)     
           },
           Linux= {
             cmd<-paste("/app/bin/jamovi ",afilename)
             system(cmd,ignore.stdout = F,ignore.stderr = F)
             #system2(cmd,args=afilename)     
             
           }
         ) # end of switch
        }
        
        return(atab)
      },
      
      .reshape=function() {
        
        private$.on<-dim(self$data)[1]
        private$.ov<-dim(self$data)[2]
        
        dep<-self$options$dep
        if (!is.something(dep))
            dep<-"y"
        if (trimws(dep)=="")
            dep<-"y"
        
        time<-self$options$rmlevels
        if (!is.something(time))
           time<-"time"
        if (trimws(time)=="")
           time<-"time"
        id<-"id"
        private$.time<-time
        private$.rdata<-reshape(self$data,varying = self$options$colstorows, v.names=dep,direction="long", timevar = time)
        private$.rdata<-private$.rdata[order(private$.rdata[[id]]),]
        private$.on<-dim(self$data)[1]
        private$.ov<-dim(self$data)[2]
        private$.nn<-dim(private$.rdata)[1]
        private$.nv<-dim(private$.rdata)[2]
        
      },
      .features=function() {
        atab<-table(private$.rdata[[private$.time]])
        tab<-as.data.frame(atab)
        attr(tab,"titles")<-c(Var1=private$.time)
        tab
      }
      
      )
)
