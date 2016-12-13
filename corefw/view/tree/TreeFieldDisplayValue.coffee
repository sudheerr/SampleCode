Ext.define 'Corefw.view.tree.TreeFieldDisplayValue',
	extend: 'Corefw.view.tree.TreeFieldBase'
	xtype: 'coretreefielddisplayvalue'


	createStore: () ->
		cache = @cache
		props = cache._myProperties
		dataCache = props.data
		@configureTree()
		fields = []

		storeName = props.uipath + '-Store'
		rootObj =
			id: 'root'
		storeConfig =
			extend: 'Ext.data.TreeStore'
			autoDestroy: true
			fields: fields
			storeId: storeName
			root: rootObj
			proxy:
				type: 'memory'

		valueColumnName = @valueColumn.index + ''
		displayColumnName = @displayColumn.index + ''

		fields.push valueColumnName, displayColumnName
		@treeStoreAddChildren rootObj, dataCache
		oldSt = Ext.getStore storeName
		if oldSt
			oldSt.destroyStore()
		st = Ext.create 'Ext.data.TreeStore', storeConfig
		return st

	configureTree: () ->
		cache = @cache
		props = cache._myProperties
		fieldAr = props.columnAr
		if fieldAr and fieldAr.length
			@valueColumn = fieldAr[0]
			@displayColumn = if fieldAr.length > 1 then fieldAr[1] else fieldAr[0]
		else
			@displayColumn =
				pathString: 'text'

		@valueColumn = @valueColumn._myProperties
		@displayColumn = @displayColumn._myProperties

		@treeConfig.valueField = @valueColumn.index + ''
		@treeConfig.displayField = @displayColumn.index + ''

		return

	treeStoreAddChildren: (nodeObj, childrenArray) ->
		props = @cache._myProperties
		if childrenArray and childrenArray.length
			children = []
			nodeObj.children = children
			for child in childrenArray
				if not child
					continue
				childObj =
					id: child.index
					disabled: child.disabled
					matching: child.matching
				Ext.apply childObj, child.value
				# further configuration of child nodes if necessary
				if @configureTreeChildren
					@configureTreeChildren childObj, child
				if child.leaf
					childObj.leaf = child.leaf
				if not props.lazyLoading
					if not child.children or not child.children.length
						childObj.leaf = true
						childObj.cls = 'noelbow'

				# old JSON
				if props.selectType in ['multiple', 'single']
					childObj.checked = child.isSelected

				# new JSON
				if props.selectType in ['MULTIPLE', 'SINGLE']
					childObj.checked = child.selected

				children.push childObj

				if child.children and child.children.length
					@treeStoreAddChildren childObj, child.children

		return