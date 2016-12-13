Ext.define 'Corefw.view.grid.gridpick.GridPickerWindow',
	extend: 'Ext.window.Window'
	xtype: 'coregridpickerwindow'
	header: false
	autoShow: false
	resizable: false
	draggable: false
	focusOnToFront: false
	layout: 'fit'
	overflowX: 'auto'
	overflowY: 'auto'
	minHeight: 21 * 1 + 21 #rowHeight * rowQuantity + headerHeight
	maxHeight: 21 * 10 + 21
	initComponent: ->
		@validValues = []
		@callParent arguments
		addListeners =
			show: (me)->
				combo = me.parentField
				val = if combo.getPostValue then combo.getPostValue() else combo.getValue()
				me.setSelectedValue val
				borderWidth = 4
				if me.grid
					me.grid.setEachColumnSize()
					innerGridWidth = me.grid.getWidthNeeded() + borderWidth
					outerFieldWidth = combo.getWidth()
					gridWrapperWidth = if innerGridWidth > outerFieldWidth then innerGridWidth else outerFieldWidth
					me.setWidth gridWrapperWidth
					me.grid.updatePaginationHeight()
				@initLazyLoadingOnScroll()
				@ajustPosition()
				[mask] = Ext.DomQuery.select '.x-mask[id!=global]'
				mask and mask.style.display = 'none'
				return
		@on addListeners
		pickerwindow = @
		@grid = @add
			xtype: 'grid'
			autoRender: true
			sortableColumns: false
			columns: []
		# update height of pagination grid
			updatePaginationHeight: ->
				grid = @
				props = pickerwindow.parentField?.cache?._myProperties
				pageSize = props.pageSize
				if not pageSize
					return
				recordCount = grid.store.totalCount
				# record count is less than page size
				if recordCount < pageSize
					delete grid.height
					grid.updateLayout()
					# grid height is not settled and record size must be same as page size
				else if not grid.height and recordCount is pageSize
					grid.setHeight grid.getHeight() - 5
				return
			updatePickerValue: ->
				grid = @
				indexOfSelected = []
				picker = pickerwindow.parentField
				picker.selChanging = true
				picker.valueChanged = true

				selModel = grid.getSelectionModel()
				selected = selModel.getSelection()

				store = selModel.store
				for sel in selected
					recordIndex = store.indexOf sel
					indexOfSelected.push recordIndex if recordIndex > -1

				if pickerwindow.multiSelect
					indexOfSelected.sort()
					picker.setPickValue pickerwindow.getValueByIndex indexOfSelected
				else
					picker.setPickValue pickerwindow.getValueByIndex indexOfSelected[0]
					picker.hideGridWindow()
				picker.fireEvent 'select', picker
			listeners:
				afterrender: ->
					@setEachColumnSize()
					return
			getWidthNeeded: ()->
				sum = 0
				cols = @headerCt.columnManager.getColumns()
				borderWidth = 1
				for col in cols
					sum += col.getWidthNeeded() + borderWidth
				return sum
			setEachColumnSize: ()->
				me = @
				delaySet = Ext.Function.createDelayed ->
					cols = me.headerCt.columnManager.getColumns()
					for col in cols
						if col.setColumnMinWidth
							col.setColumnMinWidth()
					return
				, 1
				delaySet()
				return
			selModel:
				mode: if pickerwindow.multiSelect then "SIMPLE" else "SINGLE"

		if pickerwindow.multiSelect
			addListeners =
				selectionchange: ->
					@updatePickerValue()
					return
		else
			addListeners =
				itemclick: ->
					@updatePickerValue()
					return

		@grid.on addListeners
		return
# we have to init lazying loading on scroll evetn inside grid.show event
# to get the gridview dom and add scroll event.
	initLazyLoadingOnScroll: ->
		# If already configued lazyloadingonScrollEvent, just return
		if @lazyLoadingOnScrollEventConfigued
			return
		rq = Corefw.util.Request
		parentField = @parentField
		props = parentField?.cache?._myProperties
		onScrollEvent = parentField.eventURLs?["ONSCROLL"]
		if not onScrollEvent
			return

		me = @

		pageSize = props.pageSize
		grid = @grid
		grid.pageIndex = 1

		if not pageSize
			return

		orignOnScrollEventURL = rq.objsToUrl3 onScrollEvent
		grid.setOverflowXY "hidden", "auto"
		gridViewEl = (grid.down "gridview")?.el

		appendOnScrollData = (resObj) ->
			#increment current grid pageindex only when successful event
			grid.pageIndex++
			newItems = resObj?.gridPicker?.items or []
			records = newItems and Ext.Array.map newItems, (newItem) ->
				return newItem.value
			validValues = resObj?.validValues or []

			me.validValues = (me.validValues or []).concat validValues

			if records.length < pageSize
				grid.enableScrollEvent = false
			grid.getStore().add records if records
			return

		lazyLoadingOnScrollEvent = ->
			pageIndex = grid.pageIndex
			pageIndex++
			fieldVal = parentField.getRawValue()
			onScrollEventURL = "#{orignOnScrollEventURL}&pageIndex=#{pageIndex}"
			if fieldVal
				onScrollEventURL += "&lookupString=#{fieldVal}"
			rq.sendRequest5 onScrollEventURL, appendOnScrollData, '', '', '', '', '', '', {loadMaskTarget: grid}
			return

		gridViewEl.on "scroll", (event, element) ->
			scrollTop = element.scrollTop
			scrollHeight = element.scrollHeight
			viewContentHeight = @getHeight true
			if not grid.enableScrollEvent
				return
			if scrollTop + viewContentHeight is scrollHeight
				lazyLoadingOnScrollEvent()
			return
		@lazyLoadingOnScrollEventConfigued = true
		return
	ajustPosition: ()->
		if not @el or @isHidden()
			return
		combo = @parentField
		bottomY = combo.getY() + @getHeight() + combo.getHeight()
		maxRightX = @getWidth() + combo.getX()

		if maxRightX > Ext.getBody().getWidth()
			x = combo.getX() - (@getWidth() - combo.getWidth())
		else
			x = combo.getX()
		if bottomY > Ext.getBody().getHeight()
			y = combo.inputEl.getY() - @getHeight()
		else
			y = combo.getY() + combo.getHeight()
		@showAt x, y
		return
	getValueByIndex: (index)->
		if Ext.isArray index
			result = []
			for ind in index
				result.push @validValues[ind]
			return result
		else
			return    @validValues[index]
	showData: (data)->
		@validValues = data.validValues
		grid = @grid
		gridPickerProperties = data.gridPicker
		if not gridPickerProperties
			return
		if not @grid
			@grid = @down 'grid'

		fields = []
		columnValues = []
		for p in gridPickerProperties.items or []
			for field of p.value
				if not Ext.Array.contains(fields, field)
					fields.push field
			columnValues.push p.value
		#resset pageIndex to 1 every time grid window reload data.
		grid.pageIndex = 1
		pageSize = @parentField?.cache?._myProperties?.pageSize
		if pageSize
			if columnValues.length < pageSize
				grid.enableScrollEvent = false
			else
				grid.enableScrollEvent = true

		columns = []
		view = grid.view
		for field in gridPickerProperties.allContents or []
			obj =
				text: field.title
				tooltip: field.title
				dataIndex: field.index + ''
				menuDisabled: true
				widthSetted: field.width #gridPickerProperties.allContents[index++].width
				setColumnMinWidth: ()->
					return unless @el
					minWidth = @getWidthNeeded()

					@setWidth minWidth
					return
				getWidthNeeded: ()->
					if @widthSetted
						return @widthSetted
					maxWidth = Number.NEGATIVE_INFINITY
					paddingValue = 12
					position =
						column: @getIndex()
						row: 0
					cell = view.getCellByPosition(position)
					while(cell)
						width = Ext.util.TextMetrics.measure(cell, cell.dom.innerText).width + paddingValue
						if width > maxWidth
							maxWidth = width
						position.row++
						cell = view.getCellByPosition(position)
					headerWidthNeed = Ext.util.TextMetrics.measure(@titleEl, @titleEl.dom.innerText).width
					if @text and @text isnt ''
						headerWidthNeed = headerWidthNeed + @titleEl.getPadding("lr") + @el.getBorderWidth("lr")
					maxWidth = Math.max maxWidth, headerWidthNeed
					return maxWidth
			if field.width
				obj.width = field.width

			switch field.type
				when 'CHECKBOX'
					obj.xtype = 'checkcolumn'
				when 'ICON'
					obj.iconMap = field.iconMap
					obj.renderer = (value = '', metaData, record, rowIndex, colIndex, store) ->
						column = metaData.column
						recordIndex = metaData.recordIndex
						if column and column.iconMap
							metaData.tdCls = column.iconMap[recordIndex]
						if typeof value is 'string'
							value.split '<br>'
							.join ' '
						else
							value
				when 'DATESTRING'
					obj.xtype = 'datecolumn'
					obj.format = field.format or 'Y-m-d H:i:s'
					obj.renderer = (value, metaData) ->
						column = metaData.column
						dateFormat = "Y-m-d H:i:s"
						valueFormat = 'Y-m-d H:i:s'
						if column and column.format
							valueFormat = column.format
						if not Ext.isDate value
							try
								value = Ext.Date.parse value, dateFormat
							catch
								return value
						Ext.util.Format.date value, valueFormat
				when 'DATE'
					obj.xtype = 'datecolumn'
					obj.format = field.format or 'd M Y'

			columns.push obj
		if columns.length
			columns[columns.length - 1].flex = 1
			columns[columns.length - 1].resizable = false
		# grid.suspendEvent 'selectionchange'
		grid.suspendEvents()
		grid.getStore().destroy()
		newStrore = Ext.create 'Ext.data.Store',
			fields: fields
			data: columnValues
		grid.reconfigure newStrore, columns
		grid.resumeEvents()
		if @isVisible() and pageSize
			grid.updatePaginationHeight()
		@ajustPosition()
		return

	hasHScrollbar: (grid)->
		gridViewEl = grid.view.el
		viewSize = gridViewEl.getSize true
		viewSizeWithoutScollbar = gridViewEl.getViewSize()
		if viewSize.height > viewSizeWithoutScollbar.height
			return true
		else if viewSize.height is viewSizeWithoutScollbar.height
			return false
		return false
	setSelectedValue: (value)->
		grid = @grid
		me = @
		if not grid
			return []
		selModel = grid.getSelectionModel()
		if not selModel.views.length
			return []
		cm = Corefw.util.Common
		if not Ext.isArray value
			val = [value]
		else
			val = value
		selected = []
		grid.getStore().each((record)->
			recordVal = me.getValueByIndex record.index
			if Ext.Array.contains cm.getValue(val), cm.getValue(recordVal)
				selected.push record
			return
		)
		selModel.suspendEvents()
		selModel.select selected
		selModel.resumeEvents()
		return selected

	afterRender: ->
		@callParent arguments
		document.addEventListener "click", @
		document.addEventListener "mousewheel", @
		@parentField?.ownerCt.el?.dom.addEventListener "click", @

		ownerGrid = @parentField?.up "grid"
		ownerView = ownerGrid?.view
		if not ownerView
			return
		if ownerView.isLockingView
			ownerView = ownerView.normalView
		ownerView.el?.dom?.addEventListener "scroll", @
		return
# handles events from document.addEventListener
	handleEvent: (ev) ->
		return unless @el
		target = ev.target
		if @el.dom.contains(target) or (@parentField.el and @parentField.el.dom.contains(target))
			return
		loadMask = @grid.loadMask
		if not loadMask or loadMask.isHidden()
			@parentField.hideGridWindow()
		return
	onDestroy: ->
		@callParent arguments
		document.removeEventListener "click", @
		document.removeEventListener "mousewheel", @
		return