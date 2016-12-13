###
	implements a tree with multiple columns, similar to a grid
	the tree is in the first column
###

Ext.define 'Corefw.view.tree.TreeGrid',
	extend: 'Corefw.view.tree.TreeFieldBase'
	xtype: 'coretreegrid'
	mixins: ['Corefw.mixin.Grid']
	hideLabel: true

	afterRender: ->
		@callParent arguments
		@createPagingToolbar()
		me = this
		# this is to fix grid header height layout issue, 1615346-4635, no other better ideas
		# TODO find a better approach
		delayedFn = Ext.Function.createDelayed ->
			headercontainer = me.down 'headercontainer'
			if headercontainer and headercontainer.updateLayout
				headercontainer.updateLayout isRoot: false
			return
		, 1
		delayedFn()
		return

	# overrides a method in the base class
	configureTree: ->
		treeCache = @cache
		props = treeCache._myProperties
		treeConfig = @treeConfig
		columns = []
		storeFields = @storeFields = []
		me = this
		addlConfig =
			columns: columns
			name: props.name
			columnLines: true
			cls: 'treegrid'
			viewType: 'coretreebaseview'
			lockedGridConfig:
				viewType: 'coretreebaseview'
			viewConfig:
				stripeRows: true
				enableTextSelection: true
				listeners:
					refresh: (dataview) ->
						me.setSelection()

		Ext.apply treeConfig, addlConfig

		columnArray = props.columnAr
		if columnArray and columnArray.length
			for column, index in columnArray
				colprops = column._myProperties
				# first column
				if index is 0
					@firstField = column
					@firstColumnName = colprops.dataIndex
					xtype = 'treecolumn'
				else
					if colprops.type is 'COMBOBOX'
						xtype = 'corecombocolumn'
					else
						xtype = 'gridcolumn'

				newColumnObj =
					xtype: xtype
					width: 150
					text: colprops.title
					name: colprops.name
					dataIndex: colprops.index + ''
				columns.push newColumnObj

				if colprops.editable
					props.editableColumns = true
					props.editable = true

				newStoreFieldObj =
					name: colprops.index + ''
				colType = colprops.type.toLowerCase()
				if colType is 'date' or colType is 'datetime'
					newStoreFieldObj.type = 'date'
				storeFields.push newStoreFieldObj
		@configSelType()
		@configureTool()

		return

	setSelection: ->
		# set the selected record
		selectArray = []
		st = @store
		return unless st
		nodeHash = st.tree.nodeHash
		len = Object.keys nodeHash
		for key, record of nodeHash
			props = record.raw._myProperties
			if props and props.selected
				selectArray.push record

		if selectArray.length
			@getSelectionModel().select selectArray, false, true
		return

	createPagingToolbar: ->
		su = Corefw.util.Startup
		me = this
		props = @cache._myProperties

		# set correct params for store
		addlStoreConfig =
			totalCount: props.totalRows
			pageSize: props.pageSize
			currentPage: props.currentPage
			selectablePageSizes: props.selectablePageSizes
			# replace the store's default loadPage behavior with our own
			getTotalCount: ->
				return props.totalRows
			loadPage: (pageNum) ->
				me.loadPageForTreeGrid pageNum
				return
			nextPage: ->
				me.loadPageForTreeGrid @currentPage + 1
				return
			previousPage: ->
				me.loadPageForTreeGrid @currentPage - 1
				return
		Ext.apply @tree.store, addlStoreConfig

		if not props.pageSize
			return

		pagingToolbarConfig =
			xtype: 'corepagingtoolbar'
			store: @tree.store
			cache: props
			displayInfo: true
			margin: '0 20 0 0'
		if su.getThemeVersion() is 2
			pagingToolbarConfig.displayInfo = false
			pagingToolbarConfig.margin = ' 0 8 0 0'

		header = @down 'header'
		if not header
			return
		header.insert header.items.length, pagingToolbarConfig
		return

	generatePagingPostData: (pageNum, pageSize, total) ->
		prop = @cache._myProperties
		pageNum = pageNum or 1
		pageSize = pageSize or prop.pageSize or 1
		total = total or prop.totalRows or 1
		if pageNum > Math.ceil(total / pageSize)
			pageNum = Math.ceil(total / pageSize)

		postData =
			name: @cache._myProperties.name
			total: total
			currentPage: pageNum
			pageSize: pageSize
		return postData

	loadPageForTreeGrid: (pageNum) ->
		rq = Corefw.util.Request
		events = @cache?._myProperties?.events or {}
		eventstr = if events.ONRETRIEVE then 'ONRETRIEVE' else 'ONLOAD'
		url = rq.objsToUrl3 @eventURLs[eventstr], @localUrl
		pageSize = @tree.store.pageSize
		postData = @generatePagingPostData pageNum ,pageSize
		rq.sendRequest5 url, rq.processResponseObject, @uipath, postData
		return

	configureTool: ->
		me = this
		treeConfig = me.treeConfig
		evt = Corefw.util.Event
		su = Corefw.util.Startup

		cache = me.cache
		fieldProps = cache._myProperties
		functionButtonType = 'tool'
		treeConfig?.functionButtonType = functionButtonType
		fieldLabelTool =
			xtype: 'text'
			text: fieldProps.title
			margin: '0 10 0 0'
			cls: 'custom-header'

		switch functionButtonType
			when 'tool'
				tools = []
				tools.push fieldLabelTool
			when 'toolbar'
				dockedItems = []
				tbar = []
				topBar =
					xtype: 'toolbar'
					dock: 'top'
					items: tbar
				dockedItems.push topBar
			else
				break


		navAr = fieldProps?.navs?._ar
		if navAr
			for nav in navAr
				gridToolObj =
					uipath: nav.uipath
					hidden: not nav.visible
					disabled: not nav.enabled

				switch functionButtonType
					when 'tool'
						addlConfig =
							xtype: 'button'
							ui: 'toolbutton'
							scale: 'small'
							style: 'margin-right:6px; background-color:white;'
							tooltip: nav.toolTip
							iconCls: nav.style

						if su.getThemeVersion() is 2
							addlConfig.iconCls = 'icon icon-' + Corefw.util.Cache.cssclassToIcon[nav.style]
							addlConfig.style = 'margin-right:6px'
						Ext.apply gridToolObj, addlConfig
						tools.push gridToolObj

					when 'toolbar'
						config =
							margin: '0 0 0 9'
						if nav.title
							config.text = nav.title
						else
							config.text = ' '

						if not not nav.style
							config.iconCls = nav.style

						Ext.apply gridToolObj, config
						tbar.push gridToolObj

				if nav.localEvent
					gridToolObj.handler = nav.handler
				else
					evt.addEvents nav, 'nav', gridToolObj

		# only show the toolbar if editable is set to TRUE
		if fieldProps.editable or tbar?.length > 0 or tools?.length > 0
			switch functionButtonType
				when 'tool'
					treeConfig.tools = tools
				when 'toolbar'
					treeConfig.dockedItems = dockedItems
		return


# returns an array of fields for the store
# overrides a method in the base class
# always called after configureTree, which builds the storeFields class variable
	createStoreFields: ->
		return @storeFields

# overrides a method in the base class
	treeStoreAddChildren: (nodeObj, childrenArray) ->
		cm = Corefw.util.Common
		cache = @cache

		fieldObj = {}
		for key, colObj of cache
			if key isnt '_myProperties'
				prop = colObj._myProperties
				dataIndex = prop.index + ''
				fieldObj[dataIndex] = prop

		if childrenArray and childrenArray.length
			children = []
			nodeObj.children = children

			copyProperties = [
				'changed'
				'removed'
				'new'
				'selected'
				'selectable'
				'validValues'
				'messages'
				'cssClass'
				'cellCssClass'
			]

			directCopyProps = [
				'expanded'
			]

			for child in childrenArray
				dataObj = cm.objectClone child.value

				cm.parseDateData dataObj, fieldObj

				dataObj.__index = child.index
				dataObj._myProperties = {}
				cm.copyObjProperties dataObj._myProperties, child, copyProperties
				cm.copyObjProperties dataObj, child, directCopyProps

				children.push dataObj
				@treeStoreAddChildren dataObj, child.children
		else
			nodeObj.leaf = true

		return

# note: very similar to GridBase version.
# possible refactoring project for the future
	generatePostData: ->
		postData =
			name: @name

		tree = @tree
		columns = tree.columns
		selected = tree.selModel.selected
		forcedSelectRec = @forcedSelectedRecord

		# list of columns that we're interested in
		dataIndexArray = []
		for column in columns
			dataIndexArray.push column.dataIndex

		postDataItems = []
		postData.allTopLevelNodes = postDataItems

		fetchValue = (item) ->
			if Ext.isObject item
				return item.value
			return item

		modelToRowObj = (inputModel) ->
			retRowObj = {}
			values = {}
			retRowObj.value = values

			if forcedSelectRec
				if forcedSelectRec is inputModel
					retRowObj.selected = true
				else
					retRowObj.selected = false
			else
				if selected.contains inputModel
					retRowObj.selected = true
				else
					retRowObj.selected = false

			for field in storeFields
				fieldDataIndex = field.name
				if fieldDataIndex in dataIndexArray
					val = inputModel.get fieldDataIndex

					if field.type.type is 'date'
						if val
							val = val.valueOf()
						else
							val = ''
					if val is null or val is undefined
						values[fieldDataIndex] = ''
						continue
					if Ext.isArray val
						vals = []
						Ext.each(val, (item) ->
							vals.push fetchValue item
							return
						)
						values[fieldDataIndex] = vals
					else
						values[fieldDataIndex] = fetchValue val
			# see if the "index" property exists
			# if not, add it here
			if not retRowObj.index
				retRowObj.index = inputModel.raw.__index
			return retRowObj


		# storeDataArray: source array that holds info, in property childNodes
		# postDataArray: pointer to destination array in postData
		generatePostDataCreateChildren = (storeDataArray, postDataArray) ->
			for record in storeDataArray
				rowObj = modelToRowObj record
				rowObj.editing = if record.isEditing then true else false
				rowObj.new = if record.phantom then true else false
				rowObj.changed = if record.dirty then true else false
				rowObj.removed = false
				rowObj.expanded = if record.data.expanded then true else false

				postDataArray.push rowObj

				children = record.childNodes
				if children and children.length
					childrenArray = []
					rowObj.children = childrenArray
					generatePostDataCreateChildren children, childrenArray

			return


		st = tree.getStore()
		storeModel = st.getProxy().getModel()
		storeFields = storeModel.getFields()

		childNodes = st.tree?.root?.childNodes
		if childNodes and childNodes.length
			generatePostDataCreateChildren childNodes, postDataItems
		postData.allContents = @generateHeadersPostData tree.cache
		return postData