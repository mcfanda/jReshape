// jrmergecols.js
'use strict';
require('./css');
const { TooltipManager, KeyboardShortcuts, DOMUtils, ToastManager, enableLoggingIndicator } = require('./ModuleUtils');

module.exports = {
    /**
     * Called when the view is loaded in the UI.
     * Initializes the interface, including adding buttons, tooltips,
     * and keyboard shortcuts.
     */
    view_loaded: function(ui, event) {
        // 1. Enable the "LOGGING ACTIVE" indicator using the utility function
        enableLoggingIndicator({ ui });

        // 2. Add shortcut for 'Select File(s)...' button
        KeyboardShortcuts.addShortcut(['ctrl', 'f'], () => {
            console.log('Shortcut pressed: CTRL+F');

            // Simulate a click on the "Select File(s)..." button
            let fileButton = ui.fleChs.$el.find('#butsf-file');
            if (fileButton.length > 0) {
                console.log('Invoking modeless file dialog.');
                fileButton.trigger('click'); // Simulate the click
            } else {
                console.warn('Select File button not found.');
            }
        });

        // 3. Add the 'Select File(s)...' button to the UI
        let $btnchs = ui.fleChs.$el;
        $btnchs.append(`
            <label>
                <input type="button" style="display: none;"/>
                <span id="butsf-file" class="button-style" style="font-size: 1.3em;">Select <span>F</span>ile ...</span>
            </label>
        `);
        $btnchs.find('#butsf-file').off('click').on('click', () => {
            console.log('Opening modeless file dialog.');
            DOMUtils.createCustomFileDialog(ui, (result) => {
                // result contains: { filesArray, filePaths, fileCount }
                ui.fleInp.setValue(result.filePaths); // Save the selected paths

                // Update nfiles with the count of selected files
                const nfiles = result.fileCount;
                ui.nfiles.setValue(nfiles);
                console.log(`Updated nfiles: ${nfiles}`);
                console.log('Files selected:', result.filePaths);
            });
        });

        // Event listener for manual changes to fleInp
        ui.fleInp.on("change", () => {
            const fleInpValue = ui.fleInp.value();
            if (fleInpValue) {
                // Calculate the number of files based on the ";" separator
                const nfiles = fleInpValue.split(";").filter(file => file.trim() !== "").length;
                ui.nfiles.setValue(nfiles);
            } else {
                // If fleInp is empty, set nfiles to 0
                ui.nfiles.setValue(0);
            }
        });

        // 4. Add a tooltip for the 'Select File(s)...' button
        TooltipManager.createTooltip($btnchs.find('#butsf-file')[0], 'Click or (Ctrl+F) to select a file to merge', 'right');

        // 5. Add shortcut for 'Reshape' button
        KeyboardShortcuts.addShortcut(['ctrl', 'r'], () => {
            let reshapeButton = ui.fleRes.$el.find('span#butsf-reshape');
            if (reshapeButton.length) {
                reshapeButton.trigger('click');
            }
        });

        // 6. Add the 'Reshape' button to the UI
        let $btnres = ui.fleRes.$el;
        $btnres.append(`
            <label>
                <input type="button" style="display: none;"/>
                <span id="butsf-reshape" class="button-style" style="font-size: 1.3em;"><span>R</span>eshape</span>
            </label>
        `);
        $btnres.find('#butsf-reshape').off('click').on('click', () => {
            ui.btnReshape.setValue(true);
        });

        // 7. Add a tooltip for the 'Reshape' button
        TooltipManager.createTooltip($btnres.find('#butsf-reshape')[0], 'Click or (Ctrl+R) for a new merged file', 'left');

        // 8. Define a function to fetch the column names, excluding filter-related columns
        this.getColumnNames = async () => {
            try {
                const data = await this.requestData('columns', {});
                return data.columns
                    .filter(col => !/^Filter [1-9][0-9]*$/.test(col.name) && !/^F[1-9][0-9]* \([1-9][0-9]*\)$/.test(col.name))
                    .map(col => col.name);
            } catch (error) {
                console.error('Error fetching column names:', error);
            }
        };

        // 9. Populate the UI element with column names
        this.getColumnNames().then(columns => {
        ui.varAll.setValue(columns);
        });
    },

    /**
     * Called to update the UI when data changes.
     */
    view_updated: function(ui, event) {
        this.getColumnNames().then((columns) => {
            if (!_.isEqual(ui.varAll.value(), columns)) {
                ui.varAll.setValue(columns);
            }
        });
    },

    onChange_fleInp: function(ui) {
        console.log("[onChange_fleInp] Function triggered."); // Debug: Check if the function is called

        // Monitor changes to fleInp to recalculate nfiles dynamically
        const fleInpValue = ui.fleInp.value();
        console.log(`[onChange_fleInp] Current fleInp value: ${fleInpValue}`); // Debug: Check fleInp value

        if (fleInpValue) {
            // Count the number of files based on the ";" separator
            const nfiles = fleInpValue.split(";").filter(file => file.trim() !== "").length;

            // Update the nfiles option in the backend
            ui.nfiles.setValue(nfiles);
            console.log(`[onChange_fleInp] Updated nfiles: ${nfiles}`); // Debug: Check updated nfiles
        } else {
            // No files selected, set nfiles to 0
            ui.nfiles.setValue(0);
            console.log("[onChange_fleInp] No files selected, nfiles set to 0."); // Debug: No files case
        }
    },

    /**
     * Called when data changes remotely, for instance when the dataset is modified.
     */
    dataChanged: function(ui, event) {
        if (event.dataType !== 'columns') return;

        this.getColumnNames().then((columns) => {
            if (!_.isEqual(ui.varAll.value(), columns)) {
                ui.varAll.setValue(columns);
            }
        });
    }
};
