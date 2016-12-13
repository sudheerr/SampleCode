###
	This grid is always contained in a form field.
	As such, it extends fieldcontainer, and then creates a GridBase object
		inside that container
###

Ext.define 'Corefw.view.grid.ObjectGrid',
	extend: 'Corefw.view.grid.GridFieldBase'
	xtype: 'coreobjectgrid'
	mixins: ['Corefw.mixin.Refreshable']

	initComponent: ->
		@coretype = 'field'
		@initalizeObjectGrid()
		@addListeners()
		@callParent arguments
		return

	addListeners: ->
		@listeners = @listeners or {}
		additionalListeners =
			gridclose: @gridclose

		Ext.apply @listeners, additionalListeners

	gridclose: (objGrid)->
		objGrid.onGridClose()
		return

	initalizeObjectGrid: ->
		me = this
		cm = Corefw.util.Common
		tools = []
		evt = Corefw.util.Event
		#de = Corefw.util.Debug
		su = Corefw.util.Startup

		cache = me.cache
		fieldProps = cache._myProperties

		@uipath = fieldProps.uipath

		fieldItemstype = fieldProps.columnAr

		# if filterType is present then showhidefiltr is true and adds a button to grid
		showhidefiltr = @isFilterEnabledForAnyColumn fieldItemstype

		# if de.printOutGridFields()
		# 	console.log ' -> -> ->', fieldProps.name, cache

		functionButtonType = 'tool'
		if fieldItemstype
			for fieldItem in fieldItemstype
				if fieldItemstype[_i]._myProperties.filterType is 'NUMBER' and fieldItemstype[_i]._myProperties.filterValue == 0
					cache[fieldItemstype[_i]._myProperties.name]._myProperties.filterValue = '0'
		gridConfig =
			inlineFilterVisibility: !fieldProps.hideGridHeaderFilters
			columns:
				defaults:
					lockable: false
				items: []
			hideHeaders: false
			coretype: 'field'
			corefieldtype: 'objectgrid'
			functionButtonType: functionButtonType
			style:
				borderWidth: '0px'
		if me.fieldLabel
			if su.getThemeVersion() isnt 2
				tools.push
					xtype: 'text'
					name: 'fieldLabel'
					text: ( if me.fieldLabel is '&nbsp;' then '' else me.fieldLabel)
					margin: '0 10 0 0 '
					cls: 'custom-header'
			else
				tools.push
					xtype: 'text'
					name: 'fieldLabel'
					text: ( if me.fieldLabel is '&nbsp;' then '' else me.fieldLabel)
					margin: '0 10 0 5 '
					cls: 'custom-header'

		switch functionButtonType
			when 'toolbar'
				dockedItems = []
				tbar = []
				topBar =
					xtype: 'toolbar'
					dock: 'top'
					items: tbar
				dockedItems.push topBar


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
							xtype: 'button' #///changed the look and feel according to UX guidelines///*
							ui: 'toolbutton'
							scale: 'small'
							tooltip: nav.toolTip
						# type: nav.name
							iconCls: nav.style
						if su.getThemeVersion() is 2
							if nav.style is 'I_SPACER'
								addlConfig =
									xtype: 'tbseparator'
									cls: 'iconSeparator'
									margin: '0 4 0 4'
							else
								addlConfig.iconCls = 'icon icon-' + Corefw.util.Cache.cssclassToIcon[nav.style]
								addlConfig.padding = '0 4 0 4'

						Ext.apply gridToolObj, addlConfig
						tools.push gridToolObj

					when 'toolbar'
						config =
							xtype: 'button'
							margin: '0 0 0 9'

						if nav.title
							config.text = nav.title
						else
							config.text = ' '

						if nav.style
							config.iconCls = nav.style

						Ext.apply gridToolObj, config
						tbar.push gridToolObj

				evt.addEvents nav, 'nav', gridToolObj

		if fieldProps.multiColumnSortingEnabled
			tools.push
				xtype: 'button' #///changed the look and feel according to UX guidelines///*
				ui: 'toolbutton'
				scale: 'small'
				iconCls: if su.getThemeVersion() is 2 then 'icon icon-sort-asc' else 'I_SORTER'
				onClick: ->
					Ext.create 'Corefw.view.grid.SortingWindow',
						grid: @up 'grid'
					return

		if showhidefiltr
			me = @
			if su.getThemeVersion() is 2
				showhidefilter = me.cache._myProperties.hideGridHeaderFilters
				filterVisibility = me.inlineFilterVisibility
				InlineFilterIconCls = if showhidefilter is true then 'icon icon-filterswitch-1' else if filterVisibility is false then 'icon icon-filterswitch-1' else 'icon icon-filterswitch-2'

			else
				InlineFilterIconCls = if me.inlineFilterVisibility is undefined then 'I_SHOWFILTER' else if me.inlineFilterVisibility is false then 'I_HIDEFILTER' else 'I_SHOWFILTER'
			tools.push
				xtype: 'button'
				ui: 'toolbutton'
				scale: 'small'
				tooltip: 'Hide/Show Filters'
				iconCls: InlineFilterIconCls
				handler: ->
					thePlugin = me.grid.findPlugin('inlinefilter')
					if thePlugin.visibility
						thePlugin.visibility = false
						if su.getThemeVersion() is 2
							@setIconCls('icon icon-filterswitch-1')
						else
							@.setIconCls('I_HIDEFILTER')
						thePlugin.resetup me.grid
					else
						thePlugin.visibility = true
						if su.getThemeVersion() is 2
							@setIconCls('icon icon-filterswitch-2')
						else
							@.setIconCls('I_SHOWFILTER')
						thePlugin.setup me.grid
					me.grid.getView().refresh()
					me.inlineFilterVisibility = thePlugin.visibility # to make sure that customerperspective grids are hidden when clicked on other tabs
					return
			,
				# to clear the filters
				xtype: 'button'
				ui: 'toolbutton'
				scale: 'small'
				tooltip: 'Clear All Filters'
				iconCls: if su.getThemeVersion() is 2 then 'icon icon-filter-delete' else 'I_CLEARFILTER'
				handler: ->
					thePlugin = me.grid.findPlugin('inlinefilter')
					thePlugin.resetFilters me.grid
					return

		# only show the toolbar if editable is set to TRUE
		if fieldProps.editable or tbar?.length > 0 or tools?.length > 0
			tools.push
				xtype: 'tbfill'

			gridConfig.header = {}
			gridConfig.header.titlePosition = tools.length

			switch functionButtonType
				when 'tool'
					gridConfig.tools = tools
				when 'toolbar'
					gridConfig.dockedItems = dockedItems

		#if su.getThemeVersion() is 2 
		if  fieldProps and fieldProps.footerPagingToolbar
			@margin = '0 0 0 0'
			bottomBar =
				xtype: 'toolbar'
				dock: 'bottom'
				height: 25
				cls: 'bottomBarBorder'
				style:
					'background-color': if su.getThemeVersion() is 2 then '#D5D6D7' else '#FFFFFF'
					'border-bottom-color': '#FFFFFF'
			#'border-top-width': '1px !important' #important is for temporary  override basetheme dock important. Will be removed as soon as possible.
			#'border-top-style': 'solid'
			#'border-top-color': '#BABBBD'


			if dockedItems
				dockedItems.push bottomBar
			else
				dockedItems = []
				dockedItems.push bottomBar
			gridConfig.dockedItems = dockedItems

		# copy the following properties to column header
		propertiesToCopy = [
			'fieldMask'
			'editable'
			'enabled'
			'visible'
			'events'
			'isLookup'
			'title'
			'path'
			'pathString'
			'tooltip'
			'toolTip'
			'validations'
			'validValues'
			'group'
			'rows'
			'width'
			'minWidth'
			'maxWidth'
			'supportMultiSelect'
			'filterType'
			'filterValue'
			'filterOperator'
			'filterOperators'
			'supportSort'
			'feValidations'
			'uipath'
			'name'
			'iconMap'
			'format'
			'multiSelect'
			'lookupable'
			'sortState'
			'spinnerSpec'
			'linkMap'
			'menu'
			'dropdownMenu'
			'supportWholeCheck'
			'gridPicker'
			'textAlign'
			'multiColumnSortingEnabled'
			'index'
			'pageSize'
			'flexWidth'
			'hideable'
			'lockable'
			'draggable'
			'showColumnsMenu'
			'minDate'
			'maxDate'
			'multiFilterCriteria'
			'filterOptions'
			'onlyHaveOneFilterOperators'
		]

		# we have to make the grid object look like a "regular" grid object
		# to hand off to configGrid

		# change "field" in breadcrumb to "content"
		props = cache._myProperties

		gridCache = {}
		gridConfig.cache = gridCache
		gridProps = {}
		gridCache._myProperties = gridProps

		# use columnAr if it exists -- newer format
		fieldItems = props.columnAr
		if not fieldItems
			fieldItems = props.items

		if fieldItems
			for item in fieldItems
				itemProps = item._myProperties
				continue unless itemProps
				newItemObj =
					_myProperties:
						columnType: itemProps.type

				newItemProps = newItemObj._myProperties
				cm.copyObjProperties newItemProps, itemProps, propertiesToCopy
				gridCache[itemProps.name] = newItemObj

				# is a field is editable, then the entire grid is editable
				# TODO merge editableColumns/editable
				if itemProps.editable
					props.editableColumns = true
					gridProps.editableColumns = true
					gridProps.editable = true

		cachePropertiesToCopy = [
			'enableTextSelection'
			'events'
			'groupField'
			'onlyRefreshGridData'
			'enableAutoSelectAll'
			'data'
			'name'
			'uipath'
			'title'
			'columnAr'
			'headerEllipses'
			'headerTitleRows'
			'numberOfLockedHeaders'
			'supportAutoNumber'
			'showFullRow'
			'selectType'
			'checkOnly'
			'collapsible'
			'mandatory'
			'sortHeaders'
			'hideGridHeaderMenus'
			'multiColumnSortingEnabled'
			'draggable'
			'recievablePaths'
			'maxRow'
			'minRow'
			'closable'
			'infinity'
			'bufferedPages'
			'infiniteFinish'
			'footerText'
			'pageSize'
			'currentPage'
			'showEditingMask'
			'buffered'
			'selectedAll'
			'selectAllScope'
		]
		cm.copyObjProperties gridProps, props, cachePropertiesToCopy

		# hide the grid title panel
		if not fieldProps.pageSize and fieldProps.showTitleBar is false
			delete gridConfig.title
			delete gridConfig.tools
			delete gridConfig.header

		gridcls = 'Corefw.view.grid.GridBase'
		comp = Ext.create gridcls, gridConfig
		@addGrid comp

		# we have to replace the "getCell" function in gridview,
		# 	because it doesn't properly test for a blank row DOM
		#	this was causing a crash in createGridTooltip
		view = comp.getView()
		view.getCell = (record, column) ->
			row = view.getNode record, true
			if not row or not column
				return
			return Ext.fly(row).down(column.getCellSelector());

		return

	afterRender: ->
		@callParent arguments
		props = @cache._myProperties
		currency = props.currency
		unit = props.numberScaleUnit

		if currency isnt undefined
			@createCurrencyCmp props.selectableCurrencies, currency
		if unit isnt undefined
			@createUnitCmp props.selectableNumberScaleUnits, unit

		@createPagingToolbar()
		return

	createComboboxInHeader: (name, datas, selected)->
		me = @
		header = @down 'header'
		if not header
			return
		toolBtns = header.query '[docked=right]'
		if toolBtns.length
			addIndex = header.items.indexOf toolBtns[0]
		else
			addIndex = header.items.length
		comboCfg =
			xtype: "combo"
			editable: false
			margin: "2 2 2 2"
			displayField: 'displayField'
			valueField: 'valueField'
			width: 50
			align: 'right'
			value: selected
			name: name
			getDisplayValue: ()->
				display = @displayTpl.apply @displayTplData
				return if display is "&nbsp;" then "" else display
			store: Ext.create 'Ext.data.Store',
				fields: ["displayField", "valueField"]
				data: datas
			listeners:
				change: (combo, newValue, oldValue)->
					me.comboboxInHeaderChange()
					return

		header.insert addIndex, comboCfg
		return

	registHeaderPostCmp: (name)->
		if not @headerPostCmpNames
			@headerPostCmpNames = []
		@headerPostCmpNames.push name
		return

	comboboxInHeaderChange: ()->
		postData = {}
		for name in @headerPostCmpNames
			postData[name] = @down("[name=" + name + "]").getValue()
		@sendONLOADRequest postData
		return

	createLabelInHeader: (name, text)->
		#me = @
		header = @down 'header'
		if not header
			return
		toolBtns = header.query '[docked=right]'
		if toolBtns.length
			addIndex = header.items.indexOf toolBtns[0]
		else
			addIndex = header.items.length
		labelCfg =
			xtype: "label"
			margin: "2 2 2 2"
			align: 'right'
			text: text
			name: name
			getValue: ()->
				return text
		header.insert addIndex, labelCfg
		return

	createCurrencyCmp: (datas, selected)->
		cmpName = "currency"
		@registHeaderPostCmp cmpName
		if datas
			newDatas = []
			for data in datas
				newDatas.push {displayField: data, valueField: data}
			@createComboboxInHeader cmpName, newDatas, selected
		else
			@createLabelInHeader cmpName, selected
		return

	createUnitCmp: (datas, selected)->
		cmpName = "numberScaleUnit"
		@registHeaderPostCmp cmpName
		if datas
			newDatas = []
			for data in datas
				newDatas.push {displayField: data || "&nbsp;", valueField: data}
			@createComboboxInHeader cmpName, newDatas, selected
		else
			@createLabelInHeader cmpName, selected
		return

	applyPaginationStore: (store, props) ->
		currentPage = props.currentPage
		ceilPage = Math.ceil props.totalRows / props.pageSize
		floorPage = Math.floor props.totalRows / props.pageSize
		if currentPage > floorPage
			if ceilPage == floorPage
				currentPage = floorPage
			else
				currentPage = ceilPage

		# set correct params for store
		storeConfig =
			totalCount: props.totalRows
			pageSize: props.pageSize
			currentPage: currentPage
			selectablePageSizes: props.selectablePageSizes

		Ext.apply store, storeConfig
		return

	createPagingToolbar: ->
		me = @
		props = @cache._myProperties
		su = Corefw.util.Startup
		cache = me.cache
		fieldProps = cache._myProperties

		if props.pageSize and ( not Ext.isEmpty props.totalRows ) and not fieldProps.infinity
			# TODO update Footer text and Total Selected Records even if there is no Pagination Toolbar
			header = @down 'header'
			if header
				loadConfig =
				# replace the store's default loadPage behavior with our own
					loadPage: (pageNum) ->
						me.loadPage pageNum
						return
				@applyPaginationStore me.grid.store, props
				Ext.apply me.grid.store, loadConfig

				pagingToolbarConfig =
					xtype: 'corepagingtoolbar'
					cache: props
					store: @grid.store
					displayInfo: true
					margin: '0 20 0 0'

				if su.getThemeVersion() is 2
					pagingToolbarConfig.displayInfo = false
					pagingToolbarConfig.margin = '0 8 0 0'

				toolBtns = header.query '[docked=right]'
				if toolBtns.length
					addIndex = header.items.indexOf toolBtns[0]
				else
					addIndex = header.items.length
				header.insert addIndex, pagingToolbarConfig
		return

	generatePagingPostData: (pageNum, pageSize, total) ->
		prop = @cache._myProperties
		pageNum = pageNum || 1
		pageSize = pageSize || prop.pageSize || 1
		total = total || prop.totalRows || 1

		if pageNum > Math.ceil(total / pageSize)
			pageNum = Math.ceil(total / pageSize)
		postData =
			name: @cache._myProperties.name
			total: total
			currentPage: pageNum
			pageSize: pageSize
		Ext.apply postData, @grid.generatePagingPostData()
		return postData

	loadPage: (pageNum) ->
		me = @
		pageSize = me.grid.store.pageSize
		postData = me.generatePagingPostData pageNum, pageSize
		me.grid.remoteLoadStoreData postData
		return

	switchSelectAllScope: ->
		me = @
		postData = me.generatePostData()
		me.grid.remoteLoadStoreData postData
		return

	sendRequest: (pageNum)->
		events = @cache?._myProperties?.events or {}
		eventStr = if events.ONRETRIEVE then 'ONRETRIEVE' else 'ONLOAD'
		rq = Corefw.util.Request
		url = rq.objsToUrl3 @eventURLs[eventStr], @localUrl
		postData = @generatePagingPostData pageNum

		Corefw.util.Request.sendRequest5 url, rq.processResponseObject, @uipath, postData
		return

# return the data for the underlying grid
	generatePostData: ->
		if @forcedSelectedRecord
			@grid.forcedSelectedRecord = @forcedSelectedRecord

		postData = @grid.generatePostData()
		delete @grid.forcedSelectedRecord

		return postData

	onGridClose: ()->
		rdr = Corefw.util.Render
		rdr.destroyThisComponent @
		return

	statics:
		createDataCache: (dataFieldItem, fieldCache) ->
			#su = Corefw.util.Startup
			cm = Corefw.util.Common

			if not dataFieldItem
				props = fieldCache?._myProperties
				dataFieldItem = {}
				dataFieldItem.items = props.items
				dataFieldItem.sortHeaders = props.sortHeaders

			fieldDataCache = []
			gridObjAlreadyCreated = false

			props = fieldCache._myProperties

			props.data = {}
			propsData = props.data
			propsData.items = fieldDataCache

			if dataFieldItem.sortHeaders
				propsData.sortHeaders = dataFieldItem.sortHeaders

			objPropMap =
				index: '__index'
				tooltipValue: '__misc'


			copyProperties = [
				'changed'
				'removed'
				'new'
				'subGrid'
				'selected'
				'selectable'
				'editable'
				'validValues'
				'cssClass'
				'cssClassList'
				'cellCssClass'
				'messages'
			]

			# the data rows are in field.items
			if dataFieldItem.items
				for item in dataFieldItem.items
					# if "items" property exists, then it's a "mixedgrid (tree)"
					if item.items
						if gridObjAlreadyCreated
							fieldGridArray = propsData.grid
						else
							gridObjAlreadyCreated = true
							fieldGridArray = []
							propsData.grid = fieldGridArray

						gridItem = cm.objectClone item
						fieldGridArray.push gridItem
					else
						newObj = cm.objectClone item.value
						# copy the other properties directly into this object

						newObj._myProperties = {}
						cm.copyObjProperties newObj._myProperties, item, copyProperties

						for oldKey, newKey of objPropMap
							oldVal = item[oldKey]
							if typeof oldVal isnt 'undefined'
								if Ext.isObject oldVal
									newObj[newKey] = cm.objectClone oldVal
								else
									newObj[newKey] = oldVal

						fieldDataCache.push newObj

			return