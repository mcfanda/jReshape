'use strict';
require('./css');

module.exports = {

    loaded(ui) {

        this.getColumnNames = () => {
            return this.requestData('columns', {
                }).then((data) => {
                    return data.columns.map(col => col.name);
                }).then((names) => {
                    // exclude filters
                    let index = 0;
                    while (/^Filter [1-9][0-9]*$/.exec(names[index]) ||
                           /^F[1-9][0-9]* \([1-9][0-9]*\)$/.exec(names[index])) {
                        index++
                    }
                    return names.slice(index);
                });
        };

        this.getColumnNames().then((columns) => {
            ui.varAll.setValue(columns);
         });
    },

    update(ui) {

        this.getColumnNames().then((columns) => {
            if (ui.varAll.value().toString() !== columns.toString()) {
                ui.varAll.setValue(columns);
            }
        });

    },

    fleChs_creating: function(ui) {
        let $contents = ui.fleChs.$el;
        $contents.append(`<label>
                          <input type="file"
                          multiple accept=".omv,.csv,.dta,.jasp,.Rdata,.sav,.sas7bdat"
                          style="display: none;"/>
                          <span id="butsf">Select file(s)...</span>
                          </label>`);

        $contents.on("change", (f) => { 
            var crrTxt = "";
            for (const crrFle of f.target.files) { 
                crrTxt += `${crrFle.path}; `;
            };
            ui.fleInp.setValue(crrTxt.slice(0, -2)); 
        });
    },

    dataChanged(ui, event) {

        if (event.dataType !== 'columns')
            return;
        this.getColumnNames().then((columns) => {
            if (ui.varAll.value().toString() !== columns.toString()) {
                ui.varAll.setValue(columns);
            }
        });
    }
};
