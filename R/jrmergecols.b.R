jrmergecolsClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "mergeClass",
    inherit=jrmergecolsBase,
    private=list(
        .names=NULL,
        .exnames=NULL,
        .exdata=NULL,
        .commons=NULL,
        .mergedata=NULL,
        .tables=list(),
        .notrun=FALSE,

        .init=function() {
            jinfo("MODULE: init phase started")

            self$results$showdata$setTitle(
                paste0("Data Preview \U1F539 Keep cases [",
                       self$options$type,
                       "] \U1F539 Replicated variables from [",
                       self$options$common, "]"))

            if (nchar(self$options$fleInp)==0) return()

            private$.inspect()

            if (length(private$.commons)==0) {
                private$.notrun=TRUE
                self$results$help$setContent("<h1>Warning</h1>
                                              <div><p>No common variables in the datasets, merging it is not possible.</p></div>")
            }

            atable            <- SmartTable$new(self$results$features)
            atable$initSource <- lapply(private$.commons,function(x) list(var=x))

            private$.tables[["features"]] <- atable

            atable              <- SmartTable$new(self$results$showdata)
            atable$expandOnInit <- TRUE
            atable$expandOnRun  <- TRUE
            atable$expandFrom   <- 2
            .names              <- self$options$varBy

            if (length(.names) > 10)
                .names <- .names[1:10]

            tab <- as.data.frame(matrix(".", ncol=length(.names),nrow=1))

            names(tab)                    <- .names
            atable$initSource             <- tab
            private$.tables[["showdata"]] <- atable

            atable                    <- SmartTable$new(self$results$info)
            atable$initSource         <- private$.infotable
            private$.tables[["info"]] <- atable

            lapply(private$.tables, function(x) x$initTable())
        },

        .postInit=function() {

            if (!is.null(self$results$showdata$state)) {
                atable            <- private$.tables[["showdata"]]
                atable$initSource <- private$.showdata
                atable$initTable()
            }
        },

        .run=function() {
            jinfo("MODULE: run phase started")

            private$.helpmerge()
            if (nchar(self$options$fleInp)==0) return()

            private$.tables[["features"]]$runSource <- private$.features
            private$.tables[["showdata"]]$runSource <- private$.showdata
            private$.tables[["info"]]$runSource     <- private$.infotable

            self$results$showdata$deleteRows()

            lapply(private$.tables, function(x) x$runTable())

            private$.reshape()
        },

        .reshape=function() {
            jinfo("MODULE: reshape phase started")

            if (private$.notrun) return()

            if (self$options$btnReshape) {
                data <- private$.mergedata
                jmvReadWrite:::jmvOpn(dtaFrm=data, dtaTtl= "Untitled")
            }
        },

        .inspect=function() {

            private$.names   <- names(self$data)
            data             <- jmvReadWrite:::read_all(self$options$fleInp)
            sel              <- apply(data, 1, function(x){all(is.na(x))})
            private$.exdata  <- data[!sel,]
            private$.exnames <- names(private$.exdata)
            private$.commons <- intersect(private$.names, private$.exnames)
        },

        .infotable=function() {
            jinfo("MODULE: infotable phase started")

            tab <- list(
                list(text="Variables in this dataset", var=length(private$.names)),
                list(text="Variables in external dataset", var=length(private$.exnames)),
                list(text="Common Variables", var=length(private$.commons)),
                list(text="Matching Variables", var=length(self$options$varBy)),
                list(text="Variables in Merged Dataset"),
                list(text="Cases in Dataset"),
                list(text="Cases in External Dataset"),
                list(text="Cases in Merged Dataset")
            )

            if (dim(self$data)[1] > 0) {

                data  <- self$data
                sel   <- apply(data, 1, function(x){all(is.na(x))})
                .data <- data[!sel,]

                tab[[5]]$var <- dim(private$.mergedata)[2]
                tab[[6]]$var <- dim(.data)[1]
                tab[[7]]$var <- dim(private$.exdata)[1]
                tab[[8]]$var <- dim(private$.mergedata)[1]

                tail(private$.mergedata)
            }

            return(tab)
        },

        .features=function() {

            att1 <- jmvReadWrite:::jmvAtt(self$data)
            att2 <- jmvReadWrite:::jmvAtt(private$.exdata)

            lapply(private$.commons, function(x) {
                list(var=x,
                     lab1=attr(att1[[x]], "measureType"),
                     lab2=attr(att2[[x]], "measureType")
                )
            })
        },

        .merge=function() {
            jinfo("MODULE: merge phase started")

            if (private$.notrun)
                return()

            data <- self$data
            vars <- self$options$varBy

            m    <- lapply(vars, function(x) which(is.na(data[[x]])))
            miss <- unique(unlist(m))
            sel  <- setdiff(seq_len(nrow(data)), miss)
            data <- data[sel,]
            m    <- lapply(vars, function(x) which(is.nan(data[[x]])))
            miss <- unique(unlist(m))
            sel  <- setdiff(seq_len(nrow(data)), miss)

            .data    <- data[sel,]
            .exdata  <- private$.exdata
            .commons <- setdiff(private$.commons,self$options$varBy)

            if (self$options$common=="left")
                .exdata <- .exdata[,!(names(.exdata) %in% .commons) ]

            if (self$options$common=="right")
                .data <- .data[,!(names(.data) %in% .commons) ]

            opts <- list(x=.data, y=.exdata, by=self$options$varBy)
            switch (self$options$type,
                    outer=opts$all   <- TRUE,
                    inner=opts$all   <- FALSE,
                    left =opts$all.x <- TRUE,
                    right=opts$all.y <- TRUE
            )

            private$.mergedata <- do.call(merge, opts)
        },

        .showdata=function() {
            jinfo("MODULE: showdata phase started")

            if (private$.notrun)
                return()

            private$.merge()
            data <- self$results$showdata$state

            if (is.null(data)) {
                obj  <- self
                data <- private$.mergedata

                nl       <- 20 # number of lines displayed (edit if you prefer)

                data$row <- 1:dim(data)[1]
                nr       <- nrow(data)
                nrs      <- min(nl, nr)
                nc       <- ncol(data)
                ncs      <- min(10, nc)
                cols     <- 1:ncs

                if (nr > nl)
                    warning("(Last selection) There are ", nr-nl, " more rows in the dataset not shown here\n")

                if (nc > 10) {
                    warning("There are ", nc-10, " more colums in the dataset not shown here\n")
                    cols <- c(nc, 1:ncs)
                }

                data <- data[1:nrs, cols]
                if (nr > nl)
                    try_hard(data[nrs+1,] <- rep("...",nc))

                self$results$showdata$setState(data)
            }

            return(data)
        },

        .helpmerge=function() {

            hlpFles <- paste(
                '<h2>Getting started</h2><div style=\"text-align:justify\">',
                '<h2>&#x1F4C2 Select file ...</h2><hr>',
                '<ol><li>Please, assign one or more variables that appear in all data sets to Matching Variables <b>(ID variables)</b></li>',
                '<li>You can merge columns from a file into the current dataset by using the <b>Select file ...</b> button or by typing the full path and name of the file.</li></ol><br/>',
                '<svg width=\"130pt\" height=\"30pt\">',
                '<rect width=\"30\" height=\"30\" fill=\"#2E6CB9\">',
                '<animate attributeName=\"rx\" values=\"0;15;0\" dur=\"2s\" repeatCount=\"3\"/></rect>',
                '<circle cx=\"15\" cy=\"15\" r=\"12\" stroke=\"#2E6CB9\" stroke-width=\"1\" fill=\"{color}\"/>',
                '<text x=\"35\" y=\"20\" font-size=\"130%\" fill=\"#2E6CB9\" style=\"text-anchor: start;\">',
                'File Merged:</text></svg><h3>{file}</h3><hr>')

            if(nchar(self$options$fleInp) == 0) {
                private$.notrun=TRUE
                hlp <- jmvcore::format(hlpFles,
                                       color='Tomato',
                                       file ='&#x1F4A2 Not Select')
            } else
                hlp <- jmvcore::format(hlpFles,
                                       color='MediumSeaGreen',
                                       file=self$options$fleInp)

            if(length(self$options$varBy) == 0) {
                private$.notrun=TRUE
                hlp <- paste0(hlp,
                              '<h3>&#x1F4A2 Matching variables not selected ...</h2>')
            } else if(nchar(self$options$fleInp) > 0)
                hlp <- paste0(hlp,
                             '<h2>&#x1F4C1 Reshape</h2>
                              You can open the modified data set in a new jamovi window, using the <b>Reshape</b> button')

            self$results$help$setContent(hlp)
        }
    )
)
