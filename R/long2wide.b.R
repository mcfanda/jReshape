
# This file is a generated template, your changes will not be overwritten

long2wideClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "long2wideClass",
    inherit = long2wideBase,
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
      .nc=NULL,
      .notrun=FALSE,
      .init= function() {

        self$results$help$setContent("  ")
        
        test<-(!is.something(self$options$rowstocols))
        if (test) {
          self$results$help$setContent(HELP_long2wide[[1]])
          private$.notrun=TRUE
          return()
        }
        
        test<-(!is.something(self$options$index))
        if (test) {
          HELP_long2wide
          self$results$help$setContent(HELP_long2wide[[2]])
          private$.notrun=TRUE
          return()
        }
        test<-(!is.something(self$options$id))
        if (test) {
          HELP_long2wide
          self$results$help$setContent(HELP_long2wide[[3]])
          private$.notrun=TRUE
          return()
        }
        


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

        if (private$.notrun)
          return()
        
        private$.reshape()
        private$.tables[["info"]]$runSource<-private$.infotable
        private$.tables[["save"]]$runSource<-private$.savedata
        private$.tables[["features"]]$runSource<-private$.features

        lapply(private$.tables,function(x) x$runTable())          
        
        showdata<-private$.rdata
        nr<-nrow(showdata)
        nrs<-min(30,nr)
        nc<-ncol(showdata)
        ncs<-min(10,nc)
        showdata<-showdata[1:nrs,1:ncs]
        self$results$showdata$setContent(showdata)
        msg<-""
        if (nr>30) msg<-paste("There are",nr-30,"more rows in the dataset not shown here\n")
        if (nc>10) msg<-paste(msg,"There are",nc-10,"more colums in the dataset not shown here\n")
        self$results$showdatanote$setContent(msg)
        
        },
      .infotable=function() {
        atab<-list()
        ladd(atab)<-list(text="Original N",var=private$.on)
        ladd(atab)<-list(text="New N",var=private$.nn)
        ladd(atab)<-list(text="# of original variables",var=private$.ov)
        ladd(atab)<-list(text="# of new varariables",var=private$.nv)
        ladd(atab)<-list(text="New columns",var=private$.nc)
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
        if (ext!="omv")
          aname<-paste0(aname,".omv")
        
        if (apath==".") {
          switch (where,
            Windows = {apath<-paste0("C:/Users/",Sys.getenv("USERNAME"),"/Documents")},
            Linux = {apath<-tempdir()}
          )
        }
        afilename<-file.path(apath,aname)
        afilename<-path.expand(afilename)

        if (dir.exists(apath)) 
           jmvReadWrite::write_omv(private$.rdata,afilename)
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
             q<-system2(cmd,args=afilename,stderr = T,stdout = T)     
             mark(q)
           },
           Linux= {
             cmd<-paste("/app/bin/jamovi ",afilename)
             system(cmd,ignore.stdout = F,ignore.stderr = F)
           }
         ) # end of switch
        }
        
        return(atab)
      },
      
      .reshape=function() {
        
        data<-self$data
        private$.on<-dim(data)[1]
        private$.ov<-dim(data)[2]
        
        deps<-self$options$rowstocols

        index<-self$options$index
        nl<-lapply(index, function(x) levels(factor(data[[x]])))
        
        id<-self$options$id
        private$.time<-time
        
        wnames<-combine(nl,prefix = deps)
        private$.nc<-length(wnames)
        # do some checking on the data
        nlevs<-length(wnames)
        checklevs<-tapply(data[[deps[[1]]]],data[[id]],length)
        modeval<-getmode(checklevs)
        mark(modeval,nlevs,as.numeric(modeval) %% as.numeric(nlevs) )
        if (modeval>nlevs)
            self$results$help$setContent("<h2>Warning</h2>
                                         <div>
                                         The number of rows for each case does not equal the number
                                         of columns required. Only the first instance of each level 
                                         is used.
                                         </div>")
        if ((modeval %% nlevs )>0) {
           self$results$help$setContent("<h2>Warning</h2>
                                         <div>
                                         The number of rows for each case cannot be evenly divided
                                         by the number of required columns. Missing data are generated.
                                         </div>")
          
        }
        
        data$int.index.<-apply(data[,index],1,paste0,collapse="_")
        

        private$.rdata<-reshape(data,
                                varying = wnames, 
                                v.names=deps,
                                direction="wide", 
                                timevar = "int.index.",
                                drop=index)
        
        private$.on<-dim(self$data)[1]
        private$.ov<-dim(self$data)[2]
        private$.nn<-dim(private$.rdata)[1]
        private$.nv<-dim(private$.rdata)[2]
        
      },
      .features=function() {
        
      }
      
      )
)
