HELP_simple2long<-list()
HELP_complex2long<-list()

ladd(HELP_simple2long)<-"<div>
              <h2>Getting started</h2>
               With this module, you can transform a dataset from the wide format to the long format. 
               To do this, select the variables (columns) from the original dataset that you want to convert
               into different row values and enter them in the <b>Columns to row</b> field. 
               In the new dataset, a variable (specified in the <b>Target variable</b> field) 
               will be created, containing one row for each column value for each case.
               <br><br>
               Additionally, a variable named in the <b>Repeated measure levels</b>
               field will be created, which corresponds to the original column names (e.g., conditions or times). 
               A variable ID will also be created, containing the case ID, which represents the original
               row number in the wide format.
               <br><br>
               If there are variables whose values should be copied for each row of the same case
               (invariant covariates), you can add them in the <b>Non-varying Variables</b> field.
               <br><br>
               Once you are ready, click on the <b>Reshape</b> button to open a new file with the reshaped data.
              </div>"


ladd(HELP_complex2long)<-"<div>
              <h2>Getting started</h2>
               With this module, you can transform a dataset from the wide format to the long format. 
               To do this, select the variables (columns) from the original dataset that you want to convert
               into different long format variables. For each long format variable that you want to create,
               define its name and fill the field below it in the <b>New long variable</b> field. 
               In the new dataset, a variable with the specified name 
               will be created, containing one row for each column value for each case.
               <br><br>
               Additionally,  in the <b>Index Variables</b> tab you can specify the names of
               the indexes variables, that keep track of the original levels (e.g., conditions or times). 
               A variable ID will also be created, containing the case ID, which represents the original
               row number in the wide format.
               <br><br>
               If there are variables whose values should be copied for each row of the same case
               (invariant covariates), you can add them in the <b>Non-varying Variables</b> field.
               <br><br>
               Once you are ready, click on the <b>Reshape</b> button to open a new file with the reshaped data.
              </div>"


HELP_long2wide<-list()

ladd(HELP_long2wide)<-"<h2>Getting started</h2>
               <div>
               With this module, you can transform a dataset from the long format to the wide format. 
               Please insert in the <b>Rows to Columns</b> field the variable in the long format that will fill the 
               columns in the wide format. For each long format variable variable in the field, a set of columns
               is created in the wide format.
              </div>"

ladd(HELP_long2wide)<-"<h2>Getting started</h2>
              <div>
               Please insert in the <b>Indexing Variables</b> field the variable containing the levels of the repeated 
               measure factor. For each level, a new column is created in the wide format file. If more than one indexing
               variable is selected, a column is created in the wide format file for each the combination of the indexing 
               variables levels.
              </div>"

ladd(HELP_long2wide)<-"
               <h2>Getting started</h2>
               <div>
               Please insert in the <b>ID</b> field the variable identifying the case ID. For each ID value, a row
               of data is created in the wide format file.
              </div>"

ladd(HELP_long2wide)<-"
               <h2>Getting started</h2>
               <div>
               Click on the <b>Reshape</b> to create a new file with the reshaped variables.
              </div>"


filetypes<-c("omv","sav","Rdata","csv")


##--------------------------##
# --- jrmergecols v0.3.0 --- #

HELP_mergecols<-list()

ladd(HELP_mergecols)<-paste("<h2>Getting started</h2><div style=\"text-align:justify\">
                            <p>Please assign one or more variables that appear in all data sets (e.g., a participant code)
                            to <b>Variable(s) to Match the Data Sets by</b>.<br/>",
                            "Afterwards, either write the name of (one or more) file(s) to be merged under
                            <b>Data Set(s) to Add</b> (separate mulitiple file names with semicolons), or select input files with:",
                            "<h2>&#x1F4C2 Select file(s)...</h2><hr>",
                            "For a more comprehensive explanation regarding the types of merging operations, <b>Details</b>",
                            "underneath the preview table.</p>")

ladd(HELP_mergecols)<-paste("<h2>Getting started</h2><div style=\"text-align:justify\"><p>
                            <h2>&#x1F4C2 Select file(s)...</h2><hr>",
                            "For a more comprehensive explanation regarding the types of merging operations, <b>Details</b>",
                            "underneath the preview table.</p>")

ladd(HELP_mergecols)<-paste("<h2>&#x1F4C2 Reshape</h2> You can open the modified data set in a new jamovi window.",
                            "<hr><svg width=\"130pt\" height=\"30pt\">
                            <rect width=\"30\" height=\"30\" fill=\"#2E6CB9\">
                            <animate attributeName=\"rx\" values=\"0;15;0\" dur=\"2s\" repeatCount=\"3\"/></rect>
                            <circle cx=\"15\" cy=\"15\" r=\"12\" stroke=\"#2E6CB9\" stroke-width=\"1\" fill=\"Tomato\"/>
                            <text x=\"35\" y=\"20\" font-size=\"130%\" fill=\"#2E6CB9\" style=\"text-anchor: start;\">
                            File(s) Merged</text></svg><h3>{file}</h3><hr>")                           

if (getRversion() >= "4.1.3") {
    utils::globalVariables(c("maxRow", "maxCol", "useIdx", "mulTFle",
                             "fmtVrI", "fmtAdC", "fmtAdR", "fmtFsC"))
}

# variable definitions
maxRow <- 10
maxCol <- 10
useIdx <- FALSE
mulTFle <- c("omv","csv","dta","jasp","Rdata","sav","sas7bdat")

# message formatting for sprintf
fmtVrI <- "<strong>Variables in the Output Data Set</strong> (%d variables in %d rows): %s"
fmtAdC <- "There are %d more colums in the data set not shown here. A complete list of variables can be found in \"Variables in the Output Data Set\" above this table."
fmtAdR <- "There are %d more rows in the data set not shown here."
fmtFsC <- "The column%s %s %s shown first in this preview. In the created data set, the variable order is as shown in \"Variables in the Output Data Set\" above this table."
