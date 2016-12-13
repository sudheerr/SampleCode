Ext.define 'Corefw.view.grid.GridBase',
	extend: 'Ext.grid.Panel'
	mixins: ['Corefw.mixin.Grid']
	xtype: 'coregridbase'

	defaultDef:
		lockable: false

	plugins: [{
		ptype: 'inlinefilter'
	}, {
		ptype: 'columnselectorplugin'
	}]

	columnLines: true
	viewConfig:
		enableTextSelection: true
# hack: for some reason, xtype: 'coregridbase' is not working right now
	coregridbase: true

	standardRowHeight: 21

	initComponent: ->
		@columnGroups = {}
		# disalbe gridheaderreorderer plugin
		@enableColumnMove = false
		colPlugins = @columns?.plugins or []
		colPlugins.push 'gridheaderreorderer'
		@columns = @columns or {}
		cm = Corefw.util.Common
		Ext.apply @columns,
			defaults: cm.objectClone @defaultDef
			items: []
			plugins: colPlugins
		me = this
		@initalizeGridBase()
		@addGridListeners()
		@callParent arguments
		@headerCt.on afterlayout: me.setMinAndMaxHeightToView
		# Extjs issue, lockable grid must specify its view ready with @lockedViewConfig
		## a more extendable way to add 'viewready' event to lockedGrid's view
		@lockedGrid?.view?.on('viewready', ->
			me.onViewReady()
			return
		)
		@syncRowHeight = true
		delete @columnGroups
		return

	addGridListeners: ->
		@listeners = @listeners or {}
		additionalListeners =
			beforeedit: @onGridBeforeEdit
			edit: @onGridEdit
			beforeexpand: @onGridPanelExpand
			beforecollapse: @onGridPanelCollapse
			resize: @onGridResize
		Ext.merge @listeners, additionalListeners
		@addListeners()

	onGridBeforeEdit: (evt, cell) ->
		radiogroups = Ext.ComponentQuery.query 'radiogroup'
		keyValObj = {}
		for radiogroup in radiogroups
			keyValObj[radiogroup.name] = cell.grid.getStore().getAt(cell.rowIdx).get(radiogroup.name)
			radiogroup.reset()
			radiogroup.setValue keyValObj
		return

	onGridEdit: (evt, cell) ->
		radiogroups = Ext.ComponentQuery.query 'radiogroup'
		grid = cell.grid
		for radiogroup in radiogroups
			if radiogroup.getChecked()[0]
				grid.getStore().getAt(cell.rowIdx).set(radiogroup.name, radiogroup.getChecked()[0].inputValue)
		grid.styleDecorate()
		return

	onGridPanelCollapse: ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			if not @header
				return
			ref = @header.items.items
			i = 0
			len = ref.length
			while i < len
				index = ref[i]
				itemXtype = index.xtype
				if itemXtype is 'tool' or itemXtype is 'text'
					index.show()
				else
					index.el.setStyle 'display', 'none'
				i++

		for index in @tools
			if index.xtype is 'tool'
				index.removeCls 'gridexpandCls'
				index.addCls 'gridcollapsedCls'
		return

	onGridPanelExpand: ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			if not @header
				return
			ref = @header.items.items
			i = 0
			len = ref.length
			while i < len
				index = ref[i]
				index.el.setStyle 'display', 'inline-block'
				i++
		for index in @tools
			if index.xtype is 'tool'
				index.removeCls 'gridcollapsedCls'
				index.addCls 'gridexpandCls'
		return

	updateTitle: (title) ->
		titleLabel = @down '[name=fieldLabel]'
		titleLabel?.setText title

	onGridResize: (grid, width, height, oldWidth, oldHeight) ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			paginationBar = grid.down 'corepagingtoolbar'
			if width isnt oldWidth and paginationBar
				# If grid header width is not enough, move pagination into show more menu
				items = []
				menu = grid.queryById('pageMoreBtn').menu
				barItems = paginationBar.items.items
				pageNavCtn = menu.child('#pageNavCtn')
				ctnItems = pageNavCtn.items.items
				fillWidth = grid.header.child('tbfill')?.getWidth()
				titleWidth = grid.header.titleCmp?.getWidth()
				menuWidth = if menu.rendered then menu.getWidth() else menu.minWidth
				if fillWidth is 0 and ctnItems.length is 0
					for item in barItems
						# Keep 'Page' text and show more button in toolbar
						if item.text isnt paginationBar.beforePageText and item.itemId isnt 'pageMoreBtn'
							items.push item
					for item in items
						pageNavCtn.add item
					pageNavCtn.setVisible true
				else if (fillWidth + titleWidth) > menuWidth and ctnItems.length > 0
					items = ctnItems.slice 0
					i = 0
					for item in items
						if i < 3
							paginationBar.insert i, item
						else
							paginationBar.insert (i + 1), item
						i++
					pageNavCtn.setVisible false
				# Reset the position of show more menu
				if menu.isVisible()
					menu.showBy grid.child('header'), 'tr-br', [0, 1]
		return

	initalizeGridBase: ->
		grid = this
		su = Corefw.util.Startup
		cache = @cache
		props = cache._myProperties

		not su.useClassicTheme() and grid.ui = 'citiriskdatagrid'
		if su.getThemeVersion() is 2
			grid.bodyStyle =
				borderBottom: '2px solid #656262'
		props.collapsible and (grid.collapsible = grid.titleCollapse = props.collapsible)
		itemsArray = grid.columns?.items or []
		grid.createColumnsFromCache itemsArray
		props.numberOfLockedHeaders > 0 and @isLockedView = true
		@configurePlugins props, true
		if props.groupField
			grid.features = [
				ftype: 'coregroupingsummary'
				groupHeaderTpl: '{name}'
				hideGroupedHeader: true
				enableGroupingMenu: false
				showSummaryRow: false
			]
		if props.enableTextSelection is undefined
			grid.viewConfig.enableTextSelection = false
		else
			grid.viewConfig.enableTextSelection = props.enableTextSelection
		grid.applyStore true
		grid.configSelType()
		grid.hideCollapseTool = true
		return

	addCloseBtn: ->
		me = this
		clsBtnCfg =
			xtype: 'tool',
			type: 'close',
			name: 'close-button'
			tooltip: 'close'
			docked: 'right'
			handler: ->
				field = me.up()
				field.fireEvent 'gridclose', field
				return
		if @header
			@header.add clsBtnCfg
		return

# called after this grid renders
	afterRender: ->
		@callParent arguments
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			header = @getHeader()
			if header
				header.setHeight(32)
				@addExpCollBtn()
		if @collapsible
			@addSecondTitle()

		props = @cache._myProperties

		# to avoid trigger onSelect event before rendered
		@up()?.enableSelectEvent = true
		if props.closable
			@addCloseBtn()
		return

	addExpCollBtn: ->
		#Adding Expand or collapse button for the new theme
		me = @up().grid
		if not me.header
			return
		elementForm = @up('coreelementform')
		if elementForm.collapsible
			ExpCollBtn =
				xtype: 'tool'
				type: 'collapse-' + me.collapseDirection
				docked: 'right'
				scope: me
				handler: me.toggleCollapse
			if me.collapsed
				ExpCollBtn.cls = 'gridcollapsedCls'
			else
				ExpCollBtn.cls = 'gridexpandCls'

			me.header.add ExpCollBtn
		return

	onViewReady: ->
		@callParent arguments

		container = @up '[listenGridViewReady=true]'
		if container
			container.fireEvent 'gridviewready'
		me = this
		Ext.Function.createDelayed(->
			me.restoreHeaderSortState()
		, 1)()
		return

# adds an icon denoting the grid's collapsed state
	addSecondTitle: ->
		rdr = Corefw.util.Render
		rdr.addSecondTitle this
		return

# add a row to the grid
	addRowToGrid: ->
		store = @store
		fields = store.getProxy().getModel().getFields()
		newObj = {}

		for field in fields
			newObj[field.name] = ''

		modArray = store.add newObj
		if modArray and modArray.length
			mod = modArray[0]
			mod.set '__index', Corefw.util.Data.getMaxIndex1 store

		# scroll to the bottom of the grid
		@getView().scrollBy 0, 999, false
		return


# deletes all the rows that are currently selected
	deleteRowsFromGrid: ->
		store = @store
		selected = @selModel.selected

		selected.each (model) ->
			store.remove model
			return

	setSelection: ->
		# set the selected record
		selectArray = []
		st = @store
		len = st.getCount()
		for i in [0... len]
			record = st.getAt i
			props = record.get '_myProperties'
			if props and props.selected
				selectArray.push record

		if selectArray.length
			@getSelectionModel().select selectArray, false, true
		return

	isColumnInSortHeader: (columnDataIndex) ->
		sortHeaders = @cache._myProperties?.sortHeaders
		for header in sortHeaders
			if header.index + '' is columnDataIndex
				return true
		return    false

# in the cache, inputAr points to cache._myProperties.data.items
	createStore: ->
		cache = @cache
		props = cache._myProperties
		pageSize = props.pageSize
		bufferZone = 0
		uipath = props.uipath
		storeId = uipath + '/Store'
		dataItems = props?.data?.items
		if not dataItems
			return

		@prepareFieldObj()

		storeDataAr = []
		fields = []
		columnAr = props.columnAr
		groupIndex
		me = this
		groupField = props.groupField
		requestUrl = @getRequestUrl()
		if groupField
			proxy =
				type: 'ajax'
			for column in  columnAr
				if column._myProperties.pathString is groupField
					groupIndex = column._myProperties.index.toString()
					break
		storeConfig =
			autoDestroy: false
			fields: fields
			storeId: storeId
			data: storeDataAr
			remoteSort: true
			groupField: groupIndex
			proxy: proxy
			sort: (sorters) ->
				sorts = []
				if me.isColumnInSortHeader sorters.property
					sortHeaders = me.cache._myProperties?.sortHeaders
					for header in sortHeaders
						dataIndex = header.index + ''
						if dataIndex isnt sorters.property
							sorts.push {property: header.dataIndex, direction: header.sortBy}
						else
							sorts.push sorters
				else
					sorts.push sorters

				grid = Ext.ComponentQuery.query('[uipath=' + uipath + ']')[0].grid
				grid.sort sorts
				return
		if props.infinity
			reader = Ext.create 'Corefw.data.reader.Json',
				root: 'items' # for ExtJs 4
				rootProperty: 'items' # for ExtJs 5
				totalProperty: 'totalRows'
				jsonResolver: (responseJson) ->
					totalRows = responseJson.totalRows or 0
					items = responseJson.items or []
					items = items.map (item) -> item.value
					result =
						totalRows: totalRows
						items: items
					return result
			proxy =
				type: 'coreajax'
				url: requestUrl
				reader: reader
				paramsAsJson: true
				simpleSortMode: false
				limitParam: 'pageSize'
				sortParam: 'sortHeaders'
				pageParam: 'currentPage'
				extraParams:
					retriveItemSize: pageSize
					scrollStr: 'INITIAL'
				actionMethods:
					create: 'POST'
					read: 'POST'
					update: 'POST'
					destroy: 'POST'

			storeConfig =
				autoDestroy: false
				pageSize: pageSize
				fields: fields
				storeId: storeId
				buffered: true
				autoLoad: true
				remoteSort: true
				groupField: groupIndex
				proxy: proxy
				model: 'ForumThread'
				remoteGroup: true
				leadingBufferZone: bufferZone
				trailingBufferZone: bufferZone
				decodeSorters: (sorters) ->
					unless Ext.isArray(sorters)
						if sorters is `undefined`
							sorters = []
						else
							sorters = [ sorters ]

					grid = Ext.ComponentQuery.query('[uipath=' + uipath + ']')[0].grid
					parent = grid.up 'fieldcontainer'
					parentProps = parent.cache._myProperties

					contents = parentProps.allContents
					for sorter in sorters
						for content in contents
							if content.index + '' is sorter.property
								sorter.name =  content.name

					length = sorters.length
					Sorter = Ext.util.Sorter
					fields = (if @model then @model::fields else null)
					field = undefined
					config = undefined
					i = undefined
					i = 0
					while i < length
						config = sorters[i]
						unless config instanceof Sorter
							config = property: config  if Ext.isString(config)
							Ext.applyIf config,
								root: @sortRoot
								direction: 'ASC'


							#support for 3.x style sorters where a function can be defined as 'fn'
							config.sorterFn = config.fn  if config.fn

							#support a function to be passed as a sorter definition
							config = sorterFn: config  if typeof config is 'function'

							# ensure sortType gets pushed on if necessary
							if fields and not config.transform
								field = fields.get(config.property)
								config.transform = (if field and field.sortType isnt Ext.identityFn then field.sortType else `undefined`)
							sorters[i] = new Ext.util.Sorter(config)
						i++
					return sorters

				listeners:
					groupchange: (store, groupers) ->
						sortable = not store.isGrouped()
						headers = grid.headerCt.getVisibleGridColumns()
						i = undefined
						len = headers.length
						i = 0
						while i < len
							headers[i].sortable = (if (headers[i].sortable isnt `undefined`) then headers[i].sortable else sortable)
							i++


					# This particular service cannot sort on more than one field, so if grouped, disable sorting
					beforeprefetch: (store, operation) ->
						delete operation.sorters  if operation.groupers and operation.groupers.length


		if dataItems and Ext.isArray(dataItems) and columnAr and columnAr.length
			fieldObj = @fieldObj
			for column in columnAr
				props = column._myProperties
				dataIndex = props.index + ''
				storeFieldObj =
					name: dataIndex

				type = fieldObj[dataIndex]?.type?.toLowerCase()
				columnType = fieldObj[dataIndex]?.columnType?.toLowerCase()

				storeFieldObj.columnType = columnType

				if type is 'date' or columnType is 'date' or columnType is 'datetime'
					storeFieldObj.type = 'date'

				fields.push storeFieldObj
			if not props.infinity
				@parseData dataItems, storeDataAr, fieldObj

		fields.push {name: '_myProperties'}, {name: '__index'}

		st = Ext.create 'Ext.data.Store', storeConfig

		return st

	applyStore: (shouldRecreate) ->
		@skipCancelEditing = true
		uipath = @cache?._myProperties.uipath
		myStore = Ext.StoreManager.lookup uipath + '/Store'
		if shouldRecreate and myStore
			Ext.StoreManager.remove myStore
			myStore = null
			@store = null

		if not @storeAlreadyAttached and not @store and not myStore
			myStore = @createStore()
		else
			@updateStore myStore
		@store = myStore
		delete @skipCancelEditing
		return

	updateFromCache: (cache) ->
		@cache = @updateCache cache
		if @shouldReconfigure?()
			@reconfigureGrid?()
		else
			isEditing = @isEditing
			@applyStore()
			if isEditing
				@isEditing = true
				@restoreGridEditor()
		return

	updateStoreFromCache: (cache) ->
		@cache = @updateCache cache
		@applyStore()
		res = @validateColumnOrdersFromCache()
		if not res.isValid
			@reconfigure @store, res.columnsDef
		paginationBar = @down 'corepagingtoolbar'
		paginationBar?.onLoad()
		return

	cacheScrollValue: ->
		me = this
		scrolledDescendants = []
		scrollValues = []
		result = ->
			for el, i in scrolledDescendants
				el.setScrollLeft scrollValues[i][0]
				el.setScrollTop scrollValues[i][1]
			return

		if @lockable
			el = @view?.lockedView?.el
			if el
				scroll = el.getScroll()
				scrolledDescendants[0] = el
				scrollValues[0] = [scroll.left, scroll.top]

			el = @view?.normalView?.el
			if el
				scroll = el.getScroll()
				scrolledDescendants[1] = el
				scrollValues[1] = [scroll.left, scroll.top]
		else
			el = @view.el
			if el
				scroll = el.getScroll()
				scrolledDescendants[0] = el
				scrollValues[0] =  [scroll.left, scroll.top]

		return result

	updateStore: (store) ->
		cache = @cache
		props = cache._myProperties
		fieldObj = @getFieldObj props.uipath
		dataItems = props?.data?.items
		if not dataItems
			return
		storeDataAr = []
		@parseData dataItems, storeDataAr, fieldObj

		@view.preserveScrollOnRefresh = true
		store.loadRawData storeDataAr
		if props.totalRows
			store.totalCount = props.totalRows
		if props.currentPage
			store.currentPage = props.currentPage

		return

	restoreGridEditor: ->
		if @rowEditor
			@rowEditor.isSkipBeforeEdit = true
			@rowEditor.restoreEditor()
			@rowEditor.isSkipBeforeEdit = false

	sort: (sorters) ->
		if not Ext.isArray sorters
			sorters = [sorters]
		parent = @up 'fieldcontainer'
		parentProps = parent.cache._myProperties

		##to make sorters a parameter as array, to multi-column Sort
		sortHeaders = []
		if parentProps.events['ONRETRIEVE']
			postData = @generatePostDataForRetrieve()
		else
			postData = @generatePostData()
		contents = parentProps.allContents
		for sorter in sorters
			for content in contents
				if content.index + '' is sorter.property
					sortHeaders.push {name: content.name, sortBy: sorter.direction}
		postData.sortHeaders = sortHeaders
		@storeScrollbarPosition()
		@remoteLoadStoreData postData
		return

	storeScrollbarPosition: ->
		iv = Corefw.util.InternalVar
		view = @getView()
		if view.normalView
			uipath = view.normalView.up('coreobjectgrid').uipath
			iv.setByUipathProperty uipath, 'gridscroll_normal_left', view.normalView.el.getScroll().left
			iv.setByUipathProperty uipath, 'gridscroll_locked_left', view.lockedView.el.getScroll().left
		else
			uipath = view.up('coreobjectgrid').uipath
			iv.setByUipathProperty uipath, 'gridscroll_left', view.el.getScroll().left

	reStoreScrollbarPosition: ->
#		iv = Corefw.util.InternalVar
#		view = @getView()
#		@isStoreScrollbarPosition = false
#		if view.normalView
#			uipath = view.normalView.up('coreobjectgrid').uipath
#			normalLeftOffset = iv.getByUipathProperty uipath, 'gridscroll_normal_left'
#			view.normalView.el.scroll('l', normalLeftOffset, false)
#			normalTopOffset = iv.getByUipathProperty uipath, 'gridscroll_normal_top'
#			view.normalView.el.scroll('t', normalTopOffset, false)
#			iv.deleteUipathProperty uipath, 'gridscroll_normal_left'
#			iv.deleteUipathProperty uipath, 'gridscroll_normal_top'
#		else
#			uipath = view.up('coreobjectgrid').uipath
#			leftOffset = iv.getByUipathProperty uipath, 'gridscroll_left'
#			view.el.scroll('l', leftOffset, false)
#			iv.deleteUipathProperty uipath, 'gridscroll_left'
#
#			topOffset = iv.getByUipathProperty uipath, 'gridscroll_top'
#			view.el.scroll('t', topOffset, false)
#			iv.deleteUipathProperty uipath, 'gridscroll_top'
		return

	getColumnIndex: (colComp) ->
		if colComp.isGroupHeader
			colComp = colComp.down ':not([isGroupHeader])'
		columns = @getView().getGridColumns()
		businessColumns = []
		for column in columns
			if column.uipath
				businessColumns.push column
		return Ext.Array.indexOf businessColumns, colComp

	generatePagingPostData: ->
		
	generatePostData: ->
		props = @cache._myProperties
		selected = @selModel.selected
		postData =
			name: props.name
		me = this
		items = []
		postData.items = items
		postData.allContents = me.generateHeadersPostData me.cache
		cm = Corefw.util.Common
		ExtDate = Ext.Date
		delete me.editingCell
		forcedSelectRec = @forcedSelectedRecord

		fetchValue = (item) ->
			if Ext.isObject(item)
				return item.value
			return item

		modelToRowObj = (inputModel) ->
			brExists = /<br>/g
			cm = Corefw.util.Common

			retRowObj = {}
			values = {}
			retRowObj.value = values

			if forcedSelectRec
				if forcedSelectRec is inputModel
					retRowObj.selected = true
				else
					retRowObj.selected = false
			else
				if selected.contains mod
					retRowObj.selected = true
				else
					retRowObj.selected = false

			for field in storeFields
				if field.name in ['id', '_myProperties', '__tooltipValue']
					continue

				val = mod.get field.name
				if typeof val is 'string' and lineBreakExists
					val = val.replace brExists, '\n'

				if field.name is '__index'
					retRowObj.index = val
				else if val and /^(date|datetime|month_picker)$/.test field.columnType
					val = val.valueOf()
				else if field.columnType is 'datestring' and val
					val = ExtDate.format val, 'Y-m-d H:i:s'

				if val is null or val is undefined
					values[field.name] = ''
					continue
				if Ext.isArray(val)
					vals = []
					Ext.each(val, (item) ->
						vals.push fetchValue(item)
						return
					)
					values[field.name] = vals
				else
					values[field.name] = fetchValue(val)

			# see if the "index" property exists
			# 		if not, add it here
			if not retRowObj.index and retRowObj.index isnt 0
				retRowObj.index = inputModel.index
			return retRowObj

		st = @getStore()
		len = st.getCount()
		storeModel = st.getProxy().getModel()
		storeFields = storeModel.getFields()

		if len
			for i in [0... len]
				mod = st.getAt i
				lineBreakExists = mod?.data?._myProperties?.lineBreakExists
				rowObj = modelToRowObj mod
				rowObj.editing = if mod.isEditing then true else false
				rowObj.new = if mod.phantom then true else false
				rowObj.changed = if mod.dirty then true else false
				rowObj.removed = false
				delete rowObj.value.__index
				items.push rowObj

		removedRows = st.removed

		len = removedRows.length
		if len
			for i in [0... len]
				mod = removedRows[i]
				rowObj = modelToRowObj mod
				rowObj.new = false
				rowObj.changed = true
				rowObj.removed = true
				items.push rowObj

		return postData

	getCellInLockedView: (record, column) ->
		row = this?.view?.lockedView.getNode record, true
		if not row or not column
			return
		return Ext.fly(row).down(column.getCellSelector())

# To update a item that is being edited.
	updateItemDecorate: (record) ->
		view = @getView()
		props = record.raw._myProperties
		if props
			errorMsgs = props.messages?.ERROR
			tooltipData = props.tooltipValue
			cssClass = if props.cssClassList?.length then props.cssClassList else props.cssClass
			cellCssClassObj = props.cellCssClass
			row = view.getNode record, true
			rowEl = Ext.get row

			for col in @columns
				cell = rowEl.down col.getCellSelector()

				if cell
					if cell.hasCls('x-grid-cell-error')
						cell.removeCls('x-grid-cell-error')
					if cell.isTooltipCreated
						toolAr = Ext.ComponentQuery.query 'tooltip[targetId=' + cell.id + ']'
						for tooltip in toolAr
							tooltip.destroy()
						cell.isTooltipCreated = false

					if errorMsgs and errorMsgs[col.pathString]
						errMsg = errorMsgs[col.pathString]
						oneErrMsg = errMsg.join ';'

						cell.addCls('x-grid-cell-error')

						cell.isTooltipCreated = true
						Ext.create 'Ext.tip.ToolTip',
							target: cell.id
							targetId: cell.id
							html: oneErrMsg + '\n<br>'
							ui: 'form-invalid'
					else if tooltipData and tooltipData[col.pathString]
						cell.dom.tooltip = tooltipData[col.pathString].tooltip

				if cellCssClassObj and cellCssClassObj[col.pathString]
					if not cell and view.lockedView
						cell = @getCellInLockedView record, col
					cell.addCls cellCssClassObj[col.pathString] if cell

			if cssClass?
				node = view.getNode record, true
				nodeCmp = Ext.get node
				nodeCmp?.addCls cssClass

		else
			cellProps = record.raw.__misc._myProperties.cells
			if cellProps
				row = view.getNode record, true
				rowEl = Ext.get row
				for dataIndex, cellProp of cellProps
					if dataIndex is '_myProperties'
						continue
					col = @down('[dataIndex=' + dataIndex + ']')
					cell = rowEl.down col.getCellSelector()
					if cellProp and cell
						cssClass = if cellProp.cssClassList?.length then cellProp.cssClassList else cellProp.cssClass
						cell.addCls cellProp.cssClass if cssClass
		return


	styleDecorate: ->
		# refactor needed
		store = @getStore()
		if store.data
			items = store.data.items or []
			view = @getView()
			for item in items
				props = item.raw._myProperties
				if props
					errorMsgs = props.messages?.ERROR
					cssClass = if props.cssClassList?.length then props.cssClassList else props.cssClass

					for pathString, errMsg of errorMsgs
						oneErrMsg = errMsg.join ';'
						col = @down('[pathString=' + pathString + ']')
						record = view.getRecord item
						if not record
							continue
						cell = view.getCell record, col
						cell.addCls('x-grid-cell-error')
						cell.isTooltipCreated = true
						Ext.create 'Ext.tip.ToolTip',
							target: cell.id
							targetId: cell.id
							html: oneErrMsg + '\n<br>'
							ui: 'form-invalid'

					if cssClass?
						node = view.getNode item, true
						nodeCmp = Ext.get node
						nodeCmp?.addCls cssClass
					cellCssClassObj = props.cellCssClass
					if cellCssClassObj
						for pathString, cellCssClass of cellCssClassObj
							col = @down('[pathString=' + pathString + ']')
							cell = view.getCell item, col
							if not cell and view.lockedView
								cell = @getCellInLockedView item, col
							cell.addCls cellCssClass if cell

				else
					cellProps = item.raw.__misc._myProperties.cells
					if cellProps
						for dataIndex, cellProp of cellProps
							if dataIndex is '_myProperties'
								continue
							col = @down('[dataIndex=' + dataIndex + ']')
							cell = view.getCell item, col
							if cellProp
								cssClass = if cellProp.cssClassList?.length then cellProp.cssClassList else cellProp.cssClass
								cell.addCls cellProp.cssClass if cssClass and cell
		if not Ext.isEmpty @lockedGrid
			@syncRowHeights?()
		return