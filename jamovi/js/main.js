'use strict';

module.exports = {

    loaded(ui) {

        this.getColumnNames = async () => {
            try {
                const data = await this.requestData('columns', {});
                return data.columns.filter(col => !/^Filter [1-9][0-9]*$/.test(col.name) && !/^F[1-9][0-9]* \([1-9][0-9]*\)$/.test(col.name)).map(col => col.name);

            } catch (error) {
                // Handle request data error (consider logging or displaying an error message)
                console.error('Error fetching column names:', error);

            }

        };

        this.getColumnNames().then(columns => {
            ui.varAll.setValue(columns);

        });

    },

    update(ui) {

        this.getColumnNames().then((columns) => {
            //if (ui.varAll.value().toString() !== columns.toString()) {
            if (!_.isEqual(ui.varAll.value(), columns)) {
                ui.varAll.setValue(columns);
            }
        });

    },

    dataChanged(ui, event) {
  
        if (event.dataType !== 'columns') return;

        this.getColumnNames().then((columns) => {
            //if (ui.varAll.value().toString() !== columns.toString()) {
            if (!_.isEqual(ui.varAll.value(), columns)) {
                ui.varAll.setValue(columns);
            }
        });

    }

};
