'use strict';
require('./css');
const { TooltipManager, KeyboardShortcuts, DOMUtils } = require('./ModuleUtils');

module.exports = {

    loaded: function(ui) {

        // Creating the LOGGING ACTIVE message
        const loggingContainer = document.querySelector('.silky-options-header');

        const titleContainer = loggingContainer.querySelector('h1');
        const loggingMessage = DOMUtils.createDivWithClass('logging-active hidden');
        loggingMessage.id = 'logging-message';
        loggingMessage.innerHTML = `<span>LOGGING ACTIVE</span>`;
        DOMUtils.insertAfter(titleContainer, loggingMessage);

        // Function to show/hide the LOGGING ACTIVE message
        function toggleLoggingMessage(isVisible) {
            if (isVisible) {
                DOMUtils.addClass(loggingMessage, 'visible');
                DOMUtils.removeClass(loggingMessage, 'hidden');
            } else {
                DOMUtils.addClass(loggingMessage, 'hidden');
                DOMUtils.removeClass(loggingMessage, 'visible');
            }
        }

        // Tooltip for LOGGING ACTIVE
        TooltipManager.createTooltip(loggingMessage, 'Press CTRL+ALT+L to disable logging', 'center');

        // Keyboard shortcuts for logging
        KeyboardShortcuts.addShortcut(['ctrl', 'shift', 'l'], () => {
            console.log('Ctrl+Shift+L pressed. Enabling logging.');
            ui.jlog.setValue(true);
            toggleLoggingMessage(true); // Show message
        });

        KeyboardShortcuts.addShortcut(['ctrl', 'alt', 'l'], () => {
            console.log('Ctrl+Alt+L pressed. Disabling logging.');
            ui.jlog.setValue(false);
            toggleLoggingMessage(false); // Hide the message
        });

        // Shortcuts for the Select File and Reshape buttons
        KeyboardShortcuts.addShortcut(['ctrl', 'f'], () => {
            let fileInput = ui.fleChs.$el.find('span#butsf-file');
            if (fileInput.length) {
                fileInput.trigger('click');
            }
        });

        KeyboardShortcuts.addShortcut(['ctrl', 'r'], () => {
            let reshapeButton = ui.fleRes.$el.find('span#butsf-reshape');
            if (reshapeButton.length) {
                reshapeButton.trigger('click');
            }
        });

        // Add buttons to the UI
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

        // Tooltip for buttons with control to not exit the display area
        TooltipManager.createTooltip($btnchs.find('#butsf-file')[0], 'Click or (Ctrl+F) to select a file to merge', 'right');
        TooltipManager.createTooltip($btnres.find('#butsf-reshape')[0], 'Click or (Ctrl+R) for a new merged file', 'left');

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
