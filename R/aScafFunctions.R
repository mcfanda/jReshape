# j_DEBUG <- FALSE
# j_INFO  <- FALSE
# t_INFO  <- FALSE
# j_W0S   <- .Platform$OS.type=="windows"
#
# fleWOS<-""
# # NB for Windows users: Feel free to change the path and name of the log file as you like.
# if (j_W0S) fleWOS <- file.path(base::Sys.getenv("TEMP"), "jReshape.log")
#
# #### Helper functions for debugging
#
# tinfo <- function(...) {
#     if (!t_INFO) return(invisible(NULL))
#
#     if (j_W0S && nzchar(fleWOS)) base::sink(file = fleWOS, append = TRUE)
#
#     cat(paste(list(...)))
#     cat("\n")
#
#     if (j_W0S && nzchar(fleWOS)) base::sink()
# }
#
# jinfo <- function(...) {
#     if (!j_INFO) return(invisible(NULL))
#
#     if (j_W0S && nzchar(fleWOS)) base::sink(file = fleWOS, append = TRUE)
#
#     cat("\n")
#     cat(paste(list(...)))
#     cat("\n")
#
#     if (j_W0S && nzchar(fleWOS)) base::sink()
# }
#
# mark <- function(...) {
#     if (!j_DEBUG) return(invisible(NULL))
#
#     if (j_W0S && nzchar(fleWOS)) base::sink(file = fleWOS, append = TRUE)
#
#     if (missing(...)) {
#         cat("Mark here\n")
#         return(invisible(NULL))
#     }
#
#     items <- list(...)
#     cat("______begin________\n\n")
#     for (a in items)
#         if (is.character(a)) cat(a, "\n") else print(a)
#     cat("_____end_______\n\n")
#
#     if (j_W0S && nzchar(fleWOS)) base::sink()
# }


# Define global environment for log flags
logFlags            <- new.env(parent = emptyenv())
logFlags$j_DEBUG    <- FALSE
logFlags$j_INFO     <- FALSE
logFlags$log_active <- FALSE  # Tracks if the log file is currently open
logFlags$j_OS       <- .Platform$OS.type

# Determine the appropriate log file path based on the OS
logFlags$fleWUD <- switch(logFlags$j_OS,
                          "windows" = file.path(base::Sys.getenv("TEMP"), "jreshape.log"),
                          "unix" = file.path(Sys.getenv("HOME"), ".local", "share", "jamovi", "jreshape.log"),
                          "darwin" = file.path(Sys.getenv("HOME"), "Library", "Logs", "jamovi", "jreshape.log"),
                          file.path(tempdir(), "jreshape.log")  # Default to tempdir() if OS is unrecognized
)

# Ensure the log directory exists
ensure_log_dir <- function(log_path) {
    log_dir <- dirname(log_path)
    if (!dir.exists(log_dir)) {
        tryCatch({
            dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
        }, error = function(e) {
            # Handle errors silently
        })
    }
}

# Helper function to get current timestamp
current_time <- function() {
    format(Sys.time(), "%Y-%m-%d %H:%M:%S")
}

# Update logging flags dynamically
set_logflags <- function(jlog) {
    if (jlog && !logFlags$log_active) {
        open_log()  # Open the log only if it is not already active
    } else if (!jlog && logFlags$log_active) {
        close_log()  # Close the log only if it is currently active
    }

    logFlags$j_DEBUG <- jlog
    logFlags$j_INFO  <- jlog
}

# Open the log file if not already open
open_log <- function() {
    ensure_log_dir(logFlags$fleWUD)
    if (nzchar(logFlags$fleWUD) && !logFlags$log_active) {
        tryCatch({
            if (!file.exists(logFlags$fleWUD)) file.create(logFlags$fleWUD)
            cat(paste0("Logging started at  ",
                       current_time(),
                       "\n---------------------------------------\n"),
                file = logFlags$fleWUD, append = TRUE)
            logFlags$log_active <- TRUE
        }, error = function(e) {
            # Optional: Handle errors silently
        })
    }
}

# Close the log file
close_log <- function() {
    if (nzchar(logFlags$fleWUD) && logFlags$log_active) {
        tryCatch({
            cat(paste0("---------------------------------------\n",
                       "Logging disabled at ", current_time(), "\n\n"),
                file = logFlags$fleWUD, append = TRUE)
            logFlags$log_active <- FALSE
        }, error = function(e) {
            # Optional: Handle errors silently
        })
    }
}

# Write info messages to the log
jinfo <- function(...) {
    if (!logFlags$j_INFO || !logFlags$log_active) return(invisible(NULL))
    tryCatch({
        if (nzchar(logFlags$fleWUD)) {
            if (!file.exists(logFlags$fleWUD)) file.create(logFlags$fleWUD)
            cat(paste(..., collapse = " "), "\n",
                file = logFlags$fleWUD, append = TRUE)
        }
    }, error = function(e) {
        # Optional: Log the error internally
    })
}

# Write debug marks to the log
mark <- function(...) {
    if (!logFlags$j_DEBUG || !logFlags$log_active) return(invisible(NULL))
    tryCatch({
        if (nzchar(logFlags$fleWUD)) {
            if (!file.exists(logFlags$fleWUD)) file.create(logFlags$fleWUD)
            cat("______begin________\n", file = logFlags$fleWUD, append = TRUE)
            lapply(list(...), function(a) {
                if (is.character(a)) {
                    cat(a, "\n", file = logFlags$fleWUD, append = TRUE)
                } else {
                    cat(paste(capture.output(print(a)), collapse = "\n"), "\n",
                        file = logFlags$fleWUD, append = TRUE)
                }
            })
            cat("_______end_________\n", file = logFlags$fleWUD, append = TRUE)
        }
    }, error = function(e) {
        # Optional: Log the error internally
    })
}

is.something <- function(x, ...) UseMethod(".is.something")

.is.something.default <- function(obj) (!is.null(obj))

.is.something.list <- function(obj) (length(obj) > 0)

.is.something.numeric <- function(obj) (length(obj) > 0)

.is.something.character <- function(obj) (length(obj) > 0)

.is.something.logical <- function(obj) !is.na(obj)

is.there<-function(pattern,string) length(grep(pattern,string,fixed=T))>0

#### This function run an expression and returns any warnings or errors without stopping the execution.
try_hard<-function(exp,max_warn=5) {

  .results<-list(error=FALSE,warning=list(),message=FALSE,obj=FALSE)

  .results$obj <- withCallingHandlers(
    tryCatch(exp, error=function(e) {
      mark("SOURCE:")
      mark(conditionCall(e))
      .results$error<<-conditionMessage(e)
      NULL
    }), warning=function(w) {

      if (length(.results$warning)==max_warn)
        .results$warning[[length(.results$warning)+1]]<<-"Additional warnings are present."

      if (length(.results$warning)<max_warn)
        .results$warning[[length(.results$warning)+1]]<<-conditionMessage(w)

      invokeRestart("muffleWarning")
    }, message = function(m) {
      .results$message<<-conditionMessage(m)
      invokeRestart("muffleMessage")
    })


  if (!isFALSE(.results$error)) {
    mark("CALLER:")
    mark(rlang::enquo(exp))
    mark("ERROR:")
    mark(.results$error)
  }
  if(length(.results$warning)==0) .results$warning<-FALSE
  if(length(.results$warning)==1) .results$warning<-.results$warning[[1]]


  return(.results)
}


sourcifyOption<- function(x,...) UseMethod(".sourcifyOption")

.sourcifyOption.default=function(option,def=NULL) {

  if (option$name == 'data')
    return('data = data')

  if (startsWith(option$name, 'results/'))
    return('')

  value <- option$value
  def <- option$default

  if ( ! ((is.numeric(value) && isTRUE(all.equal(value, def))) || base::identical(value, def))) {
    valueAsSource <- option$valueAsSource
    if ( ! identical(valueAsSource, ''))
      return(paste0(option$name, ' = ', valueAsSource))
  }
  ''
}
.sourcifyOption.OptionVariables<-function(option,def=NULL) {

  if (is.null(option$value))
     return('')

  values<-sourcifyName(option$value)

  if (length(values)==1)
     return(paste0(option$name,"=",values))
  else
    return(paste0(option$name,"=c(",paste0(values,collapse = ","),")"))
}

.sourcifyOption.OptionTerms<-function(option,def=NULL)
     .sourcifyOption.default(option,def)

.sourcifyOption.OptionArray<-function(option,def=NULL) {
  alist<-option$value
  if (length(alist)==0)
      return('')
  if (is.something(def) & option$name %in% names(def)) {
    test<-all(sapply(alist,function(a) a$type)==def[[option$name]])
    if (test)
      return('')
  }
  paste0(option$name,"=c(",paste(sapply(alist,function(a) paste0(sourcifyName(a$var),' = \"',a$type,'\"')),collapse=", "),")")
}


.sourcifyOption.OptionList<-function(option,def=NULL) {

  if (length(option$value)==0)
    return('')
  if (option$value==option$default)
       return('')
  paste0(option$name,"='",option$value,"'")
}


sourcifyName<-function(name) {

  what<-which(make.names(name)!=name)
  for (i in what)
    name[[i]]<-paste0('"',name[[i]],'"')
  name
}

sourcifyVars<-function(value) {

  paste0(sourcifyName(value),collapse = ",")

}

listify <- function(adata) {
  res <- lapply(1:dim(adata)[1], function(a) as.list(adata[a, ]))
  names(res) <- rownames(adata)
  res
}

smartTableName<-function(root,alist,end=NULL) {
    paste(root,make.names(paste(alist,collapse = ".")),end,sep="_")
}


transnames<-function(original,ref) {
  unlist(lapply(original,function(x) {
    i<-names(ref)[sapply(ref,function(y) any(y %in% trimws(x)))]
    ifelse(length(i)>0,i,x)
  }))
}

is.listOfList<-function(obj) {
  if (length(obj)==0)
     return(FALSE)

  if (inherits(obj,"list")) {
    child<-obj[[1]]
    return(inherits(obj,"list"))
  }
  return(FALSE)
}

ebind<-function(...) {
  tabs<-list(...)
  .names<-unique(unlist(sapply(tabs,colnames)))
  tabs<-lapply(tabs, function(atab) {
    atab<-as.data.frame(atab)
    for (name in .names)
      if (!utils::hasName(atab,name))
        atab[[name]]<-NA
    atab
  })
  return(do.call(rbind,tabs))

}

ebind_square<-function(...) {
  tabs<-list(...)
  .names<-unique(unlist(sapply(tabs,colnames)))
  .max<-max(unlist(sapply(tabs,dim)))

  tabs<-lapply(tabs, function(atab) {
    atab<-as.data.frame(atab)
    for (name in .names)
      if (!utils::hasName(atab,name))
        atab[[name]]<-NA
    if (dim(atab)[1]<.max)
        atab[(dim(atab)[1]+1):.max,]<-NA
    atab
  })
  return(do.call(rbind,tabs))

}

`ladd<-`<-function(x,value) {
  x[[length(x)+1]]<-value
  return(x)
}

`padd<-` <- function(x, value) {
  x <- c(0, x)
  x[[1]] <- value
  x
}

###########


sourcifyOption<- function(x,...) UseMethod(".sourcifyOption")

.sourcifyOption.default=function(option,def=NULL) {

  if (option$name == 'data')
    return('data = data')

  if (startsWith(option$name, 'results/'))
    return('')

  value <- option$value
  def <- option$default

  if ( ! ((is.numeric(value) && isTRUE(all.equal(value, def))) || base::identical(value, def))) {
    valueAsSource <- option$valueAsSource
    if ( ! identical(valueAsSource, ''))
      return(paste0(option$name, ' = ', valueAsSource))
  }
  ''
}
.sourcifyOption.OptionVariables<-function(option,def=NULL) {

  if (is.null(option$value))
    return('')

  values<-sourcifyName(option$value)

  if (length(values)==1)
    return(paste0(option$name,"=",values))
  else
    return(paste0(option$name,"=c(",paste0(values,collapse = ","),")"))
}

.sourcifyOption.OptionTerms<-function(option,def=NULL)
  .sourcifyOption.default(option,def)

.sourcifyOption.OptionArray<-function(option,def=NULL) {
  alist<-option$value
  if (length(alist)==0)
    return('')
  if (is.something(def) & option$name %in% names(def)) {
    test<-all(sapply(alist,function(a) a$type)==def[[option$name]])
    if (test)
      return('')
  }
  paste0(option$name,"=c(",paste(sapply(alist,function(a) paste0(sourcifyName(a$var),' = \"',a$type,'\"')),collapse=", "),")")
}


.sourcifyOption.OptionList<-function(option,def=NULL) {

  if (length(option$value)==0)
    return('')
  if (option$value==option$default)
    return('')
  paste0(option$name,"='",option$value,"'")
}


sourcifyName<-function(name) {

  what<-which(make.names(name)!=name)
  for (i in what)
    name[[i]]<-paste0('"',name[[i]],'"')
  name
}



#########

# remove null from list of lists
clean_lol<-function(alist) {
  il<-list()
  for (i in seq_along(alist)) {
    jl<-list()
    for (j in seq_along(alist[[i]])) {
      if (length(alist[[i]][[j]])>0) jl[[length(jl)+1]]<-alist[[i]][[j]]
    }
    if (length(jl)>0) il[[length(il)+1]]<-jl
  }
  il
}
