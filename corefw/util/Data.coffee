# functions that handle data

Ext.define 'Corefw.util.Data',
	singleton: true

# this function can take a pointer to the top level cache and recursively
# 		parse the data from inside a field
# data belongs in the cache._myProperties.data property of the form above the field
	cacheData3: (cache, parentCache) ->
		props = cache?._myProperties
		if props
			widgetType = props.widgetType

			# process field here
			switch widgetType
				when 'FORM_BASED_ELEMENT', 'BAR_ELEMENT', 'FIELDSET', 'TOOLBAR', 'BREADCRUMB'
					cache._myProperties.data = {}
				when 'FIELD'
				# value exists, attach to data object of parent cache
					if parentCache._myProperties
						data = parentCache._myProperties.data
						if not data
							data = {}
							parentCache._myProperties.data = data
						valueFirstTypes = ["combobox"]
						valueFieldQuene = ["displayValue", "value"]
						if Ext.Array.contains valueFirstTypes, props.type.toLowerCase()
							valueFieldQuene.reverse()
						for field in valueFieldQuene
							val = props[field]
							valList = []
							# it's a hack here, grid picker setValue stuff need to be re-write
							if Ext.isArray(val) and props.type.toLowerCase() is 'grid_picker'
								for oneVal in val
									valList.push oneVal?.displayValue
								val = valList
							if val or val is 0 or val is false
								data[props.name] = val
								return
				when 'OBJECT_GRID', 'HIERARCHY_OBJECT_GRID'
				# simulate a data object
					dataObj = {}
					dataObj.items = props.items
					dataObj.sortHeaders = props.sortHeaders
					Corefw.view.grid.ObjectGrid.createDataCache dataObj, cache
					return
				when 'CHART'
					return
				when 'TREE', 'TREE_WITH_GRID', 'TREE_GRID', 'TREE_NAVIGATION'
					@cacheTreeData dataObj, cache
					return
				when 'GROUPED_GRID'
					props.data = props.values
					delete props.values
					return
				when 'RCGRID'
					Corefw.view.grid.RcGrid.createDataCache dataObj, cache
					return
				when 'MIXED_GRID'
					Corefw.view.tree.TreeMixedGridField.createDataCache dataObj, cache
					return
				else
					if widgetType not in ['APPLICATION', 'PERSPECTIVE', 'VIEW', 'COMPOSITE_ELEMENT']
						console.log 'cacheData3 not found: widgetType, cache: ', widgetType, cache


		for key, nextCache of cache
			if key isnt '_myProperties'
				if not widgetType or widgetType in
					['APPLICATION', 'PERSPECTIVE', 'VIEW', 'COMPOSITE_ELEMENT', 'FIELDSET', 'FORM_BASED_ELEMENT',
					 'BAR_ELEMENT', 'TOOLBAR', 'BREADCRUMB']
					@cacheData3 nextCache, cache

		return

	cacheTreeData: (dataFieldItem, fieldCache) ->
		cm = Corefw.util.Common

		if dataFieldItem
			# old JSON format
			dataObj = cm.objectClone dataFieldItem.children
			fieldCache._myProperties.data = dataObj
		else if fieldCache?._myProperties?.allTopLevelNodes
			fieldCache._myProperties.data = fieldCache._myProperties.allTopLevelNodes
		return

	removeStore: (storeName) ->
		# see if a store already exists
		# if so, delete it
		oldSt = Ext.getStore storeName
		if oldSt
			oldSt.destroyStore()

		return

# returns a model-ish data type for the variable
	getDataType: (val) ->
		if Ext.isBoolean val
			return 'boolean'
		else if Ext.isNumber val
			if val is parseInt val
				return 'int'
			else
				return 'float'
		return 'auto'

# gets the max value of the __index property, plus 1
	getMaxIndex1: (store) ->
		len = store.getCount()
		if not len
			return

		mod = store.getAt 0
		maxIndex = mod.get '__index'

		if len is 1
			return maxIndex

		for i in [1... len]
			mod = store.getAt i
			maxIndex = Math.max(maxIndex, mod.get ('__index'))

		return maxIndex + 1

# cycle through all fields in the form
# we use form fields, because it's possible that the data for that form is missing
	getFieldArray: (formCache) ->
		props = formCache._myProperties
		data = props.data
		fieldAr = []
		for key, field of formCache
			if key is '_myProperties'
				continue

			fieldObj =
				name: key

			type = field._myProperties.type?.toLowerCase()
			if type is 'date'
				fieldObj.type = 'date'

			val = data[key]
			if Ext.isArray(val)
				values = [];
				for singleVal in val
					if typeof singleVal is 'object'
						values.push singleVal.value
					else
						values.push singleVal
				val = values
			else if typeof val is 'object'
				val = val.value

			# if data does exist, set the model type to match the variable type received in the data
			if typeof val isnt 'undefined' and val isnt null
				if type is 'date'
					dt = new Date parseInt val
					data[key] = dt
				else if type is 'datestring'
					fieldObj.type = 'auto'
					data[key] = Ext.Date.parse val, 'Y-m-d H:i:s'
				else
					fieldObj.type = @getDataType val
					data[key] = val

			fieldAr.push fieldObj
		return fieldAr

	createFormStore: (formCache) ->
		cm = Corefw.util.Common
		props = formCache._myProperties
		data = props.data
		fieldAr = @getFieldArray formCache
		# this is here to figure out the application's name
		appName = cm.getAppName()

		storeName = "#{appName}.store.dynamic.#{props.uipath}"

		config =
			fields: fieldAr
			data: data
			id: storeName

		store = Ext.create 'Ext.data.Store', config
		return store

	updateFormStore: (fieldCache) ->
		cm = Corefw.util.Common
		uipath = Corefw.util.Uipath
		path = fieldCache._myProperties.uipath
		formCache = uipath.uipathToParentCacheItem(path)
		@cacheData3(fieldCache, formCache)
		props = formCache._myProperties
		data = props.data
		fieldAr = @getFieldArray formCache
		# this is here to figure out the application's name
		appName = cm.getAppName()
		storeName = "#{appName}.store.dynamic.#{props.uipath}"
		config =
			fields: fieldAr
			data: data
			id: storeName
		store = Ext.create 'Ext.data.Store', config
		return store

	displayFormData: (formComponent, formCache) ->
		store = @createFormStore formCache

		formComponent.loadRecord store.getAt(0), true
		return

	updateDisplayFormData: (formComponent, fieldCache) ->
		store = @updateFormStore fieldCache
		formComponent.loadRecord store.getAt(0)
		return



# given an array of values, will return a store containing those values,
#		in a single column called "val"
# if inputAr is blank or undefined, will return an empty store
	arrayToStore: (name, setName, inputAr, fieldCache) ->
		storeDataAr = []

		dd = Ext.Date.now()
		storeName = name + dd

		storeConfig =
			extend: 'Ext.data.Store'
			storeId: storeName
			fields: [
				name: 'val'
			,
				name: 'dispField'
			,
				name: 'sub_dispField'
			,
				name: 'sub_val'
			]
			data: storeDataAr

		if setName
			# if we're defining a setname, keep the previous store under this setname
			# we also can't use "autoDestroy" because we need the values of the previous store
			#		around for a short time

			# save the storeId in a global cache
			iv = Corefw.util.InternalVar
			ivKey = 'arrayToStore' + setName
			oldStoreArray = iv.getArray ivKey

			if oldStoreArray.length > 1
				# delete the oldest store
				oldStoreId = oldStoreArray[0]
				@removeStore oldStoreId
				iv.removeIndexFromArray ivKey, 0

			# now add the new store
			iv.addToArray ivKey, storeName
		else
			storeConfig.autoDestroy = true

		# add the records
		if inputAr and Ext.isArray(inputAr) and inputAr.length
			encodeValue = @encodeValue
			for value in inputAr
				if typeof value is 'string' or typeof value is 'number'
					dataObj =
						dispField: encodeValue value
						val: value
						sub_dispField: encodeValue value
						sub_val: value
					storeDataAr.push dataObj
				else if typeof value is 'object'
					if value.valueField isnt null and typeof value.valueField isnt 'undefined' and value.displayField isnt null and typeof value.displayField isnt 'undefined'
						dataObj =
							dispField: encodeValue value.displayField
							val: value.valueField
							sub_dispField: encodeValue value.sub_displayField
							sub_val: value.sub_valueField
					else if value.displayValue isnt null and typeof value.displayValue isnt 'undefined' and value.value isnt null and typeof value.value isnt 'undefined'
						dataObj =
							dispField: encodeValue value.displayValue
							val: value.value
							sub_dispField: encodeValue value.sub_displayValue
							sub_val: value.sub_value
					else
						continue
					storeDataAr.push dataObj

		st = Ext.create 'Ext.data.Store', storeConfig

		return st

	encodeValue: (value) ->
		try
			return Ext.htmlEncode value
		catch error
			return value
