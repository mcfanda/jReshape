
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
      .labs=NULL,
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
        private$.tables[["save"]]$runSource<-savedata(self,private$.rdata)
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
      .reshape=function() {
        
        data<-self$data
        private$.on<-dim(data)[1]
        private$.ov<-dim(data)[2]

        ## gather variables names
        id<-self$options$id
        deps<-self$options$rowstocols
        indexes<-self$options$index
        
        ## be sure the index variables are factors
        for (ind in indexes) 
                     if (!is.factor(data[[ind]]))
                         data[[ind]]<-factor(data[[ind]])
        ## prepare the new variables names
        nl<-lapply(indexes, function(x) levels(data[[x]]))
        wnames<-lapply(deps, function(x) combine(nl,prefix = x))
        wnames<-unlist(wnames)
        
        private$.nc<-length(wnames)
        
        ## prepare the labs
        labs<-lapply(seq_along(indexes), function(x) paste(indexes[[x]],levels(data[[indexes[[x]]]]),sep="="))
        labs<-paste0(levels(interaction(labs, sep = " ")))
        labs<-paste(wnames,labs,sep=": ")
        names(labs)<-wnames
        private$.labs<-labs
        
        # do some checking on the data
        nlevs<-length(wnames)/length(deps)
        checklevs<-tapply(data[[deps[[1]]]],data[[id]],length)
        modeval<-getmode(checklevs)
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
        
        test=any(table(data[,indexes])==0)
        if (test) {
          self$results$help$setContent("<h2>Warning</h2>
                                         <div>
                                         Indexing variables levels are nested. Results may be unexpected.
                                         Pleae check the new data carefully.
                                         </div>")
          
        }
        
        
        ## make a internal index variable
        if (length(indexes)>1)
             data$int.index.<-apply(data[,indexes],1,paste0,collapse="_")
        else
             data$int.index.<-data[,indexes]
        
mark(head(data$int.index.))
        ## reshape
        private$.rdata<-reshape(data,
                                varying = wnames, 
                                v.names=deps,
                                direction="wide", 
                                timevar = "int.index.",
                                drop=indexes)
        ## set the new variables labels
        attr(private$.rdata,"variable.labels")<-labs
        
        ## gather some info
        private$.on<-dim(self$data)[1]
        private$.ov<-dim(self$data)[2]
        private$.nn<-dim(private$.rdata)[1]
        private$.nv<-dim(private$.rdata)[2]
        
      },
      .features=function() {
        lapply(private$.labs, function(x) {
          s<-strsplit(x,":",fixed = T)[[1]]
          list(var=s[[1]],lab=s[[2]])
        })
        
        
      }
      
      )
)
