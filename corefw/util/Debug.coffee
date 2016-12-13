Ext.define 'Corefw.util.Debug',
	singleton: true

	printOutGridFields: ->
		return false

	printOutViews: ->
		return false

	printOutRawResponse: ->
		return false

	addDebugFunctions: ->
		su = Corefw.util.Startup
		startupObj = su.getStartupObj()
		if startupObj and startupObj.debugMode
			Ext.StoreManager.list = ->
				Ext.StoreManager.each (store) ->
					console.log store.getCount(), store.storeId

