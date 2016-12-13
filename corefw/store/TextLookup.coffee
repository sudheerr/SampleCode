Ext.define 'Corefw.store.TextLookup',
	extend: 'Ext.data.Store'

	fields: ['text']
	queryKeyName: 'pathString'
	queryValueName: 'operand'
	proxy:
		type: 'rest'
		url: 'api/pivot/lookup'
		actionMethods:
			read: 'POST'
		reader: 
			type: 'json'

	getTypesRegex: (types)->
		if types and types.length
			return new RegExp("("+types.join(")|(")+")", "i")
		else
			return false

	findByTypes: (types)->
		return @find 'text', @getTypesRegex(types)

	filterData: (types)->
		regex = @getTypesRegex types
		if regex
			@filterBy (item)->
				return regex.test item.get("text")
		else
			@filterBy (item)->
				return false

	listeners: 
		beforeload: (me, operation, eOpts) ->
			operation.params = operation.params or {}
			operation.params[@queryKeyName] = this[@queryKeyName]
			operation.params[@queryValueName] = 
				if operation.params?.query then operation.params.query else this[@queryValueName]
			return