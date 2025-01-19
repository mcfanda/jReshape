MzMergeUtils <- R6::R6Class(
    "MzMergeUtils",
    private = list(
        dataset = NULL,
        external_files = NULL,
        match_vars = NULL,
        join_type = NULL,
        merged_data = NULL,

        # Validate input
        .validate_input = function() {
            if (is.null(private$dataset) || nrow(private$dataset) == 0) {
                stop("[MzMergeUtils] Dataset is empty or NULL.")
            }
            if (!nzchar(private$external_files)) {
                stop("[MzMergeUtils] No external files specified.")
            }
            if (is.null(private$match_vars) || length(private$match_vars) == 0) {
                stop("[MzMergeUtils] No matching variables specified.")
            }
        },

        # Read external files
        .read_external_files = function() {
            files <- strsplit(private$external_files, ";")[[1]]
            files <- trimws(files)
            jinfo(paste("[MzMergeUtils] Files to read =", paste(files, collapse = ", ")))

            datasets <- lapply(files, function(file) {
                if (!file.exists(file)) {
                    stop(sprintf("[MzMergeUtils] File not found: '%s'", file))
                }
                tryCatch({
                    jmvReadWrite:::read_all(fleInp = file)
                }, error = function(e) {
                    stop(sprintf("[MzMergeUtils] Error reading file '%s': %s", file, e$message))
                })
            })
            return(datasets)
        },

        get_commons = function() {
            if (is.null(private$dataset) || is.null(private$external_files)) {
                stop("[MzMergeUtils] Dataset or external files not initialized.")
            }
            files <- private$.read_external_files()
            commons <- intersect(names(private$dataset), unique(unlist(lapply(files, names))))
            return(commons)
        },

        # Perform the merge
        .perform_merge = function(datasets) {
            merged_data <- private$dataset

            # Traccia i suffissi per ogni file esterno
            for (i in seq_along(datasets)) {
                external_ds <- datasets[[i]]

                # Rinominare colonne duplicate per garantire suffissi coerenti
                names(external_ds) <- sapply(names(external_ds), function(col) {
                    if (col %in% private$match_vars) return(col) # Variabili di matching mantengono il nome
                    if (col %in% names(merged_data)) return(paste0(col, ".y", i)) # Aggiungi suffisso basato sull'indice del file
                    return(col) # Nessuna modifica per le colonne uniche
                })

                # Esegui il merge con il dataset principale
                merged_data <- merge(
                    x = merged_data,
                    y = external_ds,
                    by = private$match_vars,
                    all.x = private$join_type %in% c("outer", "left"),
                    all.y = private$join_type %in% c("outer", "right")
                )
            }

            # Ordina le colonne: le variabili di matching prima
            all_columns <- names(merged_data)
            match_columns <- intersect(private$match_vars, all_columns)
            other_columns <- setdiff(all_columns, match_columns)
            ordered_columns <- c(match_columns, other_columns)
            merged_data <- merged_data[, ordered_columns, drop = FALSE]

            # Sostituisci i valori NA con stringhe vuote
            merged_data[is.na(merged_data)] <- ""

            return(merged_data)
        }
    ),

    public = list(
        initialize = function(dataset, external_files, match_vars, join_type) {
            private$dataset <- dataset
            private$external_files <- external_files
            private$match_vars <- match_vars
            private$join_type <- join_type
            private$.validate_input()
        },

        # Public method to get merged data
        get_data = function() {
            if (is.null(private$merged_data)) {
                datasets <- private$.read_external_files()
                private$merged_data <- private$.perform_merge(datasets)
            }
            return(private$merged_data)
        },

        # Public method to get features
        get_features = function() {
            if (is.null(private$dataset) || is.null(private$external_files)) {
                stop("[MzMergeUtils] Dataset or external files not initialized.")
            }

            xatt <- jmvReadWrite:::jmvAtt(private$dataset)
            yatts <- lapply(private$.read_external_files(), function(dataset) {
                jmvReadWrite:::jmvAtt(dataset)
            })

            features <- lapply(private$get_commons(), function(var) {
                labs_right <- lapply(seq_len(length(yatts)), function(i) {
                    if (!is.null(yatts[[i]][[var]])) {
                        attr(yatts[[i]][[var]], "measureType")
                    } else {
                        NA
                    }
                })

                list(
                    var = var,
                    lab = attr(xatt[[var]], "measureType"),
                    labs = labs_right
                )
            })

            return(features)
        },

        generateReport = function() {
            n_files <- length(strsplit(private$external_files, ";")[[1]])
            n_rows <- if (!is.null(private$merged_data)) nrow(private$merged_data) else 0
            n_cols <- if (!is.null(private$merged_data)) ncol(private$merged_data) else 0
            col_names_main <- paste(names(private$dataset), collapse = ", ")

            file_details <- tryCatch({
                files <- strsplit(private$external_files, ";")[[1]]
                files <- trimws(files)
                details <- lapply(seq_along(files), function(i) {
                    file <- files[[i]]
                    cols <- names(jmvReadWrite:::read_all(fleInp = file))
                    duplicates <- intersect(cols, names(private$dataset))
                    duplicates_formatted <- if (length(duplicates) > 0) {
                        paste(
                            "<p><strong>Duplicates:</strong> ",
                            paste(duplicates, collapse = ", "),
                            "</p><p>In the final dataset, these variables are renamed with suffix '.y", i, "'</p>"
                        )
                    } else {
                        "<p><strong>Duplicates:</strong> None</p>"
                    }
                    paste0(
                        "<p><strong>File:</strong> ", file, "</p>",
                        "<p><strong>Columns:</strong> ", paste(cols, collapse = ", "), "</p>",
                        duplicates_formatted
                    )
                })
                paste(details, collapse = "<hr>")
            }, error = function(e) {
                "Error retrieving file details"
            })

            commons <- if (!is.null(private$match_vars)) paste(private$match_vars, collapse = ", ") else "None"

            report <- paste0(
                "<div class=\"report-container\">",
                "<h2 style='display: inline;'>Merge Report</h2>",
                "<h3 style='display: inline; margin-left: 10px;'><i>(Show detailed information)</i></h3>",
                "<p><strong>Number of files merged:</strong> ", n_files, "</p>",
                "<p><strong>Total rows in the merged dataset:</strong> ", n_rows, "</p>",
                "<p><strong>Total columns in the merged dataset:</strong> ", n_cols, "</p>",
                "<p><strong>Columns in the main dataset:</strong> ", col_names_main, "</p>",
                "<hr>",
                "<p><strong>Common variables:</strong> ", commons, "</p>",
                "<hr>",
                "<h3>External Files Details</h3>",
                file_details,
                "</div>"
            )

            styled_report <- paste0(
                "<style>",
                ".report-container {",
                "  border: 2px solid #3e6da9;",
                "  border-radius: 50px 10px 10px 10px;",  # Top-left corner radius larger
                "  box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);",
                "  padding: 20px;",
                "  font-family: Arial, sans-serif;",
                "  background-color: #f9f9f9;",
                "}",
                ".report-container h2 {",
                "  color: #3e6da9;",
                "  border-radius: 25px 10px 5px 5px;",  # Top-left corner radius larger
                "  background-color: #f1f1f1;",
                "  padding: 10px;",
                "}",
                ".report-container p {",
                "  font-size: 14px;",
                "  margin-bottom: 10px;",
                "}",
                "</style>",
                report
            )

            return(styled_report)
        }
    )
)
