Ext.define 'Corefw.model.DomainTreeNode',
	extend: 'Ext.data.TreeModel'
	fields: [
		{
			name: 'path'
			type: 'string'
		}
		{
			name: 'text'
			type: 'string'
		}
		{
			name: 'leaf'
			type: 'boolean'
		}
		{
			name: 'lookupable'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'measure'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'isItemList'
			type: 'boolean'
		}
		{
			name: 'qtip'
			type: 'string'
		}
		{
			name: 'dataTypeString'
			type: 'string'
		}
		{
			name: 'prominence'
			type: 'string'
		}
		{
			name: 'underCollection'
			type: 'boolean'
		}
		{
			name: 'repetitiveRatio'
			type: 'int'
			defaultValue: -1
		}
	]
	isLookupable: ->
		@get 'lookupable'
	isMeasure: ->
		@get 'measure'