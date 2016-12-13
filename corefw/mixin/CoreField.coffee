# mixin to share prop/method between fields, but since java side field type is not provided in widgettype, 
# createDataCache will not actually be used in getClassByType as inheritable static method
Ext.define 'Corefw.mixin.CoreField',
	xtype: 'corefield'
	coretype: 'field'
###
	inheritableStatics:
#	TODO this method is neverd called, should be deleted
		createDataCache: (dataObj, cache, parentCache) ->
			props = cache?._myProperties
			# value exists, attach to data object of parent cache
			data = parentCache._myProperties.data
			if not data
				data = {}
				parentCache._myProperties.data = data
			valueFirstTypes = ["combobox"]
			valueFieldQuene = ["displayValue","value"]
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
			return
###