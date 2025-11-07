savedata<-function(obj,data,title="Untitled", option="reshape") {

    for (x in names(data)) {
      if (inherits(data[[x]],"numeric")) {
       vec<-na.omit(data[[x]])
       test<-all(vec==round(vec))
       if (test) 
         data[[x]]<-as.integer(data[[x]])
      }
    }

  option<-obj$options$option(option)
  
  if (is.null(option$perform)) {
    ## old style
    .saverfun <- function(data,title) {
      jmvReadWrite:::jmvOpn(dtaFrm = data, dtaTtl = title)
    }
  } else {
    # new style
    .saverfun <- function(data,title) {
      
      option$perform(function(action) {
        list(
          data = data,
          title = title)
      })
    }
  } ### end
  
  .saverfun(data,title)
  
}

showdata<-function(obj,data) {

    nl<-50
    data$row<-1:dim(data)[1]
    nr<-nrow(data)
    nrs<-min(nl,nr)
    nc<-ncol(data)
    ncs<-min(10,nc)
    cols<-1:ncs
    if (nr>nl) warning("There are ",nr-nl," more rows in the dataset not shown here\n")
    if (nc>10) { warning("There are ",nc-10," more colums in the dataset not shown here\n")
        cols<-c(nc,1:ncs)
    }
    data<-data[1:nrs,cols]
    if (nr>nl)
        try_hard(data[nrs+1,]<-rep("...",nc))
    data

}
