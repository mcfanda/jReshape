jrmergecolsClass <- if (requireNamespace('jmvcore', quietly=TRUE)) R6::R6Class(
    "mergeClass",
    inherit = jrmergecolsBase,
    private = list(
        .fleInp = NULL,
        .mrgDta = NULL,
        .notrun = FALSE,

        .init = function() {
            jinfo("___ Start INIT ___")

            self$results$help$setContent("  ")

            test <- (!is.something(self$options$varBy))
            if (test) {
                self$results$help$setContent(HELP_mergecols[[1]])
                private$.notrun=TRUE
                return()
            }

            self$results$pvwDta$setTitle(paste0("Data Preview \U1F539 Merging Operation Type [",
                                  self$options$typMrg, "]"))

            if (private$.chkVar()) {
                # prepare output table
                private$.mrgDta <- do.call(jmvReadWrite::merge_cols_omv, private$.crrArg())

                seqRow <- seq(self$results$pvwDta$rowCount + 1, min(dim(private$.mrgDta)[1], maxRow))
                seqCol <- seq(ifelse(useIdx, 1, 2), min(dim(private$.mrgDta)[2], maxCol))

                colNme <- names(private$.mrgDta)
                if (length(private$.colFst()) > 0) {
                    if (!all(private$.colFst() == colNme[seq_along(private$.colFst())], na.rm = TRUE)) {
                        # fmtFsC is defined in constants.R
                        self$results$pvwDta$setNote("Note",
                                           sprintf(fmtFsC,
                                                   ifelse(length(private$.colFst()) > 1, "s", ""),
                                                   paste0(private$.colFst(), collapse = ", "),
                                                   ifelse(length(private$.colFst()) > 1, "are", "is")))
                    }
                    colNme <- unique(c(private$.colFst(), colNme))
                }
                # create a list vector with empty entries (to be assigned when adding a new row),
                # change title for the first column (if useIdx is FALSE) and add further columns
                # and rows to the current table
                valRow <- stats::setNames(as.list(rep("", length(seqCol) + 1)),
                                          c("fstCol", colNme[seqCol]))

                if (!useIdx)
                    self$results$pvwDta$getColumn(1)$setTitle(colNme[1])

                for (i in seqCol)
                    self$results$pvwDta$addColumn(name = colNme[i], title = colNme[i])

                for (i in seqRow)
                    self$results$pvwDta$addRow(rowKey = i, values = valRow)

                return(invisible(NULL))

            } else {
                # reset output table
                numRow <- self$results$pvwDta$rowCount
                colNme <- names(self$results$pvwDta$columns)

                self$results$pvwDta$deleteRows()
                for (i in seq(numRow))
                    self$results$pvwDta$addRow(rowKey = i,
                                     stats::setNames(as.list(rep("", length(colNme))), colNme))
            }
        },

        .run = function() {
            jinfo("___ Start RUN ___")

            if (private$.notrun) {
                return()
            }

            if (private$.chkVar() && dim(self$data)[1] >= 1) {

                if (self$options$btnRes) {
                    do.call(jmvReadWrite::merge_cols_omv, private$.crrArg()[-2])
                } else {
                    hlpSvg <- jmvcore::format(HELP_mergecols[[3]], file = paste0(private$.fleInp, collapse = "<br/>"))
                    self$results$help$setContent(hlpSvg)

                    dtaRow <- dim(private$.mrgDta)[1]
                    dtaCol <- dim(private$.mrgDta)[2] + ifelse(useIdx, 1, 0)
                    pvwRow <- self$results$pvwDta$rowCount
                    pvwCol <- length(self$results$pvwDta$columns)
                    pvwClN <- vapply(self$results$pvwDta$columns, "[[", character(1), "title", USE.NAMES = FALSE)

                    if (useIdx) {
                        private$.mrgDta <- cbind(data.frame(fstCol = seq(pvwRow)), private$.mrgDta[seq(pvwRow), pvwClN[-1]])
                    } else {
                        private$.mrgDta <- private$.mrgDta[seq(pvwRow), pvwClN]
                    }

                    cnvCol <- vapply(private$.mrgDta, is.factor, logical(1))
                    private$.mrgDta[, cnvCol] <- sapply(private$.mrgDta[, cnvCol], as.character)
                    if (pvwCol < dtaCol)
                        private$.mrgDta[, pvwCol] <- "..."

                    for (i in seq(pvwRow)) {

                        if (useIdx) {
                            crrRow <- as.list(private$.mrgDta[i, ])
                        } else {
                            crrRow <- stats::setNames(as.list(private$.mrgDta[i, ]), c("fstCol", names(private$.mrgDta)[-1]))
                        }

                        crrRow[vapply(crrRow, is.na, logical(1))] <- ""
                        if (i == pvwRow && pvwRow < dtaRow)
                            crrRow[-1] <- "..."

                        self$results$pvwDta$setRow(rowNo = i, crrRow)
                        # fmtAdC and fmtAdR are defined in constants.R
                        if (i == 1 && pvwCol < dtaCol)
                            self$results$pvwDta$addFootnote(pvwCol,
                                                            sprintf(fmtAdC, dtaCol - pvwCol), rowNo = i)

                        if (i == pvwRow && pvwRow < dtaRow)
                            self$results$pvwDta$addFootnote(1,
                                                            sprintf(fmtAdR, dtaRow - pvwRow), rowNo = i)
                    }
                }

            } else {
                self$results$help$setContent(HELP_mergecols[[2]])

            }
        },

        ## ----------------------------------------------------------
        # Credits for Sebastian Jentschke.
        # https://github.com/sjentsch/jTransform/blob/main/R/utils.R
        # Some of these functions are used here, with some changes.
        ## ----------------------------------------------------------
        .chkFle = function(crrFle = "") {
            jinfo("___ .chkFle Start ___")

            # mulTFle is defined in constants.R
            if (!file.exists(crrFle) || !jmvReadWrite:::hasExt(crrFle, mulTFle)) {
                jmvcore::reject(
                    jmvcore::format("'{file}' doesn't exists or has an unsupported file type.",
                                    file = crrFle), code='')
            }

            retfle <- file.path(normalizePath(crrFle), fsep = .Platform$file.sep)
            return(retfle)
        },

        .chkVar = function() {
            jinfo("___ .chkVar Start ___")

            if (!is.null(self$options$fleInp) &&
                !is.null(private$.fleInp)     &&
                all(vapply(private$.fleInp,
                           grepl,
                           logical(1),
                           self$options$fleInp))) {

                return(length(self$options$varBy) > 0)

            } else if (!is.null(self$options$fleInp) && nzchar(self$options$fleInp)) {
                private$.fleInp <-
                    vapply(trimws(strsplit(self$options$fleInp, ";")[[1]]),
                           private$.chkFle,
                           character(1),
                           USE.NAMES = FALSE)

                return(length(self$options$varBy) > 0)
            } else {
                private$.fleInp <- NULL
                return(FALSE)
            }
        },

        .colFst = function() {
            jinfo("___ .colFst Start ___")

            colNme <- names(private$.mrgDta)
            colBy  <- self$options$varBy
            colDta <- setdiff(names(self$data), colBy)
            colMrg <- setdiff(colNme, c(colBy, colDta))
            numOth <- (maxCol - length(colBy))
            numHlO <- numOth / 2
            numDta <- length(colDta)
            numMrg <- length(colMrg)
            numOfs <- ifelse(length(colNme) > maxCol, 1, 0)
            if (all(c(numDta, numMrg) >= numHlO)) {
                c(colBy, colDta[seq(floor(numHlO))], colMrg[seq(ceiling(numHlO))])
            } else if (numDta >= numHlO) {
                c(colBy, colDta[seq(numOth - numMrg - numOfs)], colMrg)
            } else if (numMrg >= numHlO) {
                c(colBy, colDta, colMrg[seq(numOth - numDta - numOfs)])
            } else {
                c(colBy, colDta, colMrg)
            }
        },

        .crrArg = function() {
            jinfo("___ .crrArg Start ___")

            if (!is.null(self$data) && dim(self$data)[1] > 0) dtaFrm <- self$data else dtaFrm <- self$readDataset()
            attr(dtaFrm, "fleInp") <- private$.fleInp
            list(dtaInp = dtaFrm, fleOut = NULL, varBy = self$options$varBy, typMrg = self$options$typMrg)
        },

        .fmtSrc = function(fcnNme = "", crrArg = NULL) {
            jinfo("___ .fmtSrc Start ___")

            dflArg <- eval(parse(text = paste0("formals(", fcnNme, ")")))
            for (nmeArg in names(crrArg)) {
                if (identical(crrArg[[nmeArg]], dflArg[[nmeArg]])) crrArg[nmeArg] <- NULL
            }

            gsub("^list\\(", paste0(fcnNme, "(\n    dtaInp = data,"), gsub("=", " = ", jmvcore::sourcify(crrArg)))
        }
    ),

    public = list(

        asSource = function() {
            jinfo("___ asSource Start ___")

            if (private$.chkVar()) {
                paste0("attr(data, \"fleInp\") <- c(\n    \"", paste0(private$.fleInp, collapse = "\",\n    \""), "\")\n",
                       private$.fmtSrc("jmvReadWrite::merge_cols_omv", private$.crrArg()[c(-1, -2)]))
            }
        }
    )
)
