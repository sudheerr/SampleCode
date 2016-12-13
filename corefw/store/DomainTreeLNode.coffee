Ext.define 'Corefw.store.DomainTreeLNode',
	extend: 'Ext.data.Store'
	fields: [
		{
			name: 'path'
			type: 'string'
		}
		{
			name: 'facadePathString'
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
			name: 'searchString'
			type: 'string'
		}
		{
			name: 'customizedPath'
			type: 'string'
		}
		{
			name: 'groupable'
			type: 'boolean'
		}
		{
			name: 'underCollection'
			type: 'boolean'
		}
		{
			name: 'isMinDepth'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'isLastMinDepth'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'repetitveRatio'
			type: 'int'
			defaultValue: -1
		}
	]
	autoLoad: false
	proxy:
		type: 'rest'
		actionMethods:
			read: 'POST'
		url: 'api/pivot/domainTree/search'
		reader:
			type: 'json'