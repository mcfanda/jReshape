HELP_simple2long<-"<div>
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
               Once you are ready, provide a file name and select <b>Create</b>.
               This will produce a CSV file that will be saved in the specified location 
               (or in the working folder if no path is indicated in the filename).
               The CSV file can be directly opened in jamovi by the user.
               <br><br>
               If you select <b>Open the dataset</b>, jamovi will open it for you.

              </div>"
