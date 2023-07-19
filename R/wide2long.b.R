

wide2longClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
  "wide2longClass",
  inherit = wide2longBase,
  private = list(
    # this is a list that contains all the SmartTables
    .tables=list(),
    .runcreate=FALSE,
    .rdata=NULL,
    .colstorows=NULL,
    .deps=NULL,
    .indexes=NULL,
    .indexes_name=NULL,
    .covs=NULL,
    .on=NULL,
    .ov=NULL,
    .nn=NULL,
    .nv=NULL,
    .ndep=NULL,
    .notrun=FALSE,
    .message=NULL,
    .init= function() {
      
      jinfo("MODULE: init phase started")

      if (self$options$mode=="complex") {
        private$.deps<-lapply(self$options$comp_colstorows,function(x) x$label)
        private$.colstorows<-lapply(self$options$comp_colstorows,function(x) x$vars)
        indexes<-self$options$comp_index
        indexes<-indexes[unlist(lapply(indexes,function(x) is.something(trimws(x$var))))]
        indexes<-indexes[unlist(lapply(indexes,function(x) is.something(x$levels)))]
        private$.indexes<-indexes
        private$.indexes_name<-unlist(lapply(indexes,function(x) x$var))
        private$.covs<-self$options$comp_covs
          
      }
      if (self$options$mode=="simple") {
        private$.deps<-list(self$options$sim_dep)
        private$.colstorows<-list(self$options$sim_colstorows)
        private$.indexes<-list(list(var=self$options$sim_index,levels=0))
        private$.indexes_name<-self$options$sim_index
        private$.covs<-self$options$sim_covs
        
      }
        if (self$options$mode=="simple")
                   self$results$desc$setContent(HELP_simple2long[[1]])
        if (self$options$mode=="complex")
                   self$results$desc$setContent(HELP_complex2long[[1]])


      if (!is.something(private$.indexes_name)) private$.indexes_name<-"index"
      
      test<-any(unlist(lapply(private$.deps,function(x) !is.something(x))))
      if (test)  {
        private$.message<-"<h2>Help</h2><div>Please give a name to the long format target variable</div>"
        private$.notrun=TRUE
        return()
      }  
      test<-any(unlist(lapply(private$.colstorows,function(x) !is.something(x))))
      if (test) {
        private$.message<-"<h2>Help</h2><div>Please fill in the columns variables that will go in the long format target variables</div>"
        private$.notrun=TRUE
        return()
      }
      ns<-unlist(lapply(private$.colstorows, function(x) length(x)))
      if (length(private$.deps)>1)
        if (var(ns)!=0)  {
          private$.message<-"<h2>Help</h2><div>Levels should be the same across target variables. 
                              </div>"
          private$.notrun=TRUE
          return()
        }  
      
      tot<-prod(unlist(lapply(private$.indexes,function(x) as.numeric(x$levels))))
      ref<-ns[1]
      if (length(private$.indexes)>1) {
        if (tot!=ref) {
          private$.message<-paste("<h2>Help</h2><div>The combination (product) of the index variables levels should be equal
                            to the number of levels defined in the `Columns to rows` setup.
                              </div>")
          private$.notrun=TRUE
          return()
        }
      }
      if (length(private$.indexes)==1 &  tot!=ref & tot>0) {
        private$.message<-paste("<h2>Help</h2><div>Index variable",private$.indexes[[1]]$var,"defined levels are ignored. The number of 
                               Columns to rows variables is used instead.
                              </div>")
      }
      
      jinfo("MODULE: init check phase ended")
      # set up the coefficients SmartTable
      atable<-SmartTable$new(self$results$info)
      private$.tables[["info"]]<-atable
      atable<-SmartTable$new(self$results$features)
      atable$expandOnRun<-TRUE
      private$.tables[["features"]]<-atable
      atable<-SmartTable$new(self$results$showdata)
      atable$expandOnRun<-TRUE
      atable$expandFrom<-2
      private$.tables[["showdata"]]<-atable
      lapply(private$.tables,function(x) x$initTable())          
      jinfo("MODULE: init ended")
      
    },
    .run = function() {
      
      jinfo("MODULE: run phase started")

      self$results$help$setContent(" ")      
      if (is.something(private$.message)) self$results$help$setContent(private$.message)      
      if (private$.notrun)    return()

      private$.reshape()
      private$.tables[["info"]]$runSource<-private$.infotable
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
      ladd(atab)<-list(text="Cols to rows",var=length(unlist(private$.colstorows)))
      ladd(atab)<-list(text="Target variables",var=private$.ndep)
      ladd(atab)<-list(text="Fixed variables",var=length(private$.covs))
      
      return(atab)
    },
    
    .reshape=function() {
      vars<-c(unlist(private$.colstorows),unlist(private$.covs))
      data<-subset(self$data,select=vars)
  
      private$.on<-dim(self$data)[1]
      private$.ov<-dim(self$data)[2]
      
      dep<-unlist(private$.deps)
      colstorows<-private$.colstorows
      if (length(colstorows)==1) colstorows<-unlist(colstorows)

      indexes<-private$.indexes
      id<-"id"
      private$.rdata<-reshape(data,varying = colstorows, v.names=dep,direction="long", timevar = "int.index.")
      private$.rdata<-private$.rdata[order(private$.rdata[[id]]),]

      if (length(indexes)>1) {
        grid<-expand.grid(lapply(indexes,function(x) 1:as.numeric(x$levels)))
        if (length(grep("int.index.",private$.indexes_name,fixed=T))>0) stop("'int.index.' is a reserved word, please choose another name for your index variables")
        tdata<-as.data.frame(do.call(rbind,lapply(1:private$.on,function(i) grid)))
        private$.rdata<-as.data.frame(cbind(tdata,private$.rdata))
        names(private$.rdata)[1:length(private$.indexes_name)]<-private$.indexes_name
        private$.rdata[["int.index."]]<-NULL
      } else   names(private$.rdata)[names(private$.rdata)=="int.index."]<-private$.indexes_name
      
      private$.rdata[[id]]<-factor(private$.rdata[[id]])
      private$.nn<-dim(private$.rdata)[1]
      private$.nv<-dim(private$.rdata)[2]
      private$.ndep<-length(dep)
      
    },
    .features=function() {

      tab<-aggregate(private$.rdata[[1]],lapply(private$.indexes_name,function(i) private$.rdata[,i]),length)
      names(tab)[1:length(private$.indexes)]<-private$.indexes_name
      names(tab)[ncol(tab)]<-"Freq"
      for (i in seq_along(private$.colstorows)) tab[[private$.deps[[i]]]]<-private$.colstorows[[i]]
      tab
    },
    .showdata=function() {
      savedata(self,private$.rdata)
      showdata(self,private$.rdata)
      
    }
    
    
  )
)