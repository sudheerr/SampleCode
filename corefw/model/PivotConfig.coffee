Ext.define 'Corefw.model.PivotConfig',
	extend: 'Ext.data.Model'

	requires: [
		'Corefw.model.PivotConfigItem'
		'Corefw.model.PivotValueConfigItem'
		'Corefw.model.FilterCriteria'
		'Corefw.data.writer.Json'
	]

	hasMany: [
		{
			name: 'rowLabels'
			model: 'Corefw.model.PivotConfigItem'
		}
		{
			name: 'columnLabels'
			model: 'Corefw.model.PivotConfigItem'
		}
		{
			name: 'values'
			model: 'Corefw.model.PivotValueConfigItem'
		}
		{
			name: 'filter'
			model: 'Corefw.model.FilterCriteria'
		}
	]

	proxy:
		type: 'rest'
		url: 'api/pivot/pivotConfig'
		batchActions: true
		actionMethods:
			read: 'POST'
			update: 'PUT'
		reader:
			type: 'json'
		writer:
			type: 'deepJson'
			root: 'pivotConfig'