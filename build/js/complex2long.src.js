
// This file is an automatically generated and should not be edited

'use strict';

const options = [{"name":"data","type":"Data"},{"name":"colstorows","type":"Array","default":[{"label":"long_y","vars":[]}],"template":{"type":"Group","elements":[{"name":"label","type":"String"},{"name":"vars","type":"Variables"}]}},{"name":"covs","title":"Non-varying variables","type":"Variables"},{"name":"index","title":"Index variables","type":"Array","default":[{"var":"index1","levels":0}],"template":{"type":"Group","elements":[{"name":"var","type":"String"},{"name":"levels","type":"Integer"}]}},{"name":"filename","title":"Filename (.csv)","type":"String","default":"longdata.csv"},{"name":"open","title":"Open the dataset","type":"Bool","default":true},{"name":"button","type":"String","hidden":true},{"name":"create","type":"Bool","default":false,"hidden":true},{"name":"toggle","type":"Bool","default":false,"hidden":true}];

const view = function() {
    
    this.handlers = require('./complex2long')

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
			persistentItems: true,
			stretchFactor: 1,
			suggested: ["continuous","ordinal"],
			permitted: ["numeric"],
			controls: [
				{
					type: DefaultControls.TargetLayoutBox,
					typeName: 'TargetLayoutBox',
					label: "New long variable (Columns to rows)",
					controls: [
						{
							type: DefaultControls.ListBox,
							typeName: 'ListBox',
							name: "colstorows",
							height: "large",
							addButton: "Add new long variable",
							events: [
								{ onEvent: 'listItemAdded', execute: require('./complex2long').onChange_items_changed },
								{ onEvent: 'listItemRemoved', execute: require('./complex2long').onChange_items_changed }
							],
							templateName: "linreg-block-template",
							template:
							{
								type: DefaultControls.LayoutBox,
								typeName: 'LayoutBox',
								margin: "normal",
								controls: [
									{
										type: DefaultControls.TextBox,
										typeName: 'TextBox',
										valueKey: ["label"],
										borderless: true,
										name: "blockName",
										stretchFactor: 1,
										margin: "normal"
									},
									{
										type: DefaultControls.VariablesListBox,
										typeName: 'VariablesListBox',
										name: "blocklist",
										valueFilter: "unique",
										valueKey: ["vars"],
										isTarget: true,
										height: "auto",
										ghostText: "drag columns to rows variables here"
									}
								]
							}							
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
					label: "New file data",
					margin: "large",
					controls: [
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
		},
		{
			type: DefaultControls.CollapseBox,
			typeName: 'CollapseBox',
			label: "Index Variables",
			collapsed: true,
			stretchFactor: 1,
			controls: [
				{
					type: DefaultControls.Label,
					typeName: 'Label',
					label: "Clustering Variables",
					margin: "large",
					style: "list",
					stretchFactor: 1,
					controls: [
						{
							type: DefaultControls.LayoutBox,
							typeName: 'LayoutBox',
							style: "inline",
							stretchFactor: 1,
							controls: [
								{
									type: DefaultControls.ListBox,
									typeName: 'ListBox',
									name: "index",
									fullRowSelect: true,
									addButton: "Add a index variable",
									height: "large",
									events: [
										{ onEvent: 'listItemAdded', execute: require('./complex2long').onChange_index_added },
										{ onEvent: 'listItemRemoved', execute: require('./complex2long').onChange_index_removed }
									],
									showColumnHeaders: true,
									stretchFactor: 1,
									columns: [
										{
											name: "var",
											label: "Name",
											template:
											{
												type: DefaultControls.TextBox,
												typeName: 'TextBox',
												stretchFactor: 1
											}											
										},
										{
											name: "levels",
											label: "N levels",
											template:
											{
												type: DefaultControls.TextBox,
												typeName: 'TextBox',
												stretchFactor: 0.5
											}											
										}
									]
								}
							]
						}
					]
				}
			]
		}
	]
});

module.exports = { view : view, options: options };
