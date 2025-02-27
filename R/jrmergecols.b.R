jrmergecolsClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "mergeClass",
    inherit=jrmergecolsBase,
    private=list(
        .names=NULL,            # Column names of the main dataset
        .exnames=NULL,          # Column names of the external datasets
        .exdata=NULL,           # Combined data from external files
        .commons=NULL,          # Common variables between datasets
        .mergedata=NULL,        # Final merged dataset
        .tables=list(),         # Tables for UI display
        .notrun=FALSE,          # Flag to indicate whether the process should run
        .merge_util=NULL,       # Instance of MzMergeUtils

        # Initialization phase
        .init=function() {
            set_logflags(self$options$jlog)  # Update logging flags
            jinfo("[.init] phase started")

            # Set title for the data preview table
            self$results$showdata$setTitle(
                paste0("Data Preview \U1F539 Keep cases [",
                       self$options$type,"]"))

            if (nchar(self$options$fleInp)==0) return()

            private$.inspect()

            # If no common variables, show warning
            if (length(private$.commons)==0) {
                private$.notrun=TRUE
                jinfo("[.init] No common variables in the datasets, merging it is not possible")
                self$results$help$setContent("<h1>Warning</h1>
                                              <div><p>No common variables in the datasets, merging it is not possible.</p></div>")
            }

            # Initialize features table
            atable            <- SmartTable$new(self$results$features)
            atable$initSource <- lapply(private$.commons,function(x) list(var=x))
            private$.tables[["features"]] <- atable

            # Initialize showdata table
            atable              <- SmartTable$new(self$results$showdata)
            atable$expandOnInit <- TRUE
            atable$expandOnRun  <- TRUE
            atable$expandFrom   <- 2
            .names              <- self$options$varBy

            if (length(.names) > 10)
                .names <- .names[1:10]

            tab <- as.data.frame(matrix(".", ncol=length(.names), nrow=1))

            names(tab)                    <- .names
            atable$initSource             <- tab
            private$.tables[["showdata"]] <- atable

            # Initialize info table
            atable                    <- SmartTable$new(self$results$info)
            atable$initSource         <- private$.infotable
            private$.tables[["info"]] <- atable

            # Initialize all tables
            lapply(private$.tables, function(x) x$initTable())

            jinfo("[.init] phase ended")
        },

        .inspect=function() {
            jinfo("[.inspect] phase started")

            # Split and clean file paths
            files <- strsplit(self$options$fleInp, ";")[[1]]
            files <- trimws(files)  # Remove leading and trailing whitespace

            # Initialize variables
            private$.names   <- names(self$data)
            private$.exdata  <- list()  # Store all external datasets
            private$.exnames <- NULL    # Combined names of all external datasets

            # Process each file
            datasets <- lapply(files, function(file) {
                if (!file.exists(file)) {
                    mzstop <- sprintf("File \"%s\" not found.", file)
                    jinfo("[.inspect]", mzstop)
                    stop(mzstop)
                }
                jmvReadWrite:::read_all(file)
            })

            # Find all unique column names across datasets
            all_columns <- unique(unlist(lapply(datasets, names)))

            # Ensure all datasets have the same columns
            datasets <- lapply(datasets, function(ds) {
                missing_cols <- setdiff(all_columns, names(ds))
                if (length(missing_cols) > 0) {
                    for (col in missing_cols) {
                        ds[[col]] <- NA  # Add missing columns with NA values
                    }
                }
                ds <- ds[, all_columns, drop = FALSE]  # Reorder columns to match
                return(ds)
            })

            # Combine all external datasets
            private$.exdata  <- do.call(rbind, datasets)
            private$.exnames <- names(private$.exdata)
            private$.commons <- intersect(private$.names, private$.exnames)

            jinfo("[.inspect] phase ended")
        },

        # Post-initialization phase
        .postInit=function() {
            jinfo("[.postInit] phase started")
            if (!is.null(self$results$showdata$state)) {
                atable            <- private$.tables[["showdata"]]
                atable$initSource <- private$.showdata
                atable$initTable()
            }
            jinfo("[.postInit] phase ended")
        },

        # Run phase
        .run = function() {
            set_logflags(self$options$jlog)  # Update logging flags
            jinfo("[.run] phase started")

            private$.helpmerge()

            if (!nzchar(self$options$fleInp)) {
                jinfo("[.run] No external files specified.")
                return()
            } else if (is.null(self$data) || nrow(self$data) == 0) {
                jinfo("[.run] Dataset is empty or NULL.")
                return()
            } else if (is.null(self$options$varBy) || length(self$options$varBy) == 0) {
                jinfo("[.run] No matching variables specified.");
                return()
            }

            files <- strsplit(self$options$fleInp, ";")[[1]]
            files <- trimws(files)
            if (any(!file.exists(files))) {
                mzstop <- sprintf("One or more files not found: %s", paste(files[!file.exists(files)], collapse = ", "))
                jinfo("[.run]", mzstop)
                stop(mzstop)
            }

            if (is.null(private$.merge_util)) {
                private$.merge_util <- tryCatch({
                    MzMergeUtils$new(
                        dataset = self$data,
                        external_files = paste(files, collapse = ";"),
                        match_vars = self$options$varBy,
                        join_type = self$options$type
                    )
                }, error = function(e) {
                    mzstop <- sprintf("Error initializing MzMergeUtils: %s", e$message)
                    jinfo("[.run]", mzstop)
                    stop(mzstop)
                })
            }

            private$.mergedata <- tryCatch({
                private$.merge_util$get_data()
            }, error = function(e) {
                mzstop <- sprintf("Error during merge execution: %s", e$message)
                jinfo("[.run]", mzstop)
                stop(mzstop)
            })

            private$.tables[["features"]]$runSource <- private$.features
            private$.tables[["showdata"]]$runSource <- private$.showdata
            private$.tables[["info"]]$runSource     <- private$.infotable

            self$results$showdata$deleteRows()
            lapply(private$.tables, function(x) x$runTable())

            # Check if the showMergeReport option is enabled
            if (self$options$showMergeReport) {
                self$results$mergeReport$setVisible(TRUE)

                # Use MzMergeUtils to generate the report content
                report_content <- tryCatch({
                    private$.merge_util$generateReport()
                }, error = function(e) {
                    mzstop <- sprintf("Error generating report: %s", e$message)
                    jinfo("[.run]", mzstop)
                    stop(mzstop)
                })
                self$results$mergeReport$setContent(report_content)
            } else {
                # Hide the mergeReport output if the option is disabled
                self$results$mergeReport$setVisible(FALSE)
            }

            private$.reshape()
            jinfo("[.run] phase ended")
        },

        # Reshape phase
        .reshape = function() {
            jinfo("[.reshape] phase started")

            if (private$.notrun || is.null(private$.mergedata)) {
                jinfo("[.reshape] No merged data available or notrun. Skipping reshape.")
                return()
            }

            # Open the dataset in a new Jamovi instance if requested
            if (self$options$btnReshape) {
                tryCatch({
                    jmvReadWrite:::jmvOpn(dtaFrm = private$.mergedata, dtaTtl = "Merged Dataset")
                    jinfo("[.reshape] Merged dataset opened in a new Jamovi instance.")
                }, error = function(e) {
                    mzstop <- sprintf("Error opening dataset: %s", e$message)
                    jinfo("[.reshape]", mzstop)
                    stop(mzstop)
                })
            } else {
                jinfo("[.reshape] Reshape not requested. Skipping.")
            }

            jinfo("[.reshape] phase ended")
        },

        # Info table generation
        .infotable=function() {
            jinfo("[.infotable] phase started")

            tab <- list(
                list(text="External files to merge", var=self$options$nfiles),
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
                sel   <- apply(data, 1, function(x) { all(is.na(x)) })
                .data <- data[!sel, ]

                tab[[6]]$var <- dim(private$.mergedata)[2]
                tab[[7]]$var <- dim(.data)[1]
                tab[[8]]$var <- dim(private$.exdata)[1]
                tab[[9]]$var <- dim(private$.mergedata)[1]

                tail(private$.mergedata)
            }
            jinfo("[.infotable] phase ended")

            return(tab)
        },

        .features = function() {
            jinfo("[.features] phase started")

            # Verify that private$.merge_util is properly initialized
            if (is.null(private$.merge_util) || !inherits(private$.merge_util, "MzMergeUtils")) {
                stop("[.features] MzMergeUtils is not properly initialized.")
            }

            # Retrieve features using get_features() method
            features <- private$.merge_util$get_features()

            # Format the data for the table
            features <- lapply(features, function(f) {
                # Verify that the data is correctly structured
                if (!"labs" %in% names(f) || length(f$labs) < self$options$nfiles) {
                    stop(sprintf("[.features] Missing or invalid 'labs' for variable '%s'.", f$var))
                }

                # Populate the table columns
                list(
                    var = f$var,
                    lab = f$lab,
                    lab1 = ifelse(self$options$nfiles >= 1, f$labs[[1]], NA),
                    lab2 = ifelse(self$options$nfiles >= 2, f$labs[[2]], NA),
                    lab3 = ifelse(self$options$nfiles >= 3, f$labs[[3]], NA)
                )
            })

            jinfo("[.features] phase ended")
            return(features)
        },

        .showdata = function() {
            jinfo("[.showdata] phase started")

            if (private$.notrun) return()

            # [Final data] Here should be all the variables merged
            private$.mergedata
            data <- self$results$showdata$state

            if (is.null(data)) {
                obj <- self
                data <- private$.mergedata

                nl <- 20 # number of lines displayed (edit if you prefer)

                data$row <- 1:dim(data)[1]
                nr <- nrow(data)
                nrs <- min(nl, nr)
                nc <- ncol(data)
                ncs <- min(15, nc)
                cols <- 1:ncs

                if (nr > nl)
                    warning("(Last selection) There are ", nr - nl, " more rows in the dataset not shown here\n")

                if (nc > 15) {
                    warning("There are ", nc - 15, " more columns in the dataset not shown here\n")
                    cols <- c(nc, 1:ncs)
                }

                data <- data[1:nrs, cols]
                if (nr > nl)
                    try_hard(data[nrs + 1, ] <- rep("...", nc))

                self$results$showdata$setState(data)
            }
            mark("[.showdata] Returned data", head(data))
            jinfo("[.showdata] phase ended")
            return(data)
        },

        .helpmerge = function() {
            jinfo("[.helpmerge] phase started")

            hlpFles <- paste(
                '<h2>Getting started</h2><div style=\"text-align:justify\">',
                '<h2>&#x1F4C2 Select file ...</h2><hr>',
                '<ol><li>Please, assign one or more variables that appear in all data sets to Matching Variables <b>(ID variables)</b></li>',
                '<li>You can merge columns from a file into the current dataset by using the <b>Select file ...</b> button (<b>Ctrl+F</b>) or by typing the full path and name of the file.</li></ol><br/>',
                '<svg width=\"130pt\" height=\"30pt\">',
                '<rect width=\"30\" height=\"30\" fill=\"#2E6CB9\">',
                '<animate attributeName=\"rx\" values=\"0;15;0\" dur=\"2s\" repeatCount=\"3\"/></rect>',
                '<circle cx=\"15\" cy=\"15\" r=\"12\" stroke=\"#2E6CB9\" stroke-width=\"1\" fill=\"{color}\"/>',
                '<text x=\"35\" y=\"20\" font-size=\"130%\" fill=\"#2E6CB9\" style=\"text-anchor: start;\">',
                'File Merged:</text></svg><h3>{file}</h3><hr>')

            fileList <- gsub(";", "<br>", self$options$fleInp)

            if(nchar(self$options$fleInp) == 0) {
                private$.notrun=TRUE
                hlp <- jmvcore::format(hlpFles, color='Tomato', file ='&#x1F4A2 Not Select')
            } else {
                hlp <- jmvcore::format(hlpFles, color='MediumSeaGreen', file=fileList)
            }

            if(length(self$options$varBy) == 0) {
                private$.notrun=TRUE
                hlp <- paste0(hlp,'<h3>&#x1F4A2 Matching variables not selected ...</h2>')
            } else if(nchar(self$options$fleInp) > 0) {
                hlp <- paste0(hlp,
                              '<h2>&#x1F4C1 Reshape</h2>',
                              'Open the modified data set in a new jamovi window, using the <b>Reshape</b> button (<b>Ctrl+R</b>)')
            }

            self$results$help$setContent(hlp)
            jinfo("[.helpmerge] phase ended")
        }
    )
)
