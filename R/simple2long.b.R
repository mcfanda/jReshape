
# This file is a generated template, your changes will not be overwritten

simple2longClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "simple2longClass",
    inherit = simple2longBase,
    private = list(
      # this is a list that contains all the SmartTables
      .tables=list(),
      .rdata=NULL,
      .time="time",
      .on=NULL,
      .ov=NULL,
      .nn=NULL,
      .nv=NULL,
      .init= function() {
        jinfo("MODULE: init phase started")
        # set up the coefficients SmartTable
        atable<-SmartTable$new(self$results$info)
        private$.tables[["info"]]<-atable
        atable<-SmartTable$new(self$results$save)
        private$.tables[["save"]]<-atable
        atable<-SmartTable$new(self$results$features)
        private$.tables[["features"]]<-atable
        
        lapply(private$.tables,function(x) x$initTable())          
        
        help<-"<div>
               With this module, you can transform a dataset from the wide format to the long format. 
               To do this, select the variables (columns) from the original dataset that you want to convert
               into different row values and enter them in the <b>Columns to row</b> field. 
               In the new dataset, a variable (specified in the <b>Target variable</b> field) 
               will be created, containing one row for each column value for each case.
               <br><br>
               Additionally, a variable named in the <b>Repeated measure levels</b>
               field will be created, which corresponds to the original column names (e.g., conditions or times). 
               A variable ID will also be created, containing the case ID, which represents the original
               row number in the wide format.
               <br><br>
               If there are variables whose values should be copied for each row of the same case
               (invariant covariates), you can add them in the <b>Non-varying Variables</b> field.
               <br><br>
               Once you are ready, provide a file name and select <b>Save the dataset</b>.
               This will produce a CSV file that will be saved in the specified location 
               (or in the working folder if no path is indicated in the filename).
               The CSV file can be directly opened in jamovi by the user.
               
              </div>"
        if (!self$options$save)
           self$results$help$setContent(help)
        else
           self$results$help$setContent("    ")
        
        
      },
      .run = function() {
    
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
        atab<-NULL
        fileok<-TRUE
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
        
        if (apath==".") apath<-getwd()
        
  
        afilename<-paste0(apath,"/",aname)
        if (self$options$save)
            atab<-list(list(text="Filename:",info=aname),
                       list(text="Folder:",info=apath),
                       list(text="Pathname:",info=afilename)
            )
        if (dir.exists(apath))
            write.csv(private$.rdata,file = afilename,row.names = FALSE,sep = ";")
        else 
            stop("Folder",apath,"does not exist")
          
          
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
