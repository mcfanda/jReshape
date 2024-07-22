'use strict';
require('./css');

module.exports = {

    fleChs_creating: function(ui) {

        let $btnchs = ui.fleChs.$el;
        $btnchs.append(`<label>
                        <input type="file"
                        accept=".omv,.csv,.dta,.jasp,.Rdata,.sav,.sas7bdat"
                        style="display: none;"/>
                        <span id="butsf" style="font-size: 1.3em;">Select file ...</span>
                        </label>`);
        $btnchs.on("change", (f) => {
            var crrTxt = ""; 
            for (const crrFle of f.target.files) {
                crrTxt += `${crrFle.path}; `;

            };
            ui.fleInp.setValue(crrTxt.slice(0, -2));
            
        });

    },
    
    fleRes_creating: function(ui) {

        let $btnres = ui.fleRes.$el;
        $btnres.append(`<label>
                        <input type="button" 
                        style="display: none;"/>
                        <span id="butsf" style="font-size: 1.3em;">Reshape</span>
                        </label>`);
        $btnres.on('click', () => { 
                ui.btnReshape.setValue(true);
        });
    }

};
