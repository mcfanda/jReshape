// jrMain.js
'use strict';
require('./css');
const { enableLoggingIndicator, TooltipManager} = require('./ModuleUtils');

module.exports = {
    /**
     * This function is called when the view is loaded in the UI.
     * Adds the LOGGING ACTIVE indicator to the interface.
     */
    view_loaded: function(ui, event) {
        // Enable the LOGGING ACTIVE indicator using the utility function
        enableLoggingIndicator({ ui });
    }
};
