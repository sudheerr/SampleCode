# contains functions common to Grids
# this file is needed because a grid and tree grid need to support similar functions,
#		but they derive from different base classes

Ext.define 'Corefw.mixin.Grid',
	defaultRowHeight: 22

	constructor: ->
		return

	configureBufferedRenderPlugin: ->
		bpConfig =
			pluginId: 'corebufferedplugin'
			trailingBufferZone: 10
			leadingBufferZone: 20
		bp = Ext.create 'Corefw.view.grid.BufferedRenderer', bpConfig
		if @plugins
			@plugins.push bp
		else
			@plugins = [
				bp
			]
		return

	configureBufferedSelPlugin: ->
		bsConfig =
			pluginId: 'corebufferedselplugin'
		bs = Ext.create 'Corefw.view.grid.plugin.BufferedSelect', bsConfig
		if @plugins
			@plugins.push bs
		else
			@plugins = [
				bs
			]
		return

	configureEditPlugin: ->
		rowEditingConfig =
			clicksToEdit: 2
		rowedit = Ext.create 'Corefw.view.grid.RowEditing', rowEditingConfig
		@rowEditor = rowedit
		if @plugins
			@plugins.push rowedit
		else
			@plugins = [
				rowedit
			]
		return

	configureDragAndDropPlugins: (props, isGrid) ->
		rq = Corefw.util.Request
		generateDragDropPostData = @generateDragDropPostData
		ptype = if isGrid then 'coregridviewdragdrop' else 'coretreeviewdragdrop'
		isDraggable = props.draggable or false
		recievablePaths = props.recievablePaths or []
		isDroppable = recievablePaths.length > 0
		dropToUipath = props.uipath
		plugins = @viewConfig?.plugins
		return if not isDraggable and not isDroppable
		pluginConfig =
			ptype: ptype
			enableDrag: isDraggable

		listeners =
			beforeDrop: (node, data) ->
				dragFromView = data.view
				if dragFromView is this
					data.copy = false
				else
					data.copy = true
				return true
			drop: (node, data) ->
				dragFromView = data.view
				container = @up 'fieldcontainer'
				if dragFromView is this
					url = container.eventURLs['ONROWSTATECHANGE']
					return unless url
					postData = container.generatePostData()
					if isGrid
						postData.items.forEach (item, index) ->
							item.index = index
							item.changed = true
					url = rq.objsToUrl3 url
					rq.sendRequest5 url, rq.processResponseObject, dropToUipath, postData, 'The drag and drop request is failed', 'POST'
					return

				droppedTarget = container.grid or container.tree
				droppedTarget.getStore().remove data.records

				dragFromView.getSelectionModel().select +data.item.dataset.recordindex
				dragFromUipath = dragFromView.up('fieldcontainer')?.cache._myProperties.uipath
				return if not dragFromUipath

				postData = generateDragDropPostData dragFromView, this, dragFromUipath
				url = dropToUipath + '/ONDND/' + dragFromUipath
				url = rq.objsToUrl3 url
				rq.sendRequest5 url, rq.processResponseObject, dropToUipath, postData, 'The drag and drop request is failed', 'POST'
				return
		viewConfig =
			_uipath: props.uipath
			copy: true
			plugins: [
				pluginConfig
			]
			listeners: listeners
		if plugins
			plugins.push pluginConfig
			Ext.merge @viewConfig.listeners, listeners
		else
			@viewConfig = viewConfig
		return

	generateDragDropPostData: (dragFromComp, dropToComp, dragFromUipath) ->
		dragFromPostData = dragFromComp.up('fieldcontainer').generatePostData()
		dropToPostData = dropToComp.up('fieldcontainer').generatePostData()
		dropToPostData.from = dragFromPostData
		dropToPostData.from.uipath = dragFromUipath
		return dropToPostData

	configurePlugins: (props, isGrid) ->
		props.infinity and @configureBufferedRenderPlugin()
		props.buffered and @configureBufferedSelPlugin()
		props.editableColumns and @configureEditPlugin()
		@configureDragAndDropPlugins props, isGrid
		return

	defaultDef:
		lockable: false

# in the cache, each column is a key, except for _myProperties
	createColumnsFromCache: (itemsArray) ->
		cache = @cache
		grid = this
		props = cache._myProperties
		itemNew = []
		if itemsArray.length
			columnsAlreadyExist = true

		# see if we've requested an autoNumber column
		# if yes, make it the first column
		# not supported for tree grids
		if props?.supportAutoNumber and not columnsAlreadyExist
			itemsArray.push
				xtype: 'rownumberer'
				resizable: true
				width: 60

		index = 0
		@columnGroups = {}
		for key, colCache of cache
			colProps = colCache._myProperties
			# notick: this if statement is different with any where, no 'visible' here
			if key isnt '_myProperties' and not colProps?.isRemovedFromUI
				if columnsAlreadyExist
					newColumnObj = @configureOneColumn colCache, cache, index, itemsArray[index]

					if colCache._myProperties.group and colCache._myProperties.group.groupName
						@addToColumnGroup colCache._myProperties, newColumnObj, itemNew
					else
						itemNew.push newColumnObj
				else
					newColumnObj = @configureOneColumn colCache, cache, index
					@addColumn colCache, newColumnObj, itemsArray
				#	fixed ExtJs bug: getEditor function could not be set to hidden column
				if newColumnObj.hidden
					newColumnObj.getEditor = (c, h) ->
						grid.rowEditor.getColumnField this, h

				index++

		delete @columnGroups
		if itemNew.length
			@columns = itemNew
			@setGroupLocked itemNew
		else
			@setGroupLocked itemsArray
		@hideGroupColumn if itemNew.length > 0 then itemNew else itemsArray
		return
#	hide group column if its subcolumns are all hidden
	hideGroupColumn: (columns) ->
		for column in columns
			subColumns = column.columns
			if subColumns
				i = 0
				for subColumn in subColumns
					i++ if subColumn.hidden
				if i is subColumns.length
					column.hidden = true
		return

	addToColumnGroup: (props, newColumnObj, itemsArray) ->
		group = props.group
		groupName = group.groupName
		groupKey = groupName + (group.groupID or '')
		groupColumnArray = @columnGroups[groupKey]
		gridmenu = @cache._myProperties
		if not groupColumnArray
			# create this group
			groupColumnArray = []
			@columnGroups[groupKey] = groupColumnArray

			groupHeaderObj =
				text: groupName
				columns: groupColumnArray

			if gridmenu.hideGridHeaderMenus
				groupHeaderObj.menuDisabled = true

			itemsArray.push groupHeaderObj

		Ext.apply newColumnObj, @defaultDef
		groupColumnArray.push newColumnObj
		return


# colIndex: which 0-based index is this column in the grid
#		used to determine whether to lock the column according to the property
#		numberOfLockedHeaders
	configureOneColumn: (colCache, gridCache, colIndex, existingColumnObj) ->
		grid = this
		evt = Corefw.util.Event
		cm = Corefw.util.Common
		su = Corefw.util.Startup
		props = colCache._myProperties
		gridProps = gridCache._myProperties

		colType = if props.columnType then props.columnType else props.type
		columnType = colType?.toLowerCase()
		if not props.columnType and columnType
			props.columnType = columnType

		# create a new column if it doesn't already exist
		if existingColumnObj
			newColumnObj = existingColumnObj
			newColumnObj.cache = colCache
		else
			newColumnObj =
				cache: colCache

		newColumnObj.toggleSortState = ->
			column = this
			grid.toggleColumnSortState column

		minWidth = props.minWidth or 30
		maxWidth = props.maxWidth or 200
		protocolMap =
			TELEPHONE: 'tel:'
			MAIL: 'mailto:'
		if props.width
			definedWidth = props.width
			if definedWidth < minWidth
				minWidth = definedWidth
			if definedWidth > maxWidth
				maxWidth = definedWidth + 100

		config =
			text: props.title
			tooltip: props.toolTip or props.title
			dataIndex: props.index + ''
			pathString: props.pathString,
			name: props.name
			minWidth: minWidth
			maxWidth: maxWidth
#			hidden: not props.visible # don't merge to ExtJs 5
			uipath: props.uipath
			allowAutoWidth: gridProps.allowAutoWidth
			lockable: props.lockable
			draggable: props.draggable

		textAlign = props.textAlign
		if textAlign
			config.align = textAlign.toLowerCase()

		if gridProps.hideGridHeaderMenus
			config.menuDisabled = true

		if gridProps.widgetType isnt 'TREE_GRID'
			config.listeners =
				headertriggerclick: @onShowColumnMenu
		if gridProps.headerEllipses
			config.cls = 'grid-header-ellipses-cls'
		else
			# Truncating the required header lines. Adding cls to the header (Hack) because Sencha config not available to fix the issue.
			headerLines = gridProps.headerTitleRows
			if headerLines > 1
				# the cls just for headerLines = 2
				config.cls = 'headerTitleEllipse'
			else if gridProps.widgetType is 'TREE_GRID'
				config.cls = 'headerTitleEllipse'
			else
				config.cls = 'grid-header-no-ellipses-cls'

		if props.columnType
			props.corecolumntype = columnType

		if props.toolTip
			config.tooltip = (props.toolTip + '\n<br>').replace /"/g, '&quot;'
			tip = Ext.getCmp 'ext-quicktips-tip'
			tip?.dismissDelay = 0

		if props.locked
			config.locked = true

		if gridProps.numberOfLockedHeaders and colIndex < gridProps.numberOfLockedHeaders
			config.locked = true
		else
			config.locked = false

		if definedWidth
			config.width = definedWidth
		else
			if not config.locked
				config.flex = 1
				if not props.maxWidth
					delete config.maxWidth
		if props.flexWidth
			config.flex = props.flexWidth
			delete config.maxWidth
		if props.hideable is false
			config.hideable = false
		else
			config.hideable = true


		# configure sortable property
		config.sortable = props.supportSort
		if props.sortState is 'ASC'
			config.possibleSortStates = ['DESC', 'ASC']

		config.iconMap = props.iconMap
		config.linkMap = props.linkMap

		Ext.apply newColumnObj, config


		if props.editable
			@configureOneEditableColumn colCache, newColumnObj, gridCache, this

		# configure non-editable properties of the column
		typeToXtypes =
			textfield:
				tdCls: 'x-align-left'
				renderer: (value) ->
					if Ext.isObject value
						if value.displayValue
							value = value.displayValue
						else
							value = ''
					return value

			checkbox:
				xtype: 'corecheckcolumn'

			grid_picker:
				xtype: 'corecombocolumn'

			datestring:
				xtype: 'datecolumn'
				format: props.format or 'Y-m-d H:i:s'
				renderer: (value, meta) -># fixed for #7948
					dateFormat = 'Y-m-d H:i:s'
					valueFormat = props.format or 'Y-m-d H:i:s'
					if not Ext.isDate value
						try
							value = Ext.Date.parse value, dateFormat
						catch
							return value
					Ext.util.Format.date value, valueFormat

			combobox:
				xtype: 'corecombocolumn'
				validValues: props.validValues
				filterOptions: props.filterOptions

			number:
				xtype: 'numbercolumn'
				tdCls: 'x-align-right'
				renderer: (value) ->
					denominationRegExp = /[0,\.#]+(K|MM|BN)?$/
					denomination = ''
					format = props.format
					isPercent = (format.substr(format.length - 1) is '%')
					if Ext.isNumber(value) and isPercent
						value = value * 100
					if denominationRegExp.test format
						d2d =
							K: 1000
							MM: 1000000
							BN: 1000000000
						denomination = RegExp.$1
						divisor = d2d[denomination]
						if Ext.isNumber(value) and divisor
							value = value / divisor
					if Ext.isNumber value
						if value < 0
							rawValue = -value
							if not Ext.isEmpty format
								return '(' + (Ext.util.Format.number rawValue, format) + ')'
							else
								return '(' + rawValue + ')'
						else
							if not Ext.isEmpty format
								return Ext.util.Format.number value, format
							else
								return value
					else
						return value

			date:
				xtype: 'datecolumn'
				format: props.format or 'd M Y'

			datetime:
				xtype: 'datecolumn'
				format: props.format or 'd M Y, g:i a T'

			month_picker:
				xtype: 'datecolumn'
				format: props.format or 'Y-m'

			icon:
				renderer: (value = '', metaData, record, rowIndex, colIndex, store) ->
					column = metaData.column
					recordIndex = metaData.recordIndex
					if @viewType is 'coretreebaseview'
						recordIndex = store.treeStore.tree.flatten().indexOf(record) - 1
					if props.events['ONCLICK']
						metaData.style = metaData.style + ';cursor:pointer'
					if column and column.iconMap
						iconStr = column.iconMap[recordIndex]
						if su.getThemeVersion() is 2 and iconStr
							metaData.tdCls = 'iconInGrid'
							iconList = iconStr.split(' ')
							value = ''
							for iconStr in iconList
								value = value + "<div class='icon icon-" + Corefw.util.Cache.cssclassToIcon[iconStr] + "'></div>"
							return value
						else
							metaData.tdCls = iconStr
					if typeof value is 'string'
						value.split '<br>'
						.join ' '
					else
						value

			link:
				renderer: (value, metaData) ->
					format = props.format
					pseudoProtocol = props.pseudoProtocol
					if not Ext.isEmpty format
						cm = Corefw.util.Common
						value = cm.formatValueBySpecial value, format
					if Ext.isObject value
						if value.displayValue
							value = value.displayValue
						else
							value = ''
					column = metaData.column
					if column
						linkMap = column.linkMap
						recordIndex = metaData.recordIndex
						if linkMap and linkMap[recordIndex]
							return value

					# set link element by protocol type
					pt = protocolMap[pseudoProtocol]
					emptyText = if Ext.Object.isEmpty(value) then '&nbsp;' else ''
					if pt then emptyText + "<a href='#{pt}#{value}'>#{value}</a>" else emptyText + "<a href='javascript:;'>#{value}</a>"

			radio:
				renderer: (value, metaData, record, rowIndex, colIndex, store) ->
					return "<input type='radio' #{if value then "checked=checked" else ""} name=#{store.storeId}/>"

			togglebutton:
				renderer: (value, metaData, record, rowIndex, colIndex, store) ->
					return if value then 'Yes' else 'No'

		if gridProps.widgetType is 'RC_GRID'
			typeToXtypes.textfield.renderer = (value, metaData, record, rowIndex, colIndex, store) ->
				value.displayValue or (record.raw?.__misc[metaData?.column.dataIndex or '']?.displayValue) or value

		colXtype = typeToXtypes[columnType]
		if colXtype
			Ext.apply newColumnObj, colXtype
		# enable function for checking all column cells
		if colXtype and colXtype.xtype is 'corecheckcolumn'
			@addCls 'hasCheckColumn'
			if props.supportWholeCheck is true
				newColumnObj.enableAllSelecting = true
			else
				newColumnObj.enableAllSelecting = false

		evt.addEvents props, 'column', props

		return newColumnObj

	# TODO:Remove this method , once find the interceptor override column's toggleSortState
	toggleColumnSortState: (column) ->
		if column.sortable
			idx = Ext.Array.indexOf column.possibleSortStates, column.cache._myProperties.sortState
			nextIdx = (idx + 1) % column.possibleSortStates.length
			column.setSortState(column.possibleSortStates[nextIdx])

	configureOneEditableColumn: (colCache, newColumnObj, gridCache, gridComp) ->
		dt = Corefw.util.Data
		su = Corefw.util.Startup
		evt = Corefw.util.Event

		props = colCache._myProperties
		gridProps = gridCache._myProperties
		columnType = (props.columnType or props.type)?.toLowerCase()

		if not columnType
			console.log 'columnType not found, returning...'
			return

		# map types to xtypes
		typeToEditorXtypes =
			'default': 'coretextfield'
			textfield: 'coretextfield'
			date: 'coredatefield'
			datetime: 'datefield'
			header: 'textfield'
			combobox: 'combobox'
			grid_picker: 'roweditorgridpicker'
			multicombobox: 'combobox'
			checkbox: 'checkbox'
			textarea: 'coretextarea'
			radiogroup: 'radiogroup'
			number: 'corenumberfield'
			icon: 'textfield'
			link: 'textfield'
			datestring: 'coredatestringfield'
			month_picker: 'coremonthpicker'
			togglebutton: 'coretoggleslidefield'

		# temporary override for demos
		if su.useClassicTheme()
			typeToEditorXtypes.radiogroup = 'combobox'

		colEditorXType = typeToEditorXtypes[columnType]

		if not colEditorXType
			console.log 'editable columnType not found: ', columnType
			return
		newColumnObj.editor =
			xtype: colEditorXType

		valdtnArray = props.validations
		if valdtnArray
			for valdtn in valdtnArray
				switch valdtn.constraintName
					when 'FieldRegex'
						newColumnObj.editor.validator = (val) ->
							reg = eval('/' + valdtn.constraintMap.pattern + '/')
							if reg.test(val)
								return true
							return valdtn.constraintMessage
					when 'FieldNotNull'
						newColumnObj.editor.emptyText = 'required'

		comboClass = Corefw.view.form.field.ComboboxField
		switch colEditorXType
			when 'datefield'
				newColumnObj.editor.format = props.format or 'd M Y, g:i a T'
			when 'coredatefield', 'dateStringField'
				if format = props.format
					editor = newColumnObj.editor
					editor.format = format
			when 'roweditorgridpicker'
				newColumnObj.editor =
					xtype: 'roweditorgridpicker'
					cache: colCache
					valueMap: {}
					multiSelect: props.multiSelect
					lookupable: comboClass.isLookupable props
				if su.getThemeVersion() is 2
					newColumnObj.editor.triggerBaseCls = 'formtriggericon'
					newColumnObj.editor.triggerCls = 'editorcombotrig'
					newColumnObj.editor.height = 20
					if props.readOnly isnt true
						newColumnObj.editor.fieldStyle =
							'border-right-width': '0px'
			when 'combobox'
				colName = gridComp.cache._myProperties.uipath
				storename = "gridbaseregcombo#{colName}#{props.uipath}"
				st = dt.arrayToStore colName, storename, props.validValues, newColumnObj
				lookupable = comboClass.isLookupable props
				newColumnObj.editor =
					xtype: 'comboboxfield'
					store: st
					displayField: 'dispField'
					valueField: 'val'
					queryMode: 'local'
					multiSelect: props.multiSelect
					editable: comboClass.isEditable props
					lookupable: lookupable

				if lookupable
					lookupCls = 'citiriskLookup'
					Ext.apply newColumnObj.editor,
						hideTrigger: true
						cls: if newColumnObj.editor.cls then (newColumnObj.editor.cls + ' ' + lookupCls) else lookupCls
						historyInfo: props.historyInfo
					if su.getThemeVersion() is 2
						newColumnObj.editor.height = 20
						newColumnObj.editor.fieldStyle =
							'line-height': '12px'
				else
					if su.getThemeVersion() is 2
						newColumnObj.editor.triggerBaseCls = 'formtriggericon'
						newColumnObj.editor.triggerCls = 'editorcombotrig'
						newColumnObj.editor.height = 20
						if props.readOnly isnt true
							newColumnObj.editor.fieldStyle =
								'border-right-width': '0px'
				newColumnObj.editor.typeAhead = newColumnObj.editor.editable
			when 'textareafield'
				newEditorHeight = props.rows * 17
				newColumnObj.editor.height = newEditorHeight

				maxEditorHeight = gridCache._myProperties.maxEditorHeight
				if not maxEditorHeight or newEditorHeight > maxEditorHeight
					gridProps.maxEditorHeight = newEditorHeight

			when 'radiogroup'
				identify = props.path
				newColumnObj.editor =
					id: "#{identify}radiogroup"
					xtype: 'radiogroup'
					items: []

				for key, val of props.validValues
					newColumnObj.editor.items.push
						boxLabel: val
						name: identify
						inputValue: val

			when 'corenumberfield'
				editor = newColumnObj.editor
				if format = props.format
					format = format.replace /(K|MM|BN)?$/, ''
					editor.format = format
				if props.fieldMask
					editor.inputMask = props.fieldMask
					editor.enableKeyEvents = true
				spinnerSpec = props.spinnerSpec
				if spinnerSpec
					editor.step = spinnerSpec.numberStep
					editor.maxValue = spinnerSpec.upperBound
					editor.minValue = spinnerSpec.lowerBound
				if su.getThemeVersion() is 2 and props.readOnly isnt true
					newColumnObj.editor.fieldStyle =
						'border-right-width': '0px'

			when 'coretoggleslidefield'
				newColumnObj.editor.onText = 'Yes'
				newColumnObj.editor.offText = 'No'

		if newColumnObj.editor
			Ext.apply newColumnObj.editor,
				setActiveWarning: (message) ->
					me = this
					if not me.warningMessage and me.inputEl
						me.warningMessage = Ext.create 'Corefw.view.form.field.GridItemWarningMessage',
							field: me
					me.warningMessage.showMessage message
					return
				clearMessages: ->
					me = this
					warningMessage = me.warningMessage
					if not warningMessage
						return
					warningMessage.clearMessage()
					return
			if not props.enabled
				newColumnObj.editor.disabled = true
		newColumnObj.editor.pathString = props.pathString
		if su.getThemeVersion() is 2
			newColumnObj.editor.overCls = 'fieldOverCls'
		evt.addEvents props, 'column', newColumnObj.editor
		return

# go through all columns, checking to see if any grouped columns need to be locked
# if any column in a group of columns is locked, then that entire group is locked
	setGroupLocked: (colItemsArray) ->
		for col in colItemsArray
			if col.columns
				# this is a group of columns
				for subcol in col.columns
					if subcol.locked
						col.locked = true
		return

	addColumn: (colCache, newColumnObj, colItemsArray) ->
		props = colCache._myProperties

		if newColumnObj.hidden #mark the hidden column
			newColumnObj.visible = false

		# header grouping
		if props.group and props.group.groupName
			@addCls 'hasGroupHeaders'
			@addToColumnGroup props, newColumnObj, colItemsArray
		else
			colItemsArray.push newColumnObj

		# configure type of filter for column
		if @configureFilters
			@configureFilters colCache, newColumnObj
		return

	configSelType: ->
		cache = @cache
		props = cache._myProperties
		selectType = props.selectType?.toLowerCase()
		checkOnly = props.checkOnly
		buffered = props.buffered
		switch selectType
			when 'multiple'
			# There is some code which has dependency for selType,
			# so leaving selType code as it is.
				@selType = 'corecheckboxmodel'
				if checkOnly
					@selModel =
						selType: 'corecheckboxmodel'
						checkOnly: true
				if buffered
					@selModel ?=
						selType: 'corecheckboxmodel'
					@selModel.buffered = true

			when 'single'
				@selType = 'radiomodel'
			else
				@selModel =
					mode: 'MULTI'
		return

	reconfigMenuItems: (menu) ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			menu.showSeparator = false
			menuColumnArray = menu.items.items
			for menuColumn in menuColumnArray
				if menuColumn.menu
					menuColumn.menu.showSeparator = false


		activeHeader = menu.activeHeader
		props = activeHeader?.cache?._myProperties or {}
		if props.showColumnsMenu is false
			menuItem = menu.down '[text=' + activeHeader.columnsText + ']'
			menu.remove menuItem

		customDropdownMenuItems = @getCustomDropdownMenuItems menu
		@clearCustomDropdownMenuItems menu, customDropdownMenuItems

		dropdownMenuCache = activeHeader?.cache?._myProperties?.dropdownMenu or {}
		if dropdownMenuCache
			menu.uipath = dropdownMenuCache.uipath
			@addCustomDropdownMenuItemForActiveHeader menu, dropdownMenuCache

		return

	getCustomDropdownMenuItems: (menu) ->
		customDropdownMenuItems = []
		menuitemArray = menu.items.items

		for item in menuitemArray
			if item.custom
				customDropdownMenuItems.push item
		return customDropdownMenuItems

	clearCustomDropdownMenuItems: (menu, customDropdownMenuItems) ->
		for menuItem in customDropdownMenuItems
			menu.remove menuItem
		return

	addCustomDropdownMenuItemForActiveHeader: (menu, dropdownMenuCache) ->
		# add all the allContents and allNavigations items together
		menuArray = []
		if dropdownMenuCache.allContents
			for menuitem in dropdownMenuCache.allContents
				menuArray.push menuitem
		if dropdownMenuCache.allNavigations
			for menuitem in dropdownMenuCache.allNavigations
				menuArray.push menuitem

		items = []
		if menuArray and menuArray.length
			@createMenuItemsWorker menuArray, items

		menu.add items
		return

	createMenuItemsWorker: (menuArray, menuParent) ->
		rdr = Corefw.util.Render
		evt = Corefw.util.Event

		for menuItemCache in menuArray
			menuitem = {}
			props = menuItemCache._myProperties
			if not props
				props = menuItemCache

			menuitem.text = props.title
			menuitem.name = props.name
			menuitem.tooltip = props.toolTip
			menuitem.hidden = not props.visible
			menuitem.disabled = not props.enabled
			menuitem.cache = menuItemCache
			menuitem.coretype = 'gridheaderdropdownmenubutton'
			menuitem.grid = this
			menuitem.custom = true

			evt.addEvents props, 'menu', menuitem

			# add all the allContents and allNavigations items together
			nextMenuArray = []
			if menuItemCache.allContents
				for nextmenuitem in menuItemCache.allContents
					nextMenuArray.push nextmenuitem
			if menuItemCache.allNavigations
				for nextmenuitem in menuItemCache.allNavigations
					nextMenuArray.push nextmenuitem

			if nextMenuArray and nextMenuArray.length
				newAr = []
				menuitem.menu = newAr
				menuParent.push menuitem
				@createMenuItemsWorker nextMenuArray, newAr
			else
				menuParent.push menuitem
		return

# disable sort menu item if column is not sortable
	onShowColumnMenu: (headerCt, column, e) ->
		props = column.cache._myProperties
		menu = headerCt.getMenu()
		menuitemArray = menu.items.items

		# disable sort menu item if column is not sortable
		for menuitem in menuitemArray
			if menuitem.menuoperation is 'addsort'
				if props.supportSort
					menuitem.show()
				else
					menuitem.hide()
		return

	setHeaderActive: (activeHeader) ->
		for header in @columns
			header.active = false
		activeHeader.active = true
		return

	addListeners: ->
		listeners =
			beforeitemdblclick: @onBeforeitemdblclickEvent
			beforecelldblclick: @onBeforecelldblclickEvent
			columnmove: @onGridColumnMove
			viewready: @onGridViewReady
			boxready: @onGridBoxready # don't merge to ExtJs 5

		@listeners = @listeners or {}
		Ext.merge @listeners, listeners

		viewConfig =
			listeners:
				refresh: @onGridViewRefresh
				resize: @onGridViewResize

		if @viewConfig
			Ext.merge @viewConfig, viewConfig
		else
			@viewConfig = viewConfig

	onBeforeSelectEvent: ->
		@selectHandlerForRowEditor()

	onBeforeDeselectEvent: ->
		@selectHandlerForRowEditor()

	onBeforeitemclickEvent: ->
		@disableFireEventForRowEditor()

	onBeforeitemdblclickEvent: ->
		@disableFireEventForRowEditor()

	onBeforecellclickEvent: ->
		@disableFireEventForRowEditor()

	onBeforecelldblclickEvent: ->
		@disableFireEventForRowEditor()

	onGridColumnMove: (ct, column, fromIdx, toIdx) ->
		fieldContainer = ct.up 'fieldcontainer'
		grid = fieldContainer.grid or fieldContainer.tree
		grid.updateLayout() # fixing bugs: the header's right edge will disappear after removing.
		grid.updateIndexesAfterColumnMove column, fromIdx, toIdx
		events = fieldContainer.cache?._myProperties?.events or {}
		# TODO: COLUMNMOVE will be removed in some day
		gridEvent = events['COLUMNMOVE'] or events['ONCOLUMNSTATECHANGE']
		if gridEvent and gridEvent.type
			postData = fieldContainer.generatePostData()
			grid.remoteLoadStoreData? postData,
				event: gridEvent.type
		return

	updateIndexesAfterColumnMove: (column, fromIndex, toIndex) ->
		me = this
		columns = me.columns
		if me.xtype is 'coretreegrid'
			me = me.tree
			columns = me.columns
		return if not columns

		updateIndex = (col, newIndex) ->
			col.origIndex = '' + col.cache._myProperties.index
			col.cache._myProperties.index = newIndex
			col.dataIndex = '' + newIndex

		updateSubColumnIndexes = (groupHeader, movedColumns, index) ->
			subColumns = groupHeader.items.items
			for col in subColumns
				updateIndex col, index
				index++
			return index

		rebuildRecordDataExtractor = (newColumns) ->
			store = me.getStore()
			fields = store.model.prototype.fields
			items = fields.items
			map = fields.map
			for col in newColumns
				field = map[col.origIndex]
				field.name = col.dataIndex
				field.originalIndex = +col.dataIndex
			for field in items
				map[field.name] = field
			store.proxy.reader.convertRecordData = store.proxy.reader.buildRecordDataExtractor()
			return

		movedColumnName = column.name
		firstColumn = if columns[0].cache then columns[0] else columns[1]
		startIndex = +firstColumn.cache._myProperties.index
		prevColumn = me.columnManager.getHeaderAtIndex me.columnManager.getHeaderIndex(column) - 1
		prevColumn = null if not prevColumn?.cache # fixed for rownumberer and row selection column, they don't have cache
		prevColumnName = prevColumn?.name
		movedColumns = []
		# column has been moved to be the first one
		if not prevColumn
			movedColumns.push column
			column.cache._myProperties.index = startIndex
			startIndex++
			index = startIndex
			for col in columns
				continue if not col.cache
				if col.name isnt movedColumnName
					movedColumns.push col
					updateIndex col, index
					++index
		else
			index = startIndex
			for col in columns
				continue if not col.cache
				if col.name isnt movedColumnName
					movedColumns.push col
					updateIndex col, index
					index++
				if col.name is prevColumnName
					if not column.isGroupHeader
						movedColumns.push column
						updateIndex column, index
						++index
					else
						index = updateSubColumnIndexes column, movedColumns, index
		me.columns = movedColumns
		rebuildRecordDataExtractor movedColumns
		return

	# check the order of columns between old columns and new ones which from cache, should be only used in method #remoteLoadStoreData
	validateColumnOrdersFromCache: (girdcache) ->
		res = {isValid: true, columnsDef: []}
		origColumns = {}
		@columns.forEach (col) ->
			col.pathString and origColumns[col.dataIndex] = col
		newColumns = {}
		if girdcache
			newColumnsCache = girdcache._myProperties.allContents
		else
			newColumnsCache = @cache._myProperties.allContents
		newColumnsCache.forEach (col) ->
			newColumns[col.index] = col
		origColumnsLength = @columns.length
		for index in [0..(origColumnsLength - 1)]
			origCol = origColumns[index]
			newCol = newColumns[index]
			continue if not origCol or not newCol
			if origCol.pathString isnt newCol.pathString
				res.isValid = false
				break
		if res.isValid is false
			newColumns = []
			@createColumnsFromCache newColumns
			res.columnsDef = newColumns
		return res

	shouldReCreateGrid: (gridcache) ->
		isReCreateGrid = true
		if gridcache._myProperties.onlyRefreshGridData
			isReCreateGrid = false
		#TODO grid shoud not recreate later for pagination , inlinefilter , roweditor , grid editable/visible change , grid columns change , grid cell style change
		#TODO now grid whether recreate control by java side .
		return isReCreateGrid

	# to adjust if current grid supports multiple sorting
	isShowMultiSortingIcon: (gridProps) ->
		sortHeaders = gridProps.sortHeaders or []
		gridProps.multiColumnSortingEnabled is true and sortHeaders.length > 0

	#create a sorting icon dom and insert it to column to indicate current sorting information
	insertMultiSortingIcon: (column, sortHeaders) ->
		return false unless column and sortHeaders and sortHeaders.length > 0
		@removeMultiSortingIcon column
		domHelper = Ext.DomHelper
		align = column.align
		position = if align is 'left' then '85%' else '5%'
		dataIndex = column.dataIndex
		isContinue = false
		for h, index in sortHeaders
			if h.index + '' is dataIndex
				sortBy = h.sortBy.toLowerCase()
				isContinue = true
				break
		return false unless isContinue

		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			sortIconSpan = domHelper.createDom
				tag: 'span'
				id: 'sortIcon'
				style: 'display: inline-block; line-height: 41px; color: #656262;'
				class: 'imagediv ' + sortBy.toUpperCase()
			sortIconSpan.innerText = index + 1
			column.titleEl and column.titleEl.dom and column.titleEl.dom.appendChild sortIconSpan
		else
			imgSrc = "resources/images/datagrid-images/#{sortBy}.png"
			sortIconDiv = domHelper.createDom
				tag: 'div'
				id: 'sortIcon'
				style: "float:left;position: absolute;top: 6px;left: #{position};cursor: pointer;z-index:2;width:15px;height:17px;"
				class: 'imagediv'
			sortIndexSpan = domHelper.createDom
				tag: 'span'
				style: 'float: left'
			sortIndexSpan.innerText = index + 1
			sortIconImg = domHelper.createDom
				tag: 'img'
				style: 'float: left;'
				src: imgSrc
			sortIconDiv.appendChild sortIndexSpan
			sortIconDiv.appendChild sortIconImg
			column.titleEl and column.titleEl.dom and column.titleEl.dom.appendChild sortIconDiv
		
		return true

#	remove the sorting icon from column
	removeMultiSortingIcon: (column) ->
		return false unless column
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			rs = column.titleEl.select 'span#sortIcon'
		else
			rs = column.titleEl.select 'div#sortIcon'
		return false if rs.elements.length is 0
		rs.remove()
		return

	onGridViewRefresh: (dataView) ->
		grid = dataView.ownerCt
		container = grid.ownerCt
		return if grid.getWidth() > 3000 or dataView.isLockingView or grid.isLockedView or grid.isLocked
		Ext.suspendLayouts()
		if not grid.cache
			grid = grid.up('coregridbase') or grid.up('coretreebase')
		props = grid.cache._myProperties
		#	restore the rows selection state
		grid.setSelection()
		#	restore sorting state or icon for each column
		if grid.isShowMultiSortingIcon props
			grid.restoreSortingIcon props
		#	auto set column's width as its maxwidth if allowAutoWidth is true
		Ext.each grid.columns, (column) ->
			column.autoSize() if column.allowAutoWidth is true
			return
		#	reset the width and height of grid's container
		if grid.xtype is 'coretreebase'
			fn = Ext.Function.createDelayed ->
				grid.resetContainerHeightAndWidth()
			, 1
			fn()
		else
			grid.resetContainerHeightAndWidth()
		Ext.resumeLayouts()
		if container?.shouldUpdateLayout is true
			delete container.shouldUpdateLayout
			container.updateLayout()
		grid.adjustGroupHeadersWidth()
		# update the footer text
		if (bottomBar = grid.down 'toolbar[dock="bottom"]') and (footerText = props.footerText)
			bottomText =
				xtype: 'tbtext'
				text: footerText
				margin: '0 4 0 4'
				style:
					'color': '#53565A'
			bottomBar.removeAll()
			bottomBar.add bottomText
		grid.updateTitle props.title if Ext.isString(props.title) and grid.xtype is 'coregridbase'
		grid.styleDecorate?()
		return

	onGridViewResize: (view, width, height, oldWidth, oldHeigh) ->
		return if 0 is oldWidth or 0 is oldHeigh
		grid = view.ownerCt
		container = grid.ownerCt
		containerHeight = container?.getHeight()
		return if not containerHeight
		scrollbarHeight = Ext.getScrollbarSize().height
		if grid.hasHScrollbar?()
			[lastRow] = Ext.DomQuery.select 'tr[role=row]:last', view.el.dom
			if lastRow and (container.el.dom.getBoundingClientRect().bottom - lastRow.getBoundingClientRect().bottom) < scrollbarHeight
				container.suspendEvents()
				# FIXME instead of setting height on gridcontainer, why don't set height on grid view?
				container.setHeight scrollbarHeight + containerHeight
				container.heightChanged = true
				container.resumeEvents()
				grid.resetElementHeight container
		else
			if container.heightChanged and not view.xtype is 'treeview'
				container.suspendEvents()
				delete container.heightChanged
				container.setHeight containerHeight - scrollbarHeight
				container.resumeEvents()
		# in order to make grid could change height by content , should delete height of container of grid
		delete container.height if view.xtype is 'treeview'
		return

	resetContainerHeightAndWidth: ->
		comp = this
		view = comp.view
		container = comp.ownerCt
		element = container?.ownerCt
		return unless element and element?.cache and element?.xtype is 'coreelementform'
		layoutType = element.cache._myProperties?.layout?.type
		return unless layoutType is 'VBOX'
		if @stopReset
			delete @stopReset
			return

		if @shouldResetHeight()
			container.shouldUpdateLayout = true
			hScrollHeight = Ext.getScrollbarSize().height
			viewHeight = view.getHeight()
			# FIXME instead of setting height on gridcontainer, why don't set height on grid view?
			if view.minHeight and viewHeight < view.minHeight
				container.setHeight container.getHeight() + view.minHeight - viewHeight + hScrollHeight
			else if view.maxHeight and viewHeight > view.maxHeight
				container.setHeight container.getHeight() + view.maxHeight - viewHeight + hScrollHeight
			else
				container.setHeight container.getHeight() + hScrollHeight
			@resetElementHeight container
			if comp.xtype is 'coretreebase'
				comp.setHeight comp.getHeight() + hScrollHeight
			@stopReset = true
		return

	# patch fix for grid height layout issue
	# root fix is to set height on grid view instead of gridcontainer
	resetElementHeight: (gc) ->
		# the delayed function is to adjust for below layout.
		# at below layout, grid_foo, grid_bar both get hidden after gc.setHeight,
		# we must reset its element/compositeelement's height.
		# Instead of setting height on gridcontainer, we should set height on grid view.
		# view (layout: vbox)
		#	compositeelement (layout: vbox, flex: 1)
		#		compositeelement (layout: hbox)
		#			element (layout: vbox)
		#				grid_foo (flex: 1)
		#			element (layout: vbox)
		#				chart (flex: 1)
		#		element (layout: vbox)
		#			grid_bar (flex: 1)
		#	element
		fn = Ext.Function.createDelayed ->
			ef = gc?.up 'coreelementform'
			if not ef
				return
			ce = ef.up 'corecompositeelement'
			if ce?.body?.getHeight() is 0
				ce.setHeight ce.getHeight()
			else if ef?.body?.getHeight() is 0
				ef.setHeight ef.getHeight()
		, 1
		fn()
		return

	shouldResetHeight: ->
		comp = this
		view = comp.view or {}
		store = comp.store or {}
		data = if store.tree then store.tree.flatten() else store.data
		return false if data?.length is 0
		scrollbarHeight = Ext.getScrollbarSize().height
		selfBottom = comp.getView().el.dom.getBoundingClientRect().bottom
		container = comp.ownerCt
		return false unless container
		containerBottom = container.el.dom.getBoundingClientRect().bottom or 0
		diffHeight = selfBottom - containerBottom
		return not view.isLockingView and comp.hasHScrollbar() and (diffHeight > (scrollbarHeight / 5))

	restoreSortingIcon: (gridProps) ->
		grid = this
		columns = grid.columns
		sortHeaders = gridProps.sortHeaders
		#	enable auto sizing column's width by max content width
		Ext.each columns, (column) ->
			grid.insertMultiSortingIcon column, sortHeaders
			return
		return

#	restore the sorting state of header
	restoreHeaderSortState: ->
		iv = Corefw.util.InternalVar
		grid = this
		aClass = 'x-column-header-sort-ASC'
		dClass = 'x-column-header-sort-DESC'
		props = grid.cache?._myProperties or {}
		sortHeaders = props.sortHeaders or []
		length = sortHeaders.length
		# do not restore if  length of current sorting headers is less than 1
		if length is 0 or length > 1 or props.multiColumnSortingEnabled is true
			return false
		{sortBy, pathString} = sortHeaders[0]
		[h] = grid.columns.filter (c) ->
			c.pathString is pathString
		return unless h?.el?.dom
		headerCt = h.up()
		switch sortBy
			when 'DESC'
				h.addCls dClass
				h.removeCls aClass
			when 'ASC'
				h.addCls aClass
				h.removeCls dClass
			else
				h.removeCls [aClass, dClass]
		headerCt.clearOtherSortStates h
		h.sortState = sortBy
		return true

	hasHScrollbar: ->
		gridViewEl = @view.el
		viewSize = gridViewEl.getSize true
		viewSizeWithoutScollbar = gridViewEl.getViewSize()
		if viewSize.height > viewSizeWithoutScollbar.height
			return true
		else if viewSize.height is viewSizeWithoutScollbar.height
			return false
		return false

	hasVScrollbar: ->
		gridViewEl = @view.el
		viewSize = gridViewEl.getSize true
		viewSizeWithoutScollbar = gridViewEl.getViewSize()
		if viewSize.width > viewSizeWithoutScollbar.width
			return true

		return false

	setMinAndMaxHeightToView: ->
		grid = @ownerCt
		dataView = grid?.view
		return if not dataView or dataView?.isLockingView
		props = grid.cache._myProperties
		minRow = +props.minRow
		maxRow = +props.maxRow
		gridHeaderHeight = (grid.header?.getHeight?() or 0) + grid.headerCt?.getHeight?() or 0
		if minRow
			grid.minHeight = gridHeaderHeight + grid.defaultRowHeight * minRow
		if maxRow
			grid.maxHeight = gridHeaderHeight + grid.defaultRowHeight * maxRow
		return

# disable the select event unless the checker element is the clicking target
	selectHandlerForRowEditor: ->
		return true unless @isEditable
		return @isCheckClicked()

	isCheckClicked: ->
		event = window.event
		return false unless event
		selectBtnCls = Ext.baseCSSPrefix + 'grid-row-checker'
		headerCheckBtnCls = Ext.baseCSSPrefix + 'column-header-text'
		target = event.target
		if target?.classList?.contains(selectBtnCls) or target?.classList?.contains(headerCheckBtnCls)
			return true
		return false
# disable firing events if current is editable

	disableFireEventForRowEditor: ->
		if @isEditable and not @isCheckClicked()
			@stopFireEvents = true
		else
			@stopFireEvents = false
		true

# go through all columns, adjust group header's width
# this is necessary because a grouped header does not support "width" or "flex"
# if all columns in a group have explicitly set widths, then set the group's width to the sum
# otherwise, set the flex equal to the number of columns
	adjustGroupHeadersWidth: ->
		grid = this
		return unless grid and grid.el and grid.el.dom
		gridWidth = grid.getWidth()
		return unless gridWidth > 0 and grid.headerCt.el and grid.headerCt.getWidth() > 0 and not grid.isSetWidth
		headers = grid.headerCt.items.items
		groupHeaders = (headers.filter (h) -> h.isGroupHeader and not h.hidden) or []
		return unless groupHeaders.length >= 1

		needAdjustColumnContext = []
		totalWidth = 0
		totalFlex = 0
		columnsMetaData = grid.cache._myProperties.columnAr
		columns = grid.columns
		for data, index in columnsMetaData
			props = data._myProperties
			continue if props.visible is false
			column = columns[index]
			if flex = props.flexWidth > 0
				totalFlex += flex
				column.ownerCt.isGroupHeader and needAdjustColumnContext.push {column: column, flex: flex}
			else
				totalWidth += props.width or column.getWidth()

		remainingSpace = gridWidth - totalWidth
		# reduce the width of vertical scroll bar
		grid.hasVScrollbar() and remainingSpace -= Ext.getScrollbarSize().width

		for context in needAdjustColumnContext
			column = context.column
			adjustWidth = Math.round remainingSpace / totalFlex
			column.width = adjustWidth
			column.setWidth adjustWidth
			remainingSpace -= adjustWidth
			totalFlex -= context.flex
		grid.isSetWidth = true
		return


#generate the post data for headers
#@param {Object}	the corefw meta data of grid

	generateHeadersPostData: (gridCache) ->
		postData = []
		for prop, oneCache of gridCache
			continue if prop is '_myProperties'
			colProps = oneCache._myProperties
			postProps = {}
			postProps.filterOperator = colProps.filterOperator
			postProps.filterValue = colProps.filterValue
			postProps.visible = colProps.visible
			postProps.name = colProps.name
			postProps.index = +colProps.index
			postProps.width = colProps.width
			postData.push postProps
		return postData

	generatePostDataForRetrieve: ->
		cache = Corefw.util.Common.objectClone @cache
		delete cache._myProperties
		props = @cache._myProperties
		postData =
			name: props.name
		postData.allContents = @generateHeadersPostData cache
		return postData

	onGridViewReady: ->
		@hideColumnsByCache()
		return
	# don't merge to ExtJs 5
	onGridBoxready: ->
#		@hideColumnsByCache()
		return
	hideColumnsByCache: ->
		me = this
		@columnManager.getColumns().forEach (col) ->
			if cache = col.cache
				if cache._myProperties.visible is false
					me.suspendHidingEvent = true
					col.hide()
					delete me.suspendHidingEvent
	prepareFieldObj: ->
		cache = @cache
		# go through cache objects, and create a lookup by PATH,
		# 	since that's how the data is indexed
		fieldObj = @fieldObj = {}
		iv = Corefw.util.InternalVar
		iv.setByNameProperty cache._myProperties.uipath, 'fieldObj', fieldObj
		for key, colObj of cache
			if key isnt '_myProperties'
				prop = colObj._myProperties
				fieldObj[prop.index + ''] = prop

	getFieldObj: (uipath) ->
		iv = Corefw.util.InternalVar
		fieldObj = iv.getByNameProperty uipath, 'fieldObj'
		if not fieldObj
			fieldObj = @prepareFieldObj()
		return fieldObj

	prepareInfinityGridStore: (gridbase, store, scrollStr, storeDataAr) ->
		gridProps = gridbase.cache._myProperties
		if gridProps.infiniteFinish is 'FINISH'
			return
		Ext.suspendLayouts()

		if scrollStr is 'ONSCROLLDOWN'
			if store.data.length is gridProps.bufferedPages * gridProps.pageSize and gridProps.currentPage > gridProps.bufferedPages
				store.currentPage = store.currentPage - gridProps.bufferedPages + 1
			else
				store.currentPage = 1
		else if scrollStr is 'ONSCROLLUP'
			store.currentPage = gridProps.currentPage
		else
			store.currentPage = 1

		if store.totalCount > 0
			storeDataAr =
				totalCount: store.totalCount
				topics: storeDataAr
#		store.loadRawData storeDataAr
		if gridbase.isLockedView
			gridView = gridbase.view.normalView
		else
			gridView = gridbase.view
		gridView.preserveScrollOnRefresh = false
		gridView.scrollRowIntoView(store.getAt(Math.ceil(store.data.length * 4 / 5)))

		gridbase.enableScrollDownEvent = true
		gridbase.enableScrollUpEvent = true
		Ext.resumeLayouts()
		return

	resetInfinityGridConfig: (gridbase, props, scrollStr) ->
		if scrollStr is 'ONSCROLLDOWN' and props.infiniteFinish isnt 'NONE'
			gridbase.enableScrollDownEvent = false
			gridbase.enableScrollUpEvent = true
		if scrollStr is 'ONSCROLLUP'
			if props.currentPage is 1
				gridbase.enableScrollUpEvent = false
			if gridbase.view.normalView?
				gridbase.view.normalView.el.dom.scrollTop = 50
			else
				gridbase.view.el.dom.scrollTop = 50
		return

	getRequestUrl: ->
		me = this
		rq = Corefw.util.Request
		parent = me
		parentProps = parent?.cache._myProperties
		uipath = parentProps.uipath
		events = parentProps?.events or parent.events
		eventStr = if events['ONRETRIEVE'] then 'ONRETRIEVE' else 'ONLOAD'
		shouldSendRqAfterRetrieveData = events['ONRETRIEVE'] and events['ONAFTERRETRIEVE']
		url = rq.objsToUrl3 parentProps.events?[eventStr]
		return url

	remoteLoadStoreData: (postData, options = {}) ->
		me = this
		isTreeGrid = me.xtype is 'coretreebase'
		rq = Corefw.util.Request
		parent = me.ownerCt
		parentProps = parent?.cache._myProperties
		if parentProps.infinity
			return
		uipath = parentProps.uipath
		events = parentProps?.events or {}
		if options.event
			eventStr = options.event
		else
			eventStr = if events['ONRETRIEVE'] then 'ONRETRIEVE' else 'ONLOAD'
			shouldSendRqAfterRetrieveData = events['ONRETRIEVE'] and events['ONAFTERRETRIEVE']
		url = rq.objsToUrl3 parentProps.events[eventStr]
		if isTreeGrid # FIXME: if you find a way to update tree data without replacing tree
			processor = ->
				rq.processResponseObject.apply rq, arguments
				if shouldSendRqAfterRetrieveData
					fieldContainer = Ext.ComponentQuery.query("[uipath=#{uipath}]")[0]
					url = rq.objsToUrl3 parentProps.events['ONAFTERRETRIEVE']
					rq.sendRequest5 url, rq.processResponseObject, uipath, fieldContainer.generatePostData()
			rq.sendRequest5 url, processor, uipath, postData
			return

		refreshData = (jsonObj) ->
			# before replace way is removed, we have to use query to keep correct
			fieldContainer = Ext.ComponentQuery.query("[uipath=#{jsonObj.uipath}]")[0] or {}
			grid = fieldContainer.grid
			return if not grid
			cacheObject = Corefw.util.Cache.parseJsonToCache(jsonObj) or {}
			name = fieldContainer.cache._myProperties.name
			cache = cacheObject[name]
			cache = grid.updateCache cache
			grid.prepareFieldObj()
			props = cache._myProperties
			parentProps.items = cache._myProperties.items
			dataItems = props?.data?.items or []
			storeDataAr = []
			grid.parseData dataItems, storeDataAr, grid.fieldObj
			store = grid.store

			store.currentPage = props.currentPage
			grid.view.preserveScrollOnRefresh = false
			store.loadRawData storeDataAr
			store.totalCount = props.totalRows
			store.pageSize = props.pageSize
			res = grid.validateColumnOrdersFromCache()
			if not res.isValid
				grid.reconfigure store, res.columnsDef
				grid.hideColumnsByCache()
			grid.down('pagingtoolbar')?.onLoad?()

			if shouldSendRqAfterRetrieveData
				url = rq.objsToUrl3 parentProps.events.ONAFTERRETRIEVE
				rq.sendRequest5 url, rq.processResponseObject, uipath, fieldContainer.generatePostData()
			grid.restoreHeaderSortState()
			return

		rq.sendRequest5 url, refreshData, uipath, postData
		return

	updateCache: (cache) ->
		evt = Corefw.util.Event
		return unless cache
		@cache = cache
		# update parent(fieldcontainer)'s cache
		@ownerCt.cache = cache
		#update cache and state for columns
		me = this
		@columns.forEach (col) ->
			if colCache = cache[col.name]
				colProps = colCache._myProperties
				evt.addEvents colProps, 'column', colProps
				colType = if colProps.columnType then colProps.columnType else colProps.type
				columnType = colType?.toLowerCase()
				colProps.corecolumntype = colProps.columnType = columnType
				colProps.index = colProps.index + ''
				col.cache = colCache
				col.iconMap = colProps.iconMap
				col.linkMap = colProps.linkMap
				newTitle = colProps.title
				if col.isVisible() and col.text isnt newTitle
					col.setText newTitle
				groupColumn = col.up 'gridcolumn'
				newGroupColumnTitle = colProps.group?.groupName
				if newGroupColumnTitle and groupColumn and groupColumn.isVisible() and groupColumn.text isnt newGroupColumnTitle
					groupColumn.setText newGroupColumnTitle
				# update visible state
				if not colProps.visible
					me.suspendHidingEvent = true
					col.hide()
					delete me.suspendHidingEvent
			return

		return cache

	parseItemData: (valueObj, fieldObj) ->
		# this is a key/value object representing the entire row
		# we need to go through each value one at a time to see if conversion is necessary
		lineBreakRe = /\n/g
		ExtDate = Ext.Date
		for path, colValue of valueObj
			type = fieldObj[path]?.type?.toLowerCase()
			columnType = fieldObj[path]?.columnType?.toLowerCase()
			if (type is 'date' or columnType is 'date' or columnType is 'datetime' or columnType is 'month_picker') and colValue
				dt = new Date colValue
				valueObj[path] = dt
			else if columnType is 'datestring' and colValue
				valueObj[path] = ExtDate.parse colValue, 'Y-m-d H:i:s'

			if typeof colValue is 'string' and colValue.match lineBreakRe
				valueObj[path] = colValue.replace lineBreakRe, '<br>'
				if not valueObj._myProperties?
					valueObj._myProperties = {}
				valueObj._myProperties.lineBreakExists = true

# transform raw data to value by column type
	parseData: (dataItems, storeDataAr, fieldObj) ->
		parseItemData = @parseItemData
		for valueObj in dataItems
			storeDataAr.push valueObj
			parseItemData valueObj, fieldObj
		return

	parseTreeGridData: (dataNode, fieldObj) ->
		@parseItemData dataNode.value, fieldObj
		children = dataNode.children
		return if children.length is 0
		for node in children
			@parseTreeGridData node, fieldObj