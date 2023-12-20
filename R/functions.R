combine <- function(..., prefix = "", sep = "_",sep0=".") {
  paste0(paste0(prefix,sep0), as.character(interaction(..., sep = sep,lex.order = FALSE)))
}

file_ext<-function (x) 
{
  pos <- regexpr("\\.([[:alnum:]]+)$", x)
  ifelse(pos > -1L, substring(x, pos + 1L), "")
}
`ladd<-`<-function(x,value) {
  x[[length(x)+1]]<-value
  return(x)
}

getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

