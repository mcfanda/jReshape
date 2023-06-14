
// This file is an automatically generated and should not be edited

'use strict';

const options = [{"name":"data","type":"Data"},{"name":"colstorows","title":"Columns to row","type":"Variables"},{"name":"covs","title":"Non-varying variables","type":"Variables"},{"name":"rmlevels","title":"Repeated measures levels (time var)","type":"String","default":"time"},{"name":"dep","title":"Target variable","type":"String","default":"y"},{"name":"filename","title":"Filename (.csv)","type":"String"},{"name":"save","title":"Save the dataset","type":"Bool","default":false}];

const view = function() {
    
    this.handlers = { }

    View.extend({
        jus: "3.0",

        events: [

	]

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
					name: "save"
				}
			]
		}
	]
});

module.exports = { view : view, options: options };
