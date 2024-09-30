'use strict';
require('./css');

module.exports = {

    loaded: function(ui) {

        // Aggiungere listener per la combinazione di tasti Ctrl+F per selezionare un file
        Keyboard?.addKeyboardListener?.('Ctrl+KeyF', () => {
            let fileInput = ui.fleChs.$el.find('span#butsf-file');
            if (fileInput.length) {
                fileInput.trigger('click');
            }
        }, 'Shortcut per selezionare un file');

        // Aggiungere listener per la combinazione di tasti Ctrl+R per il bottone reshape
        Keyboard?.addKeyboardListener?.('Ctrl+KeyR', () => {
            let reshapeButton = ui.fleRes.$el.find('span#butsf-reshape');
            if (reshapeButton.length) {
                reshapeButton.trigger('click');
            }
        }, 'Shortcut per il reshape');
        
        let $btnchs = ui.fleChs.$el;
        $btnchs.append(`<label>
                        <input type="file"
                        accept=".omv,.csv,.dta,.jasp,.Rdata,.sav,.sas7bdat"
                        style="display: none;"/>
                        <span id="butsf-file" class="button-style" style="font-size: 1.3em;">Select <span>F</span>ile ...</span>
                        </label>`);
        $btnchs.on("change", (f) => {
            var crrTxt = ""; 
            for (const crrFle of f.target.files) {
                crrTxt += `${crrFle.path}; `;
            }
            ui.fleInp.setValue(crrTxt.slice(0, -2));
        });
    
        let $btnres = ui.fleRes.$el;
        $btnres.append(`<label>
                        <input type="button" 
                        style="display: none;"/>
                        <span id="butsf-reshape" class="button-style" style="font-size: 1.3em;"><span>R</span>eshape</span>
                        </label>`);
        $btnres.on('click', () => { 
            ui.btnReshape.setValue(true);
        });
        
        this.getColumnNames = async () => {
            try {
                const data = await this.requestData('columns', {});
                return data.columns.filter(col => !/^Filter [1-9][0-9]*$/.test(col.name) && !/^F[1-9][0-9]* \([1-9][0-9]*\)$/.test(col.name)).map(col => col.name);
            } catch (error) {
                console.error('Error fetching column names:', error);
            }
        };

        this.getColumnNames().then(columns => {
            ui.varAll.setValue(columns);
        });

        // Funzione per creare e gestire il tooltip
        function addCustomTooltip(element, text, position) {
            const tooltip = document.createElement('div');
            tooltip.className = 'custom-tooltip';
            tooltip.textContent = text;
            document.body.appendChild(tooltip);

            element.on('mouseover', (event) => {
                tooltip.style.display = 'block';
                if (position === 'left') {
                    tooltip.style.left = `${event.pageX - tooltip.offsetWidth - 10}px`; // Sposta a sinistra
                } else {
                    tooltip.style.left = `${event.pageX + 10}px`; // Sposta a destra
                }
                tooltip.style.top = `${event.pageY + 10}px`;
            });

            element.on('mousemove', (event) => {
                tooltip.style.top = `${event.pageY + 10}px`;
            });

            element.on('mouseout', () => {
                tooltip.style.display = 'none';
            });
        }

        // Aggiungi i tooltip personalizzati
        addCustomTooltip($btnchs.find('#butsf-file'), 'Click or (Ctrl+F) to select a file to merge', 'right');
        addCustomTooltip($btnres.find('#butsf-reshape'), 'Click or (Ctrl+R) for a new merged file', 'left');
    },

    update(ui) {
        this.getColumnNames().then((columns) => {
            if (!_.isEqual(ui.varAll.value(), columns)) {
                ui.varAll.setValue(columns);
            }
        });
    },

    dataChanged(ui, event) {
        if (event.dataType !== 'columns') return;

        this.getColumnNames().then((columns) => {
            if (!_.isEqual(ui.varAll.value(), columns)) {
                ui.varAll.setValue(columns);
            }
        });
    }
};

