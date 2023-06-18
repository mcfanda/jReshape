
# This file is a generated template, your changes will not be overwritten

complex2longClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "complex2longClass",
    inherit = complex2longBase,
    private = list(
      # this is a list that contains all the SmartTables
      .tables=list(),
      .runcreate=FALSE,
      .rdata=NULL,
      .indexes=NULL,
      .indexes_name=NULL,
      .on=NULL,
      .ov=NULL,
      .nn=NULL,
      .nv=NULL,
      .ndep=NULL,
      .notrun=FALSE,
      .init= function() {

        self$results$help$setContent("  ")
        
        test<-any(unlist(lapply(self$options$colstorows, function(x) !is.something(x$vars))))
        if (test) {
          help<-"<h1>Help</h1><div>Please fill in the columns variables that will go in the long format target variables</div>"
          self$results$help$setContent(help)
          private$.notrun=TRUE
          return()
        }
        test<-any(unlist(lapply(self$options$colstorows, function(x) !is.something(x$label))))
        if (test)  {
          help<-"<h1>Help</h1><div>Please give a name to each long format target variable</div>"
          self$results$help$setContent(help)
          private$.notrun=TRUE
          return()
        }  
        ns<-unlist(lapply(self$options$colstorows, function(x) length(x$vars)))
        if (length(self$options$colstorows)>1)
                if (var(ns)!=0)  {
                             help<-"<h1>Help</h1><div>Levels should be the same across target variables. 
                              </div>"
                              self$results$help$setContent(help)
                              private$.notrun=TRUE
                             return()
                }  
        indexes<-self$options$index
        indexes<-indexes[unlist(lapply(indexes,function(x) is.something(trimws(x$var))))]
        indexes<-indexes[unlist(lapply(indexes,function(x) is.something(x$levels)))]
        
        private$.indexes<-indexes
        private$.indexes_name<-unlist(lapply(indexes,function(x) x$var))
                                 
        if (length(indexes)==1 & indexes[[1]]$levels>0) {
          help<-paste("<h1>Help</h1><div>Index variable",indexes[[1]]$var,"defined levels are ignored. The number of 
                               Columns to rows variables is used instead.
                              </div>")
          self$results$help$setContent(help)
        }
          
        if (length(indexes)>1) {
          tot<-prod(unlist(lapply(indexes,function(x) as.numeric(x$levels))))
          ref<-ns[1]
          if (tot!=ref) {
          help<-paste("<h1>Help</h1><div>The combination (product) of the index variables levels should be equal
                            to the number of levels defined in the `Columns to rows` setup.
                              </div>")
          self$results$help$setContent(help)
          private$.notrun=TRUE
          return()
          
          }
        }
        
        jinfo("MODULE: init phase started")
        # set up the coefficients SmartTable
        atable<-SmartTable$new(self$results$info)
        private$.tables[["info"]]<-atable
        atable<-SmartTable$new(self$results$save)
        private$.tables[["save"]]<-atable
        atable<-SmartTable$new(self$results$features)
        atable$expandOnRun<-TRUE
        private$.tables[["features"]]<-atable
        
        
        lapply(private$.tables,function(x) x$initTable())          
        
        
      },
      .run = function() {
    
        jinfo("MODULE: run phase started")

        if (private$.notrun)    return()
        
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
        ladd(atab)<-list(text="Cols to rows",var=length(self$options$colstorows))
        ladd(atab)<-list(text="Target variables",var=private$.ndep)
        ladd(atab)<-list(text="Fixed variables",var=length(self$options$covs))
        
        return(atab)
      },

      .reshape=function() {
        
        private$.on<-dim(self$data)[1]
        private$.ov<-dim(self$data)[2]
        
        dep<-unlist(lapply(self$options$colstorows,function(x) x$label))
        colstorows<-unlist(lapply(self$options$colstorows,function(x) x$vars))
        indexes<-private$.indexes

        id<-"id"
        private$.rdata<-reshape(self$data,varying = colstorows, v.names=dep,direction="long", timevar = "int.index.")
        private$.rdata<-private$.rdata[order(private$.rdata[[id]]),]
        if (length(indexes)>1) {
          grid<-expand.grid(lapply(indexes,function(x) 1:as.numeric(x$levels)))
          if (length(grep("int.index.",private$.indexes_name,fixed=T))>0) stop("'int.index.' is a reserved word, please choose another name for your index variables")
          tdata<-as.data.frame(do.call(rbind,lapply(1:private$.on,function(i) grid)))
          private$.rdata<-as.data.frame(cbind(tdata,private$.rdata))
          names(private$.rdata)[1:length(private$.indexes_name)]<-private$.indexes_name
          private$.rdata[["int.index."]]<-NULL
        } else   names(private$.rdata)[1]<-private$.indexes_name

        
        private$.nn<-dim(private$.rdata)[1]
        private$.nv<-dim(private$.rdata)[2]
        private$.ndep<-length(dep)
        
      },
      .features=function() {

        tab<-aggregate(private$.rdata[[1]],lapply(private$.indexes_name,function(i) private$.rdata[,i]),length)
        names(tab)[1:length(private$.indexes)]<-private$.indexes_name
        names(tab)[ncol(tab)]<-"Freq"
        tab
      }
      
      )
)
