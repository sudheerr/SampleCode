###
	Base class for a tree in a form element
	The class is actually a form container which has a tree as its only child
	All properties are held at the class (ie, form container) level, not at the tree level
###

Ext.define 'Corefw.view.tree.TreeFieldBase',
	extend: 'Ext.form.FieldContainer'
	xtype: 'coretreefieldbase'

	frame: false
	layout: 'fit'
	flex: 1
	margin: 0
	padding: 0
	statics:
		createDataCache: (dataFieldItem, fieldCache) ->
			cm = Corefw.util.Common
			if dataFieldItem
				# old JSON format
				dataObj = cm.objectClone dataFieldItem.children
				fieldCache._myProperties.data = dataObj
			else if fieldCache?._myProperties?.allTopLevelNodes
				fieldCache._myProperties.data = fieldCache._myProperties.allTopLevelNodes
			return

	initComponent: ->
		cm = Corefw.util.Common
		cache = @cache
		props = cache._myProperties
		@coretype = props.coretype
		treeConfig = @createTreeConfig()
		treeConfig.store = @createStore()
		# hide the header panel
		if not props.pageSize and props.showTitleBar is false
			delete treeConfig.title
			delete treeConfig.tools
			delete treeConfig.header
#		cm.configureViewDragAndDrop @, false
		comp = @createTree treeConfig
		# add it to the container, and save a reference to it
		@items = []
		@items.push comp
		@tree = comp
		@callParent arguments
		delete @treeConfig
		return

	generateTreeTool: (navArray) ->
		fieldLabel = @fieldLabel
		@fieldLabel = ''
		#rdr = Corefw.util.Render
		evt = Corefw.util.Event
		cache = @cache
		props = cache._myProperties
		navArray = props?.navs?._ar or []
		if not Ext.isArray navArray
			navArray = []
		@configureFilterButtons props, navArray
		fieldLabelTool =
			xtype: 'text'
			text: (if fieldLabel is '&nbsp;' then '' else fieldLabel)
			margin: '0 10 0 0 '
			cls: 'custom-header'

		navTools = Ext.Array.map navArray, (nav) ->
			toolConfig =
				xtype: 'button'
				ui: 'toolbutton'
				scale: 'small'
				tooltip: nav.toolTip
				iconCls: nav.style
				uipath: nav.uipath
				hidden: not nav.visible
				disabled: not nav.enabled
			if Corefw.util.Startup.getThemeVersion() is 2
				toolConfig.iconCls = 'icon icon-' + Corefw.util.Cache.cssclassToIcon[nav.style]
			evt.addEvents nav, 'nav', toolConfig
			return toolConfig

		return [fieldLabelTool].concat navTools
	configureFilterButtons: (props, tools) ->
		getButtonTpl = ->
			align: 'LEFT'
			cssClass: ''
			cssClassList: []
			enabled: true
			events: {}
			group: {}
			navigationType: 'DEFAULT'
			readOnly: false
			visible: true
			widgetType: 'NAVIGATION'
		themeVersion = Corefw.util.Startup.getThemeVersion()
		fieldItemstype = props.columnAr
		# if filterType is present then showhidefiltr is true and adds a button to grid
		showhidefiltr = @isFilterEnabledForAnyColumn fieldItemstype
		if showhidefiltr
			me = this
			if themeVersion is 2
				showhidefilter = props.hideGridHeaderFilters
				filterVisibility = me.inlineFilterVisibility
				InlineFilterIconCls = if showhidefilter is true then 'icon icon-filterswitch-1' else if filterVisibility is false then 'icon icon-filterswitch-1' else 'icon icon-filterswitch-2'
			else
				InlineFilterIconCls = if me.inlineFilterVisibility is undefined then 'I_SHOWFILTER' else if me.inlineFilterVisibility is false then 'I_HIDEFILTER' else 'I_SHOWFILTER'
			tools.push Ext.apply getButtonTpl(),
				name: 'Hide/show'
				title: 'Hide/show'
				toolTip: 'Hide/Show Filters'
				style: InlineFilterIconCls
				localEvent: true
				handler: ->
					grid = me.grid or me.tree
					thePlugin = grid.findPlugin('inlinefilter')
					if thePlugin.visibility
						thePlugin.visibility = false
						if themeVersion is 2
							@setIconCls('icon icon-filterswitch-1')
						else
							@setIconCls('I_HIDEFILTER')
						thePlugin.resetup grid
					else
						thePlugin.visibility = true
						if themeVersion is 2
							@setIconCls('icon icon-filterswitch-2')
						else
							@setIconCls('I_SHOWFILTER')
						thePlugin.setup grid
					grid.getView().refresh()
					me.inlineFilterVisibility = thePlugin.visibility # to make sure that customerperspective grids are hidden when clicked on other tabs
					return
				# to clear the filters
			tools.push Ext.apply getButtonTpl(),
				name: 'Clear'
				title: 'Clear'
				toolTip: 'Clear All Filters'
				style: if themeVersion is 2 then 'icon icon-filter-delete' else 'I_CLEARFILTER'
				localEvent: true
				handler: ->
					grid = me.grid or me.tree
					thePlugin = grid.findPlugin('inlinefilter')
					thePlugin.resetFilters grid
					return
		return

	# seeing if filterType is enable for any column in the grid
	isFilterEnabledForAnyColumn: (fieldItems) ->
		enabledforcolumn = false
		Ext.each fieldItems, (item) ->
			if typeof item._myProperties.filterType isnt 'undefined'
				enabledforcolumn = true
			return
		return enabledforcolumn

	# function called when this component is first rendered
	onRender: ->
		# set maxHeight so that it scrolls if height exceeds available space
		#		of the enclosing field container
		@callParent arguments

		if @maxHeight
			@tree.maxHeight = @maxHeight
			@tree.setHeight @maxHeight
		return

	createTreeConfig: ->
		su = Corefw.util.Startup
		cache = @cache
		props = cache._myProperties
		treeConfig =
			cache: cache
			selectType: props.selectType
		if props.noLines
			treeConfig.lines = false
		if props.widgetType and props.widgetType is 'TREE_NAVIGATION'
			if su.getThemeVersion() is 2
				treeConfig.cls = 'treedarkstyle'
				treeConfig.bodyStyle =
					background: '#53565A'
		# new JSON property
		treeTools = @generateTreeTool()
		treeConfig.tools = treeTools
		treeConfig.header =
			titlePosition: treeTools.length
		@treeConfig = treeConfig
		return treeConfig

# sets the value of firstColumnName
# subclasses can configure other aspects of the tree as desired
	configureTree: ->
		cache = @cache
		props = cache._myProperties

		# new JSON property
		if props.columnAr
			fieldAr = props.columnAr

			if fieldAr and fieldAr.length
				firstField = fieldAr[0]._myProperties
				firstColumnName = firstField.index + ''
				@firstColumnName = firstColumnName
			else
				@firstColumnName = 'text'

			@displayField = @firstColumnName

		return


	createTree: (treeConfig) ->
		tree = Ext.create 'Corefw.view.tree.TreeBase', treeConfig
		return tree


# returns an array of fields for the store
	createStoreFields: ->
		fields = []

		firstColumnName = @firstColumnName
		newFieldObj =
			name: firstColumnName
		fields.push newFieldObj

		return fields


	createStore: ->
		cache = @cache
		props = cache._myProperties
		dataCache = props.data
		# call this first, before processing store
		if props.enableClientSideSelectAll
			selectallnode =
				children: []
				leaf: false
				expanded: false
				selectable: true
				selected: false
				value:
					0: 'Select All'
			firstnode = dataCache[0]
			if firstnode and firstnode.value[0] isnt 'Select All'
				if firstnode.value[0] isnt '(Select All)'
					dataCache.unshift selectallnode
					props.selectallnode = true

		@configureTree()
		fields = @createStoreFields()
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

		rootObj[@firstColumnName] = 'Root'

		@treeStoreAddChildren rootObj, dataCache

		# see if a store already exists
		# if so, delete it
		oldSt = Ext.getStore storeName
		if oldSt
			oldSt.destroyStore()

		# create the new store
		st = Ext.create 'Ext.data.TreeStore', storeConfig

		return st

	isChildNodeChecked: (nodeObj) ->
		children = nodeObj.children
		for child in children
			if child.selected
				return true
		return false

	configParentNode: (parentNode, shouldExpand, isSemiSelected, isAllSelected) ->
		return if parentNode.id is 'root'
		props = @cache._myProperties
		shouldExpand and props.expandSelectedNode and parentNode.expanded = true
		isSemiSelected and parentNode.semiSelected = true
		isAllSelected and parentNode.selected = true
		return

# create tree store nodes
	treeStoreAddChildren: (node, childrenNodes = []) ->
		return unless childrenNodes and childrenNodes.length > 0
		children = []
		node.children = children
		firstColName = @firstColumnName
		props = @cache._myProperties
		selectType = if props.selectType in ['MULTIPLE', 'SINGLE'] then true else false
		isSemiSelected = false
		semiSelectedNodesCount = 0
		shouldExpand = false
		for child in childrenNodes
			childObj =
				id: child.index
				firstColumnName: firstColName
				leaf: child.leaf
				disabled: child.disabled
				expanded: child.expanded
				semiSelected: false
				selected: child.selected
				origSelected: child.selected
			# set class to first level node
			if node.id is 'root'
				childObj.cls = 'topnodecls' if child.cls
				# set class to last level node if tree is not a lazyLoading tree
			else if not props.lazyLoading and (not child.children or not child.children.length)
				childObj.leaf = true
				childObj.cls = 'noelbow'
			else if child.cls
				childObj.cls = child.cls
			childObj[firstColName] = child.value[firstColName]
			children.push childObj
			if child.children and child.children.length
				@treeStoreAddChildren childObj, child.children
			childObj.selected and semiSelectedNodesCount++
			childObj.checked = (childObj.selected or childObj.semiSelected) if selectType
			isSemiSelected = isSemiSelected or childObj.semiSelected
			shouldExpand = shouldExpand or childObj.selected or childObj.semiSelected
		isAllSelected = semiSelectedNodesCount is childrenNodes.length
		if not isSemiSelected
			isSemiSelected = semiSelectedNodesCount > 0 and not isAllSelected
		# expand all parent nodes if there is any child node is selected and flag 'expandSelectedNode' is true
		@configParentNode node, shouldExpand, isSemiSelected, isAllSelected
		return