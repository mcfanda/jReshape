## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE,
                      comment = "#>",
                      collapse = TRUE,
                      message = FALSE,                      
                      warning = FALSE,
                      fig.height = 5,
                      fig.width = 7,
                      fig.align = "center",
                      out.width = "100%")

## ---- eval=FALSE--------------------------------------------------------------
#  install.packages("jmvReadWrite")

## ---- eval=FALSE--------------------------------------------------------------
#  if(!require(devtools)) install.packages("devtools")
#  devtools::install_github("sjentsch/jmvReadWrite")

## ---- echo=TRUE---------------------------------------------------------------
library(jmvReadWrite);
library(jmv);

fleOMV = system.file("extdata", "ToothGrowth.omv", package = "jmvReadWrite");
data = read_omv(fleOMV);
# if the "jmv"-package is installed, we can run a test analysis with the data
if ("jmv" %in% rownames(installed.packages())) {
    jmv::ANOVA(
        formula = len ~ supp + dose + supp:dose,
        data = data,
        effectSize = c("omega"),
        modelTest = TRUE,
        homo = TRUE,
        norm = TRUE);
    }

## ---- echo=TRUE---------------------------------------------------------------
library(jmvReadWrite);
fleOMV = system.file("extdata", "ToothGrowth.omv", package = "jmvReadWrite");
data = read_omv(fleOMV, getSyn = TRUE);
# shows the syntax of the analyses from the .omv-file
# please note that syntax extraction may not work on all systems
# if the syntax couldn't be extracted, an empty list (length = 0) is returned,
# otherwise, the syntax of the analyses from the .omv-file is shown and  
# the commands of the first and the second analysis are run, with the
# output of the second analysis assigned to the variable result2
if (length(attr(data, "syntax")) >= 2) {
    attr(data, "syntax")
    # if the "jmv"-package is installed, we can run the analyses in "syntax"     
    if ("jmv" %in% rownames(installed.packages())) {
        eval(parse(text=attr(data, "syntax")[[1]]))
        eval(parse(text=paste0("result2 = ", attr(data, "syntax")[[2]])))
        names(result2)
        # -> "main"      "assump"    "contrasts" "postHoc"   "emm"
        # (the names of the five output tables)
    }
}

## ---- echo=TRUE---------------------------------------------------------------
library(jmvReadWrite)

# use the data set "ToothGrowth" and, if it exists, write it as jamovi-file
# using write_omv()
data("ToothGrowth");
# "retDbg" has to be set in order to return debug information to wrtDta
wrtDta = write_omv(ToothGrowth, "Trial.omv", retDbg = TRUE);
names(wrtDta);
# -> "mtaDta" "xtdDta" "dtaFrm"
# this debug information contains a list with the metadata ("mtaDta", e.g.,
# column and data type), the extended data ("xtdDta", e.g., variable lables),
# and the data frame (dtaFrm) for checking (understanding the file format) and
# debugging

# check whether the file was written to the disk, get the file information (size, etc.)
# and delete the file afterwards
list.files(".", "Trial.omv");
file.info("Trial.omv");
unlink("Trial.omv");

## ---- echo=TRUE---------------------------------------------------------------
# reading and writing a file with the "sveAtt"-parameter permits you to keep
# essential meta-data to ensure that the written file looks and works like the
# original file (plus you modifications)
fleOMV = system.file("extdata", "ToothGrowth.omv", package = "jmvReadWrite");
data = read_omv(fleOMV, sveAtt = TRUE);
# shows the names of the attributes for the whole data set (e.g., number of
# rows and columns) and the names of the attributes of the first column
names(attributes(data));
names(attributes(data[[1]]));
#
# perhaps do some modifications to the file here and write it back afterwards
write_omv(data, 'Trial.omv');
unlink("Trial.omv");

