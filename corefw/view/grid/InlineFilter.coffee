# datestringfield hard coded everywhere, need refactor
Ext.define 'Corefw.view.grid.InlineFilter',
	extend: 'Ext.AbstractPlugin'
	alias: 'plugin.inlinefilter'
	uses: [
		'Ext.window.MessageBox'
		'CitiRiskLibrary.view.ClearButton'
		'Ext.container.Container'
		'Ext.util.DelayedTask'
		'Ext.layout.container.HBox'
		'Ext.data.ArrayStore'
		'Ext.form.field.Text'
		'Ext.form.field.Date'
	]
	mixins:
		observable: 'Ext.util.Observable'
	# buffer time to apply filtering when typing/selecting
	updateBuffer: 1000

	columnFilteredCls: Ext.baseCSSPrefix + 'column-filtered'
	showClearButton: true
	autoStoresRemoteProperty: 'autoStores'            # if no store is configured for a combo filter then stores are created automatically, if remoteFilter is true then use this property to return arrayStores from the server
	autoStoresNullValue: ''                    # value send to the server to expecify null filter
	autoStoresNullText: '-'                # NULL Display Text
	autoUpdateAutoStores: false                    # if set to true combo autoStores are updated each time that a filter is applied

	enableOperators: true
	visibility: true

	stringTpl:
		xtype: 'textfield'
		type: 'string'

	dateTpl:
		xtype: 'datefield'
		editable: true
		submitFormat: 'Y-m-d'

	dateStringTpl:
		xtype: 'coredatestringfield'
		editable: true
		submitFormat: 'Y-m-d H:i:s'

	numTpl:
		xtype: 'numberfield'
		allowDecimals: true
		hideTrigger: true
		keyNavEnabled: false
		mouseWheelEnabled: false
		decimalPrecision: 10

	comboTpl:
		xtype: 'combo'
		queryMode: 'local'
		typeAhead: true
		triggerAction: 'all'
		onSubmitFilterValueFilter: ->
			me = this
			me.collapse()
			me.fireEvent 'submitfiltervalue', me

			return
		createPicker: ->
			me = this
			picker = undefined
			pickerCfg = Ext.apply({
				xtype: 'boundlist'
				pickerField: me
				selModel: mode: if me.multiSelect then 'SIMPLE' else 'SINGLE'
				floating: true
				hidden: true
				store: me.store
				displayField: me.displayField
				focusOnToFront: false
				pageSize: if me.multiSelect then 10000000 else 0
				tpl: me.tpl
			}, me.listConfig, me.defaultListConfig)
			picker = me.picker = Ext.widget(pickerCfg)
			if me.multiSelect
				picker.pagingToolbar.on 'submitfiltervalue', me.onSubmitFilterValueFilter, me
			me.mon picker,
				itemclick: me.onItemClick
				refresh: me.onListRefresh
				scope: me
			me.mon picker.getSelectionModel(),
				beforeselect: me.onBeforeSelect
				beforedeselect: me.onBeforeDeselect
				selectionchange: me.onListSelectionChange
				scope: me
			return picker
#		onExpand: ->
#			me = this
#			selectedItemsBefore = me.rawValue.split(',') || []
#			selectedLen = selectedItemsBefore.length
#			selectedItems = []
#			j = 0
#			while j < selectedLen
#				if selectedItemsBefore[j].trim() != ''
#					selectedItems.push selectedItemsBefore[j].trim()
#				j++
#			if selectedItems.length
#  				me.select selectedItems
#
#			return
		listConfig:
			getInnerTpl: (displayField) ->
				if Corefw.util.Startup.themeVersion is 2
					'<div class="x-boundlist-item-inner"><div class="x-grid-row-checker x-grid-checkselect role="presentation"><span class="x-list-checkbox">&nbsp&nbsp&nbsp&nbsp&nbsp</span> {' + displayField + '} &nbsp;</div></div>'
				else
					'<div class="x-boundlist-item-innerV1"><div class="x-grid-row-checker x-grid-checkselect role="presentation"><span class="x-list-checkboxV1">&nbsp&nbsp&nbsp&nbsp</span> {' + displayField + '} &nbsp;</div></div>'
			resizeHandles: 'se s sw'
			resizable:
				listeners:
					beforeresize: ->
						@resizeTracker.maxHeight = 10000
						@target.maxHeight = 10000
						return
					resize: ->
						@resizeTracker.maxHeight = 300
						@target.maxHeight = 300
						return
			style:
				whiteSpace: 'nowrap'
			createPagingToolbar: ->
				return Ext.widget 'inlinefilterComboToolbar',
					border: false,
					ownerCt: this,
					ownerLayout: @getComponentLayout()

		clearValue: ->
			@setValue null
			return
	constructor: ->
		me = this
		me.mixins.observable.constructor.call me
		me.callParent arguments
		return

	init: (grid) ->
		me = this

		if grid.inlineFilterVisibility is false
			me.visibility = false
		grid.on
			columnresize: me.resizeContainer
			columnhide: me.resizeContainer
			columnshow: me.resizeContainer
			beforedestroy: me.unsetup
			reconfigure: me.resetup
			scope: me

		grid.addEvents 'filterupdated'

		Ext.apply grid,
			filterBar: me
			getFilterBar: ->
				return @filterBar

		me.setup grid
		if me.visibility is false
			me.unsetup grid

		me.doRemoteFilter = Ext.Function.createBuffered ->
			[field] = arguments
			if field.multiSelect and field.isExpanded
				return
			me.sendRequest()
		, 100
		return

	sendRequest: ->
		grid = @grid
		gridField = grid.ownerCt
		if gridField
			if (gridField.eventURLs?['ONRETRIEVE'])
				postData = grid.generatePostDataForRetrieve()
			else
				postData = gridField.generatePostData()
		grid.remoteLoadStoreData postData
		return

	setup: (grid) ->
		me = this

		me.grid = grid
		me.autoStores = Ext.create 'Ext.util.MixedCollection'
		me.autoStoresLoaded = false
		me.columns = Ext.create 'Ext.util.MixedCollection'
		me.containers = Ext.create 'Ext.util.MixedCollection'
		me.fields = Ext.create 'Ext.util.MixedCollection'
		me.task = Ext.create 'Ext.util.DelayedTask'

		me.parseFiltersConfig()

		if grid.rendered
			me.renderFilterBar grid
		else
			grid.on 'afterrender', me.renderFilterBar, me, {single: true}

		return

	cleanProp: (prop) ->
		prop.each (item) ->
			Ext.destroy item
			return
		prop.clear()
		prop = null
		return

	unsetup: (grid) ->
		me = this
		if me.autoStores isnt null and me.autoStores isnt undefined

			if me.autoStores.getCount()
				me.grid.store.un 'load', me.fillComboStores, me

			me.autoStores.clear()
			me.autoStores = null
			me.columns.each (column) ->
				if column.rendered
					if column.getEl().hasCls me.columnFilteredCls
						column.getEl().removeCls me.columnFilteredCls
				return
			, me
			me.columns.clear()
			me.columns = null
			me.cleanProp me.fields
			me.cleanProp me.containers

			me.task = null
		return

	resetup: (grid) ->
		@unsetup grid
		@setup grid
		return

	resetFilters: (grid) ->
		me = this
		me.fields.each (item) ->
			column = me.columns.get(item.dataIndex)
			ct = @ownerCt
			ct.fieldMouseover = true
			button = ct.down 'button'
			if(button)
				if column
					column.cache._myProperties.filterOperator = 'EQ'
				if column.filter.type is 'combo'
					if me.onlyHaveOneFilterOperators column.cache._myProperties
						column.cache._myProperties.filterOperator = _myProperties.filterOperators[0]
						item.multiSelect = true
					else
						item.multiSelect = false


				operator = me.getOperatorOnButtonIconCls column.cache._myProperties.filterOperator
				button.setIconCls(operator.iconCls)
			item.setValue null
			column.removeCls 'filteredcolumn'
			me.applyFilters item
			return

		return

	parseFiltersConfig: ->
		me = this
		su = Corefw.util.Startup
		columns = me.grid.headerCt.getGridColumns()
		me.columns.clear()
		me.autoStores.clear()

		filterColumns = []
		Ext.each columns, (column) ->
			cache = column.cache
			if not cache
				return
			props = cache._myProperties
			filterType = props.filterType
			if filterType and filterType isnt 'NONE'
				filterColumns.push column
			return

		if not filterColumns.length
			return

		Ext.each columns, (column) ->
			cache = column.cache
			if not cache
				return
			props = cache._myProperties
			filterType = props.filterType

			column.filter =
				disabled: if filterType and filterType isnt 'NONE' then false else true
				column: column
				isInlineFilter: true

			switch filterType
				when 'NUMBER'
					column.filter.type = 'num'
				when 'COMBO'
					column.filter.type = 'combo'
					#set defalut filter operation for only one filterOperators
					if (@onlyHaveOneFilterOperators props) and not props.filterOperator
						cache._myProperties.filterOperator = cache._myProperties.filterOperators[0]
				when 'DATE'
					column.filter.type = 'date'
				when 'DATESTRING'
					column.filter.type = 'dateString'
					column.filter.format = 'Y-m-d H:i:s'
				else
					column.filter.type = 'string'

			if su.getThemeVersion() is 2
				if filterType is 'COMBO'
					column.filter.triggerBaseCls = 'formtriggericon'
					column.filter.triggerCls = 'gridcombotrig'
				if filterType is 'DATESTRING'
					column.filter.cls = 'dateFilterCls'

			if column.filter.type
				column.filter = Ext.applyIf column.filter, me[column.filter.type + 'Tpl']

			if column.filter.type is 'combo' and not column.filter.store
				column.autoStore = true
				column.filter.store = Ext.create 'Ext.data.ArrayStore',
					fields: [{
						name: 'displayValue'
					}, {
						name: 'value'
					}]
				me.autoStores.add column.dataIndex, column
				column.filter = Ext.apply column.filter,
					displayField: 'displayValue'
					valueField: 'value'

			me.columns.add column.dataIndex, column

			return
		, me

		return

	fillComboStores: ->
		me = this
		me?.autoStores?.eachKey (key, item) ->
			records = if item.cache._myProperties.filterOptions then item.cache._myProperties.filterOptions else []
			# look up
			if not records.length
				rq = Corefw.util.Request
				result = []
				# this function is called after the AJAX request returns from the server
				fieldComboCallback = (respArray, uipath) ->
					if Ext.isArray respArray
						respArray.forEach (respObj, index, array) ->
							result.push
								displayValue: respObj['displayField']
								value: respObj['valueField']
							return
						item.filter.store.loadData result
						me.showInitialFilters()
					me.grid?.updateLayout?()
					return

				url = rq.objsToUrl3 item.cache._myProperties.eventURLs['ONLOOKUP'], null, ''
				errMsg = 'Did not receive a valid response for the combobox'
				method = 'POST'
				rq.sendRequest5 url, fieldComboCallback, item.cache._myProperties.uipath, null, errMsg, method
				# non look up
			else
				filter = item.filter
				filterWidget = filter.filterWidget
				filterWidget and filterWidget.suspendEvents()
				filter.store.loadData records
				filterWidget and filterWidget.resumeEvents()
			return
		, me
		return

	addEmptySelection: (records, item) ->
		if item.inlineFilterReady
			return
		records.unshift
			displayValue: @autoStoresNullText
			value: @autoStoresNullValue
		item.inlineFilterReady = true
		return


	applyFiltersOnGrid: ->
		me = this
		store = me.grid.getStore()
		store.clearFilter()
		for i in me.fields.items
			me.applyFilterOnGrid(me.fields.items[_i])
		return

	applyFilterOnGrid: (field) ->
		me = this
		anyMatchStatus = true
		store = me.grid.getStore()
		newVal = if store.remoteFilter then field.getSubmitValue() else field.getValue()
		if field.type is 'string'
			anyMatchStatus = true

		if field.type is 'date'
			time = new Date(newVal).getTime()
			newVal = if time then time else ''

		if not newVal
			newVal = ''

		if newVal isnt ''
			if field.type is 'date'
				filter = new Ext.util.Filter
					property: field.dataIndex
					id: field.dataIndex
					value: newVal
					anyMatch: anyMatchStatus
					caseSensitive: false
					root: 'data'
					filterFn: (item) ->
						if Ext.Date.format(new Date(item.data[@property]),
							'Y-m-d') is Ext.Date.format(new Date(@value), 'Y-m-d')
							return true
						else if Ext.Date.format(new Date(item.data[@property]),
							'Y-m-d H:i:s') is Ext.Date.format(new Date(@value), 'Y-m-d H:i:s')
							return true
						else if @value is null or @value is ''
							return true
						else false

			else
				filter = new Ext.util.Filter
					property: field.dataIndex
					value: newVal
					anyMatch: anyMatchStatus
					caseSensitive: false
					root: 'data'

		store.addFilter(filter, true)
		return

	manageShowHideoperatorOnButton: (operatorOnButton, operatorValueField) ->
		if operatorOnButton and operatorValueField and operatorOnButton.up() and operatorValueField.up()
			if operatorOnButton and not operatorOnButton.up().buttonMouseover and not operatorValueField.up().fieldMouseover
				operatorOnButton.hide()
		return

	showOperatorMenu: (column, operatorOnButton, operatorValueField, operators) ->
		me = this
		su = Corefw.util.Startup
		filterType = operatorValueField.type
		opMenu = Ext.create 'Ext.menu.Menu',
			width: 100
			margin: '0 0 10 0'
			column: column
			operatorOnButton: operatorOnButton
			operatorValueField: operatorValueField
			floating: true
			items: operators
			listeners:
				afterrender: (thisMenu) ->
					if su.getThemeVersion() isnt 2
						return
					thisMenu.tip = Ext.create 'Ext.tip.ToolTip',
						target: thisMenu.getEl().getAttribute('id')
						delegate: '.x-menu-item'
						trackMouse: true
						renderTo: Ext.getBody()
						listeners:
							beforeshow: (tip) ->
								menuItem = thisMenu.queryById tip.triggerElement.id
								if not menuItem.initialConfig.text
									return false
								tip.update menuItem.initialConfig.text
				click: (menu, item, e, eOpts) ->
					menu.operatorOnButton.setIconCls(item.iconCls)
					menu.column.cache._myProperties.filterOperator = item.value
					menu.operatorValueField.up().buttonMouseover = false
					operatorValueField = menu.operatorValueField
					if item.value is 'IN' or item.value is 'NI'
						if filterType is 'combo'
							me.converMultiSelectValue operatorValueField, true
						if filterType is 'num'
							operatorValueField.multiSelect = true
							operatorValueField.baseChars = '0123456789,'

					else
						if filterType is 'combo'
							me.converMultiSelectValue operatorValueField, false
						if filterType is 'num'
							operatorValueField.multiSelect = false
							operatorValueField.baseChars = '0123456789'
					if Ext.isEmpty operatorValueField.value
						return
					me.applyDelayedFilters operatorValueField
					return
				hide: (menu) ->
					menu.operatorValueField.up().buttonMouseover = false
					menu.operatorOnButton.hide()
					menu.operatorOnButton.isMenuWindowOpened = false

		if su.getThemeVersion() is 2
			opMenu.width = 26
			opMenu.minWidth = 26
			opMenu.addCls 'menuIconColor'
			opMenu.showAt(operatorOnButton.getX(), operatorOnButton.getY() + 25)
		else
			opMenu.showAt(operatorOnButton.getX() + 10, operatorOnButton.getY() + 10)
		return

	converMultiSelectValue: (operatorValueField, multiSelect) ->
		if operatorValueField.multiSelect isnt multiSelect
			operatorValueField.multiSelect = multiSelect
			if multiSelect
				operatorValueField.setValue [operatorValueField.value]
			else
				if Ext.isArray operatorValueField.value
					operatorValueField.setValue operatorValueField.value[0]

			operatorValueField.picker?.destroy()
			operatorValueField.picker = null
		return

	getOperatorOnButtonIconCls: (operatorVal) ->
		su = Corefw.util.Startup
		switch operatorVal
			when 'EQ'
				iconCls = 'I_EQUAL'
				text = 'EQUAL'
				value = 'EQ'
			when 'NE'
				iconCls = 'I_NOTEQUAL'
				text = 'NOTEQUAL'
				value = 'NE'
			when 'LT'
				iconCls = 'I_LESSTHAN'
				text = 'LESSTHAN'
				value = 'LT'
			when 'LE'
				iconCls = 'I_LESSTHANEQUAL'
				text = 'LESSEQUAL'
				value = 'LE'
			when 'GT'
				iconCls = 'I_GREATERTHAN'
				text = 'GREATERTHAN'
				value = 'GT'
			when 'GE'
				iconCls = 'I_GREATERTHANEQUAL'
				text = 'GREATEREQUAL'
				value = 'GE'
			when 'IN'
				iconCls = 'I_IN'
				text = 'IN'
				value = 'IN'
			when 'NI'
				iconCls = 'I_NOTIN'
				text = 'NOTIN'
				value = 'NI'
			when 'LIKE'
				iconCls = 'I_LIKE'
				text = 'LIKE'
				value = 'LIKE'

			when 'EQ'
				iconCls = 'I_EQUAL'
				text = 'EQUAL'
				value = 'EQ'

		if su.getThemeVersion() is 2
			operator =
				iconCls: 'icon icon-3x icon-' + Corefw.util.Cache.cssclassToIcon[iconCls]
				text: text
				value: value
		else
			operator =
				iconCls: iconCls
				text: text
				value: value


		return operator

	setUpColumnOperators: (filterOperators) ->
		me = this
		operators = []
		Ext.each filterOperators, (operatorVal) ->
			operator = me.getOperatorOnButtonIconCls(operatorVal)
			operators.push(operator)
		return operators

	renderFilterBar: (grid) ->
		me = this
		su = Corefw.util.Startup
		if me.visibility
			me.containers.clear()
			me.fields.clear()
			me.columns.eachKey (key, column) ->
				listConfig = column.filter.listConfig or {}
				plugins = []
				if me.showClearButton
					plugins.push
						ptype: 'clearbutton'
				colProps = column.cache._myProperties
				filterType = colProps.filterType
				filterOperator = colProps.filterOperator

				multiSelect = filterOperator in ['IN', 'NI']
				#				or colProps.multiFilterCriteria

				filterConf = Ext.apply column.filter,
					inlineFilter: me
					dataIndex: key
					flex: 1
					margin: 0
					fieldStyle: 'border:none 0px black;'
					fieldCls: 'operatorValueFieldCls'
					region: 'center'
					listConfig: listConfig
					preventMark: true
					msgTarget: 'none'
					checkChangeBuffer: 50
					enableKeyEvents: true
				#maskRe: if multiSelect then new RegExp("[^]*") else new RegExp("[^,]")
					plugins: plugins
					listeners:
						change: me.applyDelayedFilters
						submitfiltervalue: me.applyFieldFilter
						keypress: (txt, e) ->
							if e.getCharCode() is 13
								e.stopEvent()
								txt.collapse() if txt.isExpanded
								me.onKeyPressApplyFilters txt
							return false
						focus: ->
							ct = @ownerCt
							ct.fieldMouseover = true
							btn = ct.down 'button'
							btn?.show()
						mouseenter:
							element: 'el'
							fn: ->
								field = Ext.getCmp @id
								ct = field.ownerCt
								ct.fieldMouseover = true
								btn = ct.down 'button'
								btn?.show()
						mouseleave:
							element: 'el'
							fn: ->
								field = Ext.getCmp @id
								ct = field.ownerCt
								ct.fieldMouseover = false
								btn = ct.down 'button'
								field.column.showHideOperatorTask?.delay 20, null, me, [btn, field]

				if filterType is 'COMBO'
					filterConf = Ext.apply column.filter,
						typeAhead: not multiSelect
						multiSelect: multiSelect

				if filterType is 'NUMBER'
					filterConf = Ext.apply column.filter,
						baseChars: if multiSelect then '0123456789,' else '0123456789'

				field = Ext.widget column.filter.xtype or column.filter.type, filterConf
				me.fields.add column.dataIndex, field

				column.filter.filterWidget = field

				ctConf =
					items: [field]
					dataIndex: key
					cls: 'filterCt'
					layout: 'border'
					height: 23
					buttonMouseover: false
					fieldMouseover: false
					bodyStyle: 'background-color: "transparent";'
					width: column.getWidth()
					listeners:
						scope: me,
						element: 'el',
						mousedown: (e) ->
							e.stopPropagation()
							return
						click: (e) ->
							e.stopPropagation()
							return
						dblclick: (e) ->
							e.stopPropagation()
							return
						keydown: (e) ->
							e.stopPropagation()
							return
						keypress: (e) ->
							e.stopPropagation()
							return
						keyup: (e) ->
							e.stopPropagation()
							return

				if filterType in ['NUMBER', 'DATA', 'DATESTRING', 'STRING',
								  'COMBO'] and not @onlyHaveOneFilterOperators colProps
					filterOperators = column.cache._myProperties.filterOperators or {}
					numOfOperators = filterOperators.length

					if numOfOperators
						operators = me.setUpColumnOperators filterOperators

						column.showHideOperatorTask = new Ext.util.DelayedTask me.manageShowHideoperatorOnButton, me
						filterOperator = column.cache._myProperties.filterOperator

						if filterOperator
							operator = me.getOperatorOnButtonIconCls filterOperator
							iconCls = operator.iconCls
						else
							iconCls = if su.getThemeVersion() is 2 then 'icon icon-3x icon-equal-to' else 'I_EQUAL'


						operatorOnButton = new Ext.button.Button
							style: 'float:left;'
							itemId: 'operatorOnButton'
							hidden: true
							iconCls: iconCls
							region: 'west'
							isMenuWindowOpened: false
							cls: 'operatorOnButtonCls'
							listeners:
								click: (button) ->
									button.up().buttonMouseover = true
									button.isMenuWindowOpened = true
									me.showOperatorMenu column, button, field, operators
									return
								mouseover: (button) ->
									button.up().buttonMouseover = true
									button.show()
									return
								mouseout: (button) ->
									if not button.isMenuWindowOpened
										button.up().buttonMouseover = false
									column.showHideOperatorTask.delay 20, null, me, [operatorOnButton, field]
									return

						ctConf.items.unshift operatorOnButton

				if su.getThemeVersion() is 2
					ctConf.height = '22px'

				container = Ext.create 'Ext.container.Container', ctConf
				me.containers.add column.dataIndex, container
				container.render Ext.get(column.id)
				return
			, me

			if me.autoStores.getCount()
				me.fillComboStores()
				me.grid.store.on 'refresh', me.fillComboStores, me
			me.showInitialFilters()

		return

	onlyHaveOneFilterOperators: (colProps) ->
		hide = false
		if colProps.filterOperators?.length is 1
			hide = true
		return hide

	showInitialFilters: ->
		filterValObj = {}
		colProperties = {}
		grid = @grid
		cache = grid.cache

		for item, oneCache of cache
			if item isnt '_myProperties'
				props = oneCache._myProperties
				filterValue = props.filterValue
				filterValObj[props.index] = filterValue
				colProperties[props.index] = props

		items = @grid.filterBar.fields.items
		for item in items
			item.suspendEvents()
			filterValue = filterValObj[item.dataIndex]
			if not Ext.isEmpty filterValue
				item.column.addCls 'filteredcolumn'
			else
				item.column.removeCls 'filteredcolumn'
			if item.type.toLowerCase() is 'date'
				filterValue = new Date(filterValue)
				filterValue = Ext.Date.format filterValue, 'Y-m-d'
			if item.type.toLowerCase() is 'datestring' and filterValue
				filterValue = new Date(filterValue)
			item.setValue if filterValue or filterValue is false then filterValue else ''
			item.resumeEvents()

		@restoreFieldFocus grid
		return

	resizeContainer: (headerCt, col) ->
		dataIndex = col.dataIndex
		if not dataIndex
			return
		item = @containers.get dataIndex
		if item and item.rendered
			itemWidth = item.getWidth()
			column = @columns.get(dataIndex)
			return unless column.el
			colWidth = column.getWidth()
			if itemWidth isnt colWidth
				item.setWidth @columns.get(dataIndex).getWidth()
				item.doLayout()

		return

	restoreFieldFocus: (grid) ->
		iv = Corefw.util.InternalVar
		columns = grid.columns
		uipath = grid.up('coreobjectgrid')?.uipath
		#unsupport mix grid
		if uipath is undefined
			return
		fieldDataIndex = iv.getByUipathProperty uipath, 'fieldDataIndex'
		for column in columns
			if column.dataIndex is fieldDataIndex
				filterColumn = column
				break
		filterField = filterColumn?.filter?.filterWidget
		if filterField
			filterField.focus(false)
			iv.deleteUipathProperty uipath, 'fieldDataIndex'
		return

	storeScrollbarPosition: (iv, uipath) ->
		view = @grid.getView()
		if view.normalView
			iv.setByUipathProperty uipath, 'gridscroll_normal_left', view.normalView.el.getScroll().left
			iv.setByUipathProperty uipath, 'gridscroll_locked_left', view.lockedView.el.getScroll().left
		else
			iv.setByUipathProperty uipath, 'gridscroll_left', view.el.getScroll().left
		return

	storeCurrentFilterField: (iv, field, uipath) ->
		iv.setByUipathProperty uipath, 'fieldDataIndex', field.dataIndex
		return

	applyFilters: (field, isKeyPress) ->
		if not field.isValid()
			return
		me = this
		iv = Corefw.util.InternalVar
		grid = me.grid
		if not me.columns
			return
		column = me.columns.get field.dataIndex
		newVal = if grid.store.remoteFilter then field.getSubmitValue() else field.getValue()
		colCache = column.cache
		colProps = colCache._myProperties
		switch colProps.filterType
			when 'DATE'
				time = new Date(newVal).getTime()
				newVal = if time then time else null
			when 'DATESTRING'
				time = if newVal then Ext.Date.format newVal, 'Y-m-d H:i:s' else newVal
				newVal = if time then time else null
			when 'COMBO'
				if (@onlyHaveOneFilterOperators colProps) and not colProps.filterOperator
					colProps.filterOperator = colProps.filterOperators[0]

		if newVal is null
			delete colProps.filterValue
		else
			colProps.filterValue = newVal
		if not colProps.filterOperator
			colProps.filterOperator = 'EQ'

		uipath = grid.up().uipath
		@storeScrollbarPosition iv, uipath
		@storeCurrentFilterField iv, field, uipath
		me.doRemoteFilter field
		return


	applyDelayedFilters: (field) ->
		# make sure change event will not apply combo filter
		if not field.isValid() #or field.type is 'combo'#or field.multiSelect
			return
		inlineFilter = field.inlineFilter
		inlineFilter.task.delay inlineFilter.updateBuffer, inlineFilter.applyFilters, inlineFilter, [field]
		return

	applyFieldFilter: (field) ->
		inlineFilter = field.inlineFilter
		inlineFilter.applyFilters field
		return


	onKeyPressApplyFilters: (field) ->
		if not field.isValid()
			return
		me = this
		me.task.delay 0, me.applyFilters, me, [field]
		return