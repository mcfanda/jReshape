
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
        
      
        
        jinfo("MODULE: init phase started")
        # set up the coefficients SmartTable
        atable<-SmartTable$new(self$results$info)
        private$.tables[["info"]]<-atable
        atable<-SmartTable$new(self$results$save)
        private$.tables[["save"]]<-atable
        atable<-SmartTable$new(self$results$features)
        private$.tables[["features"]]<-atable
        atable<-SmartTable$new(self$results$showdata)
        atable$expandOnRun<-TRUE
        atable$expandFrom<-2
        private$.tables[["showdata"]]<-atable
        
        lapply(private$.tables,function(x) x$initTable())          
        
        
      },
      
      .run = function() {

        jinfo("MODULE: run phase started")

        if (!is.something(self$options$colstorows)) {
          self$results$help$setContent(HELP_simple2long)
          return()
        } else {
          self$results$help$setContent("  ")
        }
        

        private$.reshape()
        private$.tables[["info"]]$runSource<-private$.infotable
        private$.tables[["save"]]$runSource<-savedata(self,private$.rdata)
        private$.tables[["features"]]$runSource<-private$.features
        private$.tables[["showdata"]]$runSource<-private$.showdata
        
        lapply(private$.tables,function(x) x$runTable())          
        
        
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
      },
      .showdata=function() {
        showdata(self,private$.rdata)
      }
      )
)
