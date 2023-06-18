
// This file is an automatically generated and should not be edited

'use strict';

const options = [{"name":"data","type":"Data"},{"name":"colstorows","title":"Columns to rows","type":"Variables"},{"name":"covs","title":"Non-varying variables","type":"Variables"},{"name":"rmlevels","title":"Repeated measures levels (time var)","type":"String","default":"index"},{"name":"dep","title":"Target variable","type":"String","default":"y"},{"name":"filename","title":"Filename (.csv)","type":"String","default":"longdata.omv"},{"name":"open","title":"Open the dataset","type":"Bool","default":true},{"name":"button","type":"String","hidden":true},{"name":"create","type":"Bool","default":false,"hidden":true},{"name":"toggle","type":"Bool","default":false,"hidden":true}];

const view = function() {
    
    this.handlers = require('./simple2long')

    View.extend({
        jus: "3.0",

        events: [

	],

	update: require('./main').update

    }).call(this);
}

view.layout = ui.extend({

    label: "jReshape: Wide to Long format",
    jus: "3.0",
    type: "root",
    stage: 0, //0 - release, 1 - development, 2 - proposed
    controls: [
		{
			type: DefaultControls.VariableSupplier,
			typeName: 'VariableSupplier',
			persistentItems: false,
			stretchFactor: 1,
			controls: [
				{
					type: DefaultControls.TargetLayoutBox,
					typeName: 'TargetLayoutBox',
					label: "Columns to row",
					controls: [
						{
							type: DefaultControls.VariablesListBox,
							typeName: 'VariablesListBox',
							name: "colstorows",
							isTarget: true
						}
					]
				},
				{
					type: DefaultControls.TargetLayoutBox,
					typeName: 'TargetLayoutBox',
					label: "Non-varying variables",
					controls: [
						{
							type: DefaultControls.VariablesListBox,
							typeName: 'VariablesListBox',
							name: "covs",
							isTarget: true
						}
					]
				}
			]
		},
		{
			type: DefaultControls.LayoutBox,
			typeName: 'LayoutBox',
			margin: "large",
			controls: [
				{
					type: DefaultControls.Label,
					typeName: 'Label',
					label: "Names of new variables",
					margin: "large",
					controls: [
						{
							type: DefaultControls.TextBox,
							typeName: 'TextBox',
							name: "rmlevels",
							format: FormatDef.string,
							stretchFactor: 1
						},
						{
							type: DefaultControls.TextBox,
							typeName: 'TextBox',
							name: "dep",
							format: FormatDef.string,
							stretchFactor: 1
						},
						{
							type: DefaultControls.TextBox,
							typeName: 'TextBox',
							name: "filename",
							format: FormatDef.string,
							stretchFactor: 1
						}
					]
				}
			]
		},
		{
			type: DefaultControls.LayoutBox,
			typeName: 'LayoutBox',
			margin: "large",
			controls: [
				{
					type: DefaultControls.CheckBox,
					typeName: 'CheckBox',
					name: "open"
				},
				{
					type: DefaultControls.CustomControl,
					typeName: 'CustomControl',
					stretchFactor: 3,
					name: "button",
					events: [
						{ onEvent: 'creating', execute: require('./main').button_creating }
					]
				}
			]
		}
	]
});

module.exports = { view : view, options: options };
