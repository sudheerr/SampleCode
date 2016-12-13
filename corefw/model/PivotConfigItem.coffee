Ext.define 'Corefw.model.PivotConfigItem',
	extend: 'Ext.data.Model'
	
	fields: [
		{name: 'name', type: 'string'}
		{name: 'path', type: 'string'}
		{name: 'measure', type: 'boolean'}
		{name: 'aggregate', type: 'boolean', defaultValue: false}
		{name: 'sortby', type: 'string', defaultValue: "ASC"}
	]

	idProperty: 'path'

	copyFrom: (record, keyMapping={}) ->
		@fields.each (field) ->
			key = field.name
			targetKey = if keyMapping[key] then keyMapping[key] else key
			@set key, record.get(targetKey) if record.get(targetKey)
		, this