
# This file is a generated template, your changes will not be overwritten

complex2longClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "complex2longClass",
    inherit = complex2longBase,
    private = list(
      # this is a list that contains all the SmartTables
      .tables=list(),
      .runcreate=FALSE,
      .rdata=NULL,
      .time="index",
      .index=NULL,
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
        index<-self$options$index
        index<-index[unlist(lapply(index,function(x) is.something(trimws(x$var))))]
        index<-index[unlist(lapply(index,function(x) is.something(x$levels)))]
        
        private$.index<-index

        if (length(index)==1 & index[[1]]$levels>0) {
          help<-paste("<h1>Help</h1><div>Index variable",index[[1]]$var,"defined levels are ignored. The number of 
                               Columns to rows variables is used instead.
                              </div>")
          self$results$help$setContent(help)
        }
          
        if (length(index)>1) {
          tot<-prod(unlist(lapply(index,function(x) as.numeric(x$levels))))
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
        private$.tables[["features"]]<-atable
        
        
        lapply(private$.tables,function(x) x$initTable())          
        
        
      },
      .run = function() {
    
        jinfo("MODULE: run phase started")

        if (private$.notrun)    return()
        
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
        ladd(atab)<-list(text="Cols to rows",var=length(self$options$colstorows))
        ladd(atab)<-list(text="Target variables",var=private$.ndep)
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
             q<-system2(cmd,args=afilename,stderr = T,stdout = T)     
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
        
        private$.on<-dim(self$data)[1]
        private$.ov<-dim(self$data)[2]
        
        dep<-unlist(lapply(self$options$colstorows,function(x) x$label))
        colstorows<-unlist(lapply(self$options$colstorows,function(x) x$vars))
        
        time="index"
        index<-private$.index
        if (length(index)==1)
             time<-index[[1]]$var
        
        if (!is.something(time))
            time<-"index"
        if (length(index)>1)
              time<-".index."
        
            
        id<-"id"
        private$.time<-time
        private$.rdata<-reshape(self$data,varying = colstorows, v.names=dep,direction="long", timevar = time)
        private$.rdata<-private$.rdata[order(private$.rdata[[id]]),]
        
        if (length(index)>1) {
          grid<-expand.grid(lapply(index,function(x) 1:as.numeric(x$levels)))
          .names<-unlist(lapply(index,function(x) x$var))
          if (length(grep(".index.",.names,fixed=T))>0) stop("'.index.' is a reserved word, please choose another name for your index variables")
          names(grid)<-.names
          tdata<-as.data.frame(do.call(rbind,lapply(1:private$.on,function(i) grid)))
          private$.rdata<-as.data.frame(cbind(tdata,private$.rdata))
        }
        
        private$.nn<-dim(private$.rdata)[1]
        private$.nv<-dim(private$.rdata)[2]
        private$.ndep<-length(dep)
        
      },
      .features=function() {
        atab<-table(private$.rdata[[private$.time]])
        tab<-as.data.frame(atab)
        attr(tab,"titles")<-c(Var1=private$.time)
        tab
      }
      
      )
)
