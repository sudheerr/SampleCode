Ext.define 'Corefw.controller.Grid',
	extend: 'Ext.app.Controller'

	init: ->
		@control
			'grid[coretype=field]':
				afterlayout: @afterGridLayout
			'gridview':
				viewready: @onGridViewReady
			'treeview':
				viewready: @onTreeViewReady
				resize: @onTreeViewResized
				afteritemexpand: @onTreeAfterItemExpand
				afteritemcollapse: @onTreeAfterItemCollapse
				beforecellclick: @onRadioBeforeCellClick
			'menuitem[menuoperation=addsort]':
				click: @onColumnMenuAddSortClick
			'coreobjectgrid>grid':
				select: @onGridItemSelect
				deselect: @onGridItemDeselect
				cellclick: @onGridCellClick
				columnresize: @onGridColumnResizeEvent
				beforeselect: @onGridRowBeforeSelectOrDeselect
				beforedeselect: @onGridRowBeforeSelectOrDeselect
				#selectall/deselectall are fired from corecheckboxmodel
				selectall: @processGridEvent
				deselectall: @processGridEvent
			'coreobjectgrid gridview':
				itemdblclick: @onItemDoubleClick
			'coregridintreenode':
				cellclick: @onTreeNodeCellClick
			'coretreegrid treepanel':
				beforeselect: @onGridRowBeforeSelectOrDeselect
				beforedeselect: @onGridRowBeforeSelectOrDeselect
				select: @onGridItemSelect
				deselect: @onGridItemDeselect
				cellclick: @onTreeGridCellClick
				itemdblclick: @onItemDoubleClick
				edit: @onTreeGridEdit
				afterlayout: @onTreeGridAfterlayout
				columnresize: @onTreeGridColumnResizeEvent
			'checkcolumn':
				beforecheckchange: @onEditableCheckbox
				checkchange: @onCheckColumnChange
			'checkbox[columnONCHANGEevent]':
				change: @onEditorCheckboxChange
			'checkbox[columnONCHECKCHANGEevent]':
				change: @onEditorCheckboxCheckChange
			'textfield[columnONCHANGEevent]':
				change: @onTextfieldChange
			'textfield[columnONBLURevent]':
				blur: @onTextfieldBlur
			'combobox[columnONLOOKUPevent]':
				focus: @onComboBoxFocusLookup
				change: @onComboBoxChangeLookup
				beforeselect: @toogleComboBoxChangeEvent
				select: @toogleComboBoxChangeEvent
			'combobox[columnONSELECTevent]':
				select: @onComboBoxSelect
			'corehierarchygridnode':
				itemclick: @onHierarchyGridNodeRowClick
			'roweditor combobox':
				focus: @initComboboxLookUpState
			'gridcolumn':
				hide: @onGridColumnHideOrShow
				show: @onGridColumnHideOrShow
		@initinalGridSelectedChangeTask()
		return

	onRadioBeforeCellClick:(view, td, cellIndex, record) ->
		if view.xtype is 'treeradioview'
			childLeaf = record.childNodes
			disabled = record.raw.disabled
			if childLeaf.length
				return 
			else
				parentNode = record.parentNode
				childNodes = parentNode.childNodes
				if disabled
					return		
				for childNode in childNodes
					data = childNode.data
					childNode.set('checked',false)
		return

	onGridRowBeforeSelectOrDeselect: (grid, record, index, eOpts) ->
		if record?.raw?._myProperties?.selectable is false
			return false
		return true
	
	onTreeAfterItemExpand: (treeitem) ->
		treeview = treeitem.getOwnerTree().view
		@onTreeViewResized treeview
		return

	
	onTreeAfterItemCollapse: (treeitem) ->
		treeview = treeitem.getOwnerTree().view
		@onTreeViewResized treeview
		return

	onTreeViewResized: (view) ->
		treebase = view.up "coretreebase"
		tree = view.up()
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2 and tree
			props = tree.cache?._myProperties
			columns = tree.columns
			tempwidth = tree.getWidth()
			if tempwidth > 0
				if props and props.titleBackgroundIsWhite and columns
					if columns.length is 1
						column = tree.columns[0]
						column.setWidth tempwidth 
		if not treebase
			return
		return

	onTreeViewReady: (view) ->
		isStackedLayout = view.up('form')?.layoutManager?.type is 'vbox'
		cm = Corefw.util.Common
		if isStackedLayout
			cm.setMaxAndMinHeight view.up 'fieldcontainer'
		return

	restoreScrollBar: (view)->
		iv = Corefw.util.InternalVar
		baseView = view.up("coregridbase").getView()
		uipath = view.up('coreobjectgrid')?.uipath
		#unsupport mix grid
		if uipath is undefined
			return
		if baseView.normalView
			normalLeftOffset = iv.getByUipathProperty uipath,'gridscroll_normal_left'			
			baseView.normalView.el.scroll('l', normalLeftOffset, false)			
			iv.deleteUipathProperty uipath,'gridscroll_normal_left'
		else
			leftOffset = iv.getByUipathProperty uipath,'gridscroll_left'
			baseView.el.scroll('l', leftOffset, false);
			iv.deleteUipathProperty uipath,'gridscroll_left'
		return
		
	onGridViewReady: (view) ->
		return if view.getWidth() > 3000
		@applyGridStyle view.up()
		if not view.up "coregridbase"
			return			
		if view.up "grid[isLocked=true]"
			return
		view.isReady = true
		# TODO, legacy code, test if we need isAdjusted flag
		if view.el and view.el.dom
			# temporary word around:
			# fix bugs: columns and view will mess after hiding some columns
			scrollLeft = view.el.dom.scrollLeft
			if scrollLeft > 0
				if scrollLeft > 10
					view.el.dom.scrollLeft = scrollLeft - 5
				else
					view.el.dom.scrollLeft = scrollLeft + 1
				# retore the scroll bar position
				view.el.dom.scrollLeft = scrollLeft
			@restoreScrollBar(view)
		return

	toogleComboBoxChangeEvent: (comp) ->
		comp.disableChangeEvent = not comp.disableChangeEvent 
		return

	onGridColumnResizeEvent: (comp, column, width, eOpts) ->
		if column.width
			column.cache?._myProperties?.width = width
		return

	onTreeGridColumnResizeEvent: (comp, column, width, eOpts) ->
		grid = comp.up()
		view = grid.view
		columns = grid.columns
		su = Corefw.util.Startup
		delayToolTips = su.getStartupObj().delayTooltips is true;
		nodes = view.getNodes()
		loopCells = @loopCells
		createTooltipOncell = @createTooltipOncell
		createToolTip = @createToolTip
		if delayToolTips
			addlConfig =
				hideDelay: 1200
				listeners: click:
					element: 'el'
					fn: (el, d) ->
						Ext.getCmp(@id).showAt @getXY()
						return
		Ext.each nodes, (row, rowIndex)->
			node = Ext.get(row)
			loopCells view, node, columns, (col, cell) ->
				cell.on mouseenter: ->
					createTooltipOncell col, cell, "celltooltip", createToolTip, addlConfig
					return
				return
			return
		return

	loopCells: (view, row, columns, processor) ->
		for column in columns
			continue if not view.getNode row,true
			cell = view.getCell row,column
			processor? column,cell if cell
		return

	createTooltipOncell : (column, cell, tooltipValueObj, createTooltipFn, addlConfig) ->
		tooltip = cell.dom.innerHTML
		rawTip = cell.dom.textContent
		newMetrics = new Ext.util.TextMetrics()
		cellValue = ((newMetrics.getSize(rawTip).width) + 2) or 0
		columnWidth = column.getEl().getWidth() 
		cell.isTooltipCreated = cell.isTooltipCreated or false
		if cell and cell.isTooltipCreated is false and not Ext.isEmpty(tooltip)
			if columnWidth  < cellValue
				createTooltipFn cell, rawTip, addlConfig
				cell.isTooltipCreated = true
		return

	createToolTip : (target, html, addlConfig) ->
		config =
			target: target
			html: html
		if addlConfig
			Ext.apply config, addlConfig
		Ext.create 'Ext.tip.ToolTip', config
		return

	gridSelectChangeTask:null

	initinalGridSelectedChangeTask: ->
		@gridSelectChangeTask = new Ext.util.DelayedTask @processGridSelectedChangeEvent , @
		return

	processGridSelectedChangeEvent:(grid, eventType, record)->
		@processGridEvent grid, eventType, record
		return

	onGridItemSelect: (model, record) ->
		gridview = model.view
		grid = gridview.up "coretreegrid, coreobjectgrid"
		if not grid or not grid.enableSelectEvent
			return
		@gridSelectChangeTask.delay 300, null, null, [grid,'ONSELECT',record]
		return

	onGridItemDeselect: (model, record) ->
		gridview = model.view
		grid = gridview.up "coretreegrid, coreobjectgrid"
		if not grid or not grid.enableSelectEvent
			return
		@gridSelectChangeTask.delay 300, null, null, [grid,'ONDESELECT',record]
		return

	onItemDoubleClick: (gridview, record) ->
		if record.raw?._myProperties?.selectable is false
			return
		grid = gridview.up "coretreegrid, coreobjectgrid"
		if not grid
			return
		gridProps = grid.cache._myProperties
		editableGrid = gridProps.editableColumns
		if editableGrid
			return
		@processGridEvent grid, 'ONDOUBLECLICK', record
		return

	processGridEvent: (gridfield, eventType, record) ->
		editorHost = gridfield.grid or gridfield.tree
		editorHost.ctrl = this
		gridEvent = gridfield.eventURLs?[eventType]
		if not gridEvent or editorHost.isEditing or document.body.querySelector '.x-grid-dd-wrap'
			return
		if editorHost.stopFireEvents
			editorHost.stopFireEvents = false
			return
		uipath = gridfield.uipath
		rq = Corefw.util.Request
		eventURL = rq.objsToUrl3 gridEvent
		uipath = gridfield.uipath
		record.isEditing = true
		gridfield.valueChanged = true
		postData = gridfield.generatePostData()
		rq.sendRequest5 eventURL, rq.processResponseObject, uipath, postData
		record.isEditing = false
		return

	initComboboxLookUpState: (combobox) ->
		combobox.isNotFirstLookUp = false
		return

	# below function looks deprecated, to be refactored and use @processGridEvent
	onHierarchyGridNodeRowClick: ( gridview, record, item, index, e, eOpts) ->
		rq = Corefw.util.Request
		hierarchyGridNode = gridview.up 'grid'
		hierarchyGridView = hierarchyGridNode.up '[coretype=field]'

		if not hierarchyGridView
			return
		props = hierarchyGridView.cache?._myProperties
		if not props
			return
		event = props.events['ONROWCLICK']
		eventURL = event.url
		if not eventURL
			return

		url = rq.objsToUrl3 eventURL
		uipath = hierarchyGridView.uipath
		postData = hierarchyGridView.generatePostData hierarchyGridNode.expandedRowIndex,record
		rq.sendRequest5 url, rq.processResponseObject, uipath, postData, undefined, undefined, undefined, e
		return

	# this replaces onGridLinkClick, and can be expanded to handle cell clicks
	#		on other column types
	onGridCellClick: ( gridview, td, cellIndex, record, tr, rowIndex, e, eOpts ) ->
		comp = gridview.up 'coreobjectgrid'
		@processCellClick gridview, cellIndex, record, e, comp
		return

	# doesn't work yet -- breadcrumb does not know which component to replace
	onTreeNodeCellClick: ( gridview, td, cellIndex, record, tr, rowIndex, e, eOpts ) ->
		comp = gridview.up 'grid'
		@processCellClick gridview, cellIndex, record, e, comp
		return


	# this replaces onGridLinkClick, and can be expanded to handle cell clicks
	#		on other column types
	onTreeGridCellClick: ( gridview, td, cellIndex, record, tr, rowIndex, e, eOpts ) ->
		console.log 'onTreeGridCellClick----------------------------------------------'
		milliDelay = 300 				# how many milliseconds to throttle repeated calls to this function
		currentTime = Date.now()
		comp = gridview.up 'coretreegrid'
		# total hack to prevent doubled events
		if @lastCellClickProcessTime
			if currentTime - @lastCellClickProcessTime < milliDelay
				comp.tree?.stopOpeningEditor = false
				return
		@lastCellClickProcessTime = currentTime
		@processCellClick gridview, cellIndex, record, e, comp
		return



	# disable processing if current column is disabled in item cache
	isStopProcessing: (gridview,columnProps,record) ->
		rowCache = null
		index = record.raw.__index
		if gridview.xtype is 'gridview'
			grid = gridview.up 'coreobjectgrid'
			gridProps = grid.cache._myProperties
			if grid.xtype is 'corercgrid'
				rowCache = gridProps.rows[index]
			else
				rowCache = gridProps.items[index]
		else
			grid = gridview.up 'coretreegrid'
			gridProps = grid.cache._myProperties
			grid.tree.traverseNodes gridProps.allTopLevelNodes, 'children', (n) -> rowCache = n if n.index is index
		return unless rowCache
		disabledHeaders = rowCache?.disabledHeaders or []
		enabledHeaders = rowCache?.enabledHeaders or []
		isStop = false
		if columnProps.enabled
			for pathString in disabledHeaders
				if columnProps.pathString is pathString
					isStop = true
					break
		else
			isStop = true
			for pathString in enabledHeaders
				if columnProps.pathString is pathString
					isStop = false
					break
		return isStop

	processCellClick: (gridview, cellIndex, record, e, comp) ->
		rq = Corefw.util.Request
		props = gridview.getGridColumns()[cellIndex]?.cache?._myProperties
		return if not props
		columnType = props.columnType?.toLowerCase()
		if (columnType is 'link' and e.target.tagName.toLowerCase() is 'a') or (columnType is 'icon' and e.target.tagName.toLowerCase() is 'div')
			eventURLs = props.eventURLs
			return if not eventURLs or @isStopProcessing gridview, props, record
			if eventURLs.ONCLICK
				eventURL = eventURLs.ONCLICK
				url = rq.objsToUrl3 eventURL
				# force the selection to this specific record
				# necessary because this grid CAN be multi select, which we want to suppress
				# we want the selection to be the cell that was clicked
				comp.forcedSelectedRecord = record
				postData = 	comp.generatePostData()
				delete comp.forcedSelectedRecord
				uipath = comp.uipath
				perspectiveWindowOfTriggerEvent = comp.up 'coreperspectivewindow'
				if e.ctrlKey
					rq.sendRequest5 url, undefined, uipath, postData, undefined, undefined, undefined, e
					return
				if perspectiveWindowOfTriggerEvent
					rq.sendRequest5 url, perspectiveWindowOfTriggerEvent.processResponseObject, uipath, postData, undefined, undefined, perspectiveWindowOfTriggerEvent, e
				else
					rq.sendRequest5 url, rq.processResponseObject, uipath, postData, undefined, undefined, undefined, e
			if eventURLs.ONDOWNLOAD
				uc = Corefw.util.Common
				eventURL = eventURLs.ONDOWNLOAD
				url = rq.objsToUrl3 eventURL
				comp.forcedSelectedRecord = record
				uc.download comp, url
				console.log 'Returned After download'
				delete comp.forcedSelectedRecord
			if eventURLs.ONREDIRECT
				uc = Corefw.util.Common
				eventURL = eventURLs.ONREDIRECT
				url = rq.objsToUrl3 eventURL
				comp.forcedSelectedRecord = record
				uc.redirect comp, url				
				console.log 'Returned After redirect'
				delete comp.forcedSelectedRecord	
		return

	onTreeGridEdit: (evt, cell) ->
		cell.grid.styleDecorate?()
		return

	onTreeGridAfterlayout: (tree) ->
		if tree and tree.styleDecorate
			tree.styleDecorate()
		else
			treeGrid = tree.up('panel')
			if treeGrid and treeGrid.styleDecorate
				treeGrid.styleDecorate()
		return

	afterGridLayout: (grid) ->
		if grid.features and grid.features.length
			feature = grid.features[0]
			if feature.ftype is 'coregroupingsummary'
				@applyGridStyle grid
		return

	applyGridStyle: (grid) ->
		# coregrid is either an objectgrid or treegrid
		coregrid = grid.up 'coretreegrid, coreobjectgrid'
		if not coregrid
			return
		uipath = coregrid.uipath

		if uipath
			myFunc = Ext.Function.createBuffered ->
				# grid will be replaced, so previous grid reference may be not the correct one on the page.
				# here hack to use uipath query to ensure working. later refactor
				coregrid = Ext.ComponentQuery.query('[uipath=' + uipath + ']')[0]
				if coregrid
					grid = coregrid.down()
					grid.styleDecorate?()
				return
			, 400
			myFunc()
		return

	onColumnMenuAddSortClick: (menuitem, event) ->
		gridcolumn = menuitem.up 'gridcolumn'
		grid = menuitem.up 'grid'
		store = grid.store

		newSorter = Ext.create 'Ext.util.Sorter',
			property: gridcolumn.dataIndex
			direction: 'ASC'
			root: 'data'

		store.sorters.add newSorter
		store.sort()
		return

	onTextfieldChange: (comp, newValue, oldValue) ->
		@fireGridEvent comp, 'ONCHANGE', true
		return

	onTextfieldBlur: (comp, evt) ->
		@fireGridEvent comp, 'ONBLUR', true, null, null, evt
		return

	onEditableCheckbox: (column, rowIdx, checked, eOpts) ->
		cache = column.cache
		if cache
			props = cache._myProperties
			if props
				if props.editable
					if el = column.ownerCt?.grid.view.getCell(rowIdx,column)?.el
						if el.hasCls 'x-item-disabled'
							return false
				else
					return false
		return true

	onCheckColumnChange: (comp, index) ->
		view = comp.up('panel').getView?()
		if view
			gridStore = view?.getStore()
			items = gridStore?.data?.items
			for item in items
				item.isEditing = false
			record = gridStore.getAt index
			record.isEditing = true
			@fireGridEvent comp, 'ONCHANGE', false, null, true
			@fireGridEvent comp, 'ONCHECKCHANGE', false, null, true
			record.isEditing = false
		return

	onEditorCheckboxChange: (comp) ->
		@fireGridEvent comp, 'ONCHANGE', true
		return

	onEditorCheckboxCheckChange: (comp) ->
		@fireGridEvent comp, 'ONCHECKCHANGE', true
		return

	onComboBoxSelect: (comp, records) ->
		@fireGridEvent comp, 'ONSELECT', true
		return

	onComboBoxChangeLookup: (comp, newValue, oldValue) ->
		if comp.disableChangeEvent
			return
		@onComboBoxLookup comp, false, newValue, oldValue
		return

	onComboBoxFocusLookup: (comp) ->
		@onComboBoxLookup comp, true
		return

	onComboBoxLookup: (comp, delay, newValue, oldValue) ->
		me = this
		# if it is a gridpicker editor, just return.
		# gridpicker editor lookup event is handled at RowEditorGridPicker.coffee
		if comp and comp.xtype is 'roweditorgridpicker'
			return
		comboLookupService = () ->
			gridComboCallback = (respObj=[],ev, uipath) ->
				name = uipath + '_' +comp.name
				st = Corefw.util.Data.arrayToStore name, 'gridComboCallback' + comp.id, respObj, comp
				if st
					comp.bindStore st
				if delay
					Ext.Function.createDelayed(comboExpand, 200)()
				else
					comboExpand()
				return

			comboExpand = () ->
				comp.expand()
				store = comp.getStore()
				node = if store then comp.findRecordByValue comp.getValue() else null
				if node
					comp.picker?.focusNode node
				return
			
			me.fireGridEvent comp, 'ONLOOKUP', true, gridComboCallback

			return

		if delay
			delayLookup = Ext.Function.createDelayed comboLookupService, 1
			delayLookup()
		else
			comboLookupService()

		return

	onGridColumnHideOrShow: (column) ->
		grid = column.up('coregridbase') or column.up('coretreebase')
		return if grid.suspendHidingEvent
		fieldContainer = grid.ownerCt
		# handle group column
		if column.isGroupHeader
			column.items.items.forEach (c) -> c.cache._myProperties.visible = c.isVisible()
		else
			column.cache._myProperties.visible = column.isVisible()
		# sync the cache for grid and field container to avoid some data issues
		fieldContainer.cache = grid.cache
		events = fieldContainer.cache?._myProperties?.events or {}
		eventURL = events['ONCOLUMNSTATECHANGE']
		if eventURL
			postData = fieldContainer.generatePostData()
			grid.remoteLoadStoreData? postData,
				event: 'ONCOLUMNSTATECHANGE'
			if grid.xtype is 'coretreebase'
				Ext.ComponentQuery.query('menu[activeHeader]').forEach (m) -> m.destroy()
		return

	fireGridEvent: (comp, evtType, forcedUpdateRec, callback, isNotEditor, evt) ->
		return if comp.up?('roweditor')? and (callback is null or typeof(callback) is 'undefined')
		cm = Corefw.util.Common
		rq = Corefw.util.Request
		iv = Corefw.util.InternalVar
		parent = comp.up('grid') or comp.up('treepanel')
		if evt
			tar = evt.relatedTarget or evt.target or evt.currentTarget
			if tar and tar.id
				fieldId = Ext.get(tar.id).up('.x-field')?.id
				if fieldId
					field = Ext.getCmp fieldId
					colIndex = field?.column.getIndex()

		source = if isNotEditor then comp else comp.column
		sourceProps = source.cache?._myProperties
		eventURL = sourceProps?.eventURLs?[evtType]
		if not eventURL
		    return

		if not isNotEditor
			uipath = parent.cache._myProperties.uipath + '/' + sourceProps.name
			val = comp.getValue()
			if comp.xtype is 'datefield' and val
				val = val.valueOf()
			parent['editingCell'] =
				uipath: uipath
				val: val
				disp: comp.getRawValue()

		parentField = parent.up 'fieldcontainer'
		uipath = parentField.uipath
		if evtType == 'ONLOOKUP'
			return if Corefw.util.InternalVar.getByNameProperty 'roweditor','suspendChangeEvents'
			postData = null
			if not comp.isNotFirstLookUp
				comp.isNotFirstLookUp = true
				lookUpString = "";
			else
				lookUpString =  comp.getRawValue()
			url = rq.objsToUrl3(eventURL,null,lookUpString)
		else
			postData = parentField.generatePostData()
			url = rq.objsToUrl3 eventURL

		errMsg = 'Did not receive a valid response for the combobox'
		method = 'POST'
		callbackMethod = if callback then callback else rq.processResponseObject
		rq.sendRequest5 url, callbackMethod, uipath, postData, errMsg, method
		return