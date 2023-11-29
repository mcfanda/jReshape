
# This file is a generated template, your changes will not be overwritten

long2wideClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "long2wideClass",
    inherit = long2wideBase,
    private = list(
      # this is a list that contains all the SmartTables
      .tables=list(),
      .rdata=NULL,
      .time="time",
      .on=NULL,
      .ov=NULL,
      .nn=NULL,
      .nv=NULL,
      .nc=NULL,
      .wnames=NULL,
      .labs=NULL,
      .notrun=FALSE,
      .init= function() {

        jinfo("MODULE: init phase started")
        
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
  

        self$results$help$setContent(HELP_long2wide[[4]])

        # check some info from the data 
        indexes<-self$options$index
        
        nl<-lapply(indexes, function(x) levels(self$data[[x]]))
        wnames<-lapply(self$options$rowstocols, function(x) combine(nl,prefix = x))
        private$.wnames<-unlist(wnames)
        labs<-lapply(indexes, function(x) paste(x,levels(self$data[[x]]),sep="="))
        private$.labs<-paste0(levels(interaction(labs, sep = " ")))

        # set up the coefficients SmartTable
        atable<-SmartTable$new(self$results$info)
        atable$initSource<-private$.infotable
        private$.tables[["info"]]<-atable
      
        atable<-SmartTable$new(self$results$features)
        atable$initSource<-private$.features
        private$.tables[["features"]]<-atable

        atable<-SmartTable$new(self$results$showdata)
        atable$expandOnInit<-TRUE
        atable$expandFrom<-2
        .names<-unlist(c(self$options$id,private$.wnames,self$options$covs))
        tab<-as.data.frame(matrix(".",ncol = length(.names),nrow = 1))
        names(tab)<-.names
        atable$initSource<-tab
        private$.tables[["showdata"]]<-atable
        lapply(private$.tables,function(x) x$initTable())          
        
        
      },
      .postInit = function() {
        if ( ! is.null(self$results$showdata$state)) {
          atable <- private$.tables[["showdata"]]
          atable$initSource <- private$.showdata
          atable$initTable()
         }
        },

      .run = function() {
    
        jinfo("MODULE: run phase started")

        if (private$.notrun)
          return()
        
        private$.reshape()
        private$.tables[["info"]]$runSource<-private$.infotable
        private$.tables[["features"]]$runSource<-private$.features
        private$.tables[["showdata"]]$runSource<-private$.showdata
        
        lapply(private$.tables,function(x) x$runTable())          
        
        if (self$options$reshape)
          savedata(self,private$.rdata)
        
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
        
        vars<-c(self$options$id,self$options$rowstocols,self$options$index,self$options$covs)
        data<-subset(self$data,select=vars)
        
        private$.on<-dim(data)[1]
        private$.ov<-dim(data)[2]

        ## gather variables names
        id<-self$options$id
        data$id.<-as.numeric(data[[id]])
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
        
        ## here we handle possible missing values
        levs<-combine(nl,sep = "_",sep0 = "")
        alllevels<-as.data.frame(do.call("rbind",lapply(unique(data$id.), function(x) cbind(id.=x,int.index.=levs))))
        alllevels$id.<-as.numeric(alllevels$id.)

        data<-merge(data,alllevels,by=c("id.","int.index."),all.y = T)
        ## reshape
        private$.rdata<-reshape(data,
                                v.names=deps,
                                direction="wide", 
                                timevar = "int.index.",
                                idvar = "id.",
                                drop=indexes)
        
        private$.rdata<-private$.rdata[order(private$.rdata$id.),]
        private$.rdata$id.<-NULL
        rownames(private$.rdata)<-NULL
        
        private$.rdata<-private$.rdata[rowSums(is.na(private$.rdata))<(ncol(private$.rdata)),]
        .names<-unlist(c(self$options$id,self$options$covs,wnames))
        private$.rdata<-private$.rdata[,.names]
        ## set the new variables labels,
        attr(private$.rdata,"variable.labels")<-labs
        ## gather some info
        private$.on<-dim(self$data)[1]
        private$.ov<-dim(self$data)[2]
        private$.nn<-dim(private$.rdata)[1]
        private$.nv<-dim(private$.rdata)[2]
        
      },
      .features=function() {
        tab<-as.data.frame(cbind(private$.wnames,private$.labs))
        names(tab)<-c("var","lab")
        tab
      },
      .showdata=function() {
        data <- self$results$showdata$state
        if (is.null(data)) {
          data <- showdata(self,private$.rdata)
          self$results$showdata$setState(data)
        }
        data
      }
      
      
      )
)
