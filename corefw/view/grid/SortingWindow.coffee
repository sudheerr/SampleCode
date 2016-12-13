Ext.define 'Corefw.view.grid.SortingWindow',
	extend: 'Ext.window.Window'
	alias: 'widget.coresortingwindow'
	xtype: 'coresortingwindow'
	cls: 'sortingwindow'
	autoShow: true
	modal: true
	title: 'COLUMN MULTI SORTING'
	width: 520
	sortingItemHeight: 56
	sortingItemSpacing: 15
	remainedColumns: []
	layout:
		type: 'vbox'
	sortEvent: 'ONRETRIEVE'

	items: [
		xtype: 'fieldcontainer'
		height: @sortingItemHeight
		id: 'selectionArea'
		cls: 'sortingwindowbody'
		overflowY: 'auto'
		overflowX: 'hidden'
		margin: '0 0 0 0'
		items: []
	,
		xtype: 'fieldcontainer'
		id: 'buttonArea'
		cls: 'sortingwindowfooter'
		width: '100%'
		height: 40			
		layout: 
			type: 'hbox'
			pack: 'end'	
		items: [
			xtype: 'primarybutton'
			text: 'Apply'
			margin: '4 10 0 4'
			id: 'applyBtn'
		,
			xtype: 'secondarybutton'
			text: 'Clear'
			margin: '4 10 0 0'
			id: 'clearBtn'
		,
			xtype: 'secondarybutton'
			text: 'Cancel'
			margin: '4 0 0 0'
			id: 'cancelBtn'
		]
	]

	indexTextMap:
		1: '1st'
		2: '2nd'
		3: '3rd'

	initComponent: ->
		@callParent arguments

		su = Corefw.util.Startup
		@bodyPadding = 10 if su.getThemeVersion() isnt 2
		
		@bindEventToButtons()
		me = this
		grid = me.grid
		fieldCt = grid?.up 'fieldcontainer'
		return unless fieldCt
		props = fieldCt.cache._myProperties

		me.sortableCols = if grid? then Ext.clone grid.query 'gridcolumn[sortable=true]' else []
		me.remainedColumns = if grid? then Ext.clone grid.query 'gridcolumn[sortable=true]' else []
		me.sortHeaders = props.sortHeaders
		me.dataProps = props
		@initSortingItems()
		return
					
	bindEventToButtons: () ->
		me = this

		clearBtn = me.child '#buttonArea>#clearBtn'
		clearBtn.onClick = @clearSoringSelections

		cancelBtn = me.child '#buttonArea>#cancelBtn'
		cancelBtn.onClick = @cancelWindow

		applyBtn = me.child '#buttonArea>#applyBtn'
		applyBtn.onClick = @applyMultiSoring

		return

	initSortingItems: ->
		me = this
		sortHeaders = Ext.clone me.sortHeaders or []
		sortHeaders.push sortBy: 'ASC' if me.sortableCols.length > sortHeaders.length or sortHeaders.length is 0
		selectionArea = me.child '#selectionArea'
			
		for header,index in sortHeaders
			sortBy = header.sortBy
			value = header.title
			me.scStore = me.createSortingItemStore()
			selectionArea.add me.createSortingItem index + 1, sortBy, value, me.scStore

		scStore = me.createSortingItemStore()
		me.handleComboboxStore scStore

		return

	createSortingItemStore: (newVal, oldVal, newItemNeeded) ->
		sortableCols = @remainedColumns
		comboxes = @query '[name=columnCombobox]' 

		if newVal and oldVal and newItemNeeded

			@sortableCols.forEach (col) ->
				textValue = col.text
				changeIndex = sortableCols.findIndex (column) ->
					if column.text is newVal 
						return column
				if textValue is newVal
					sortableCols.splice changeIndex, 1
				else if textValue is oldVal
					sortableCols.splice changeIndex, 0 , col
				
		else
			sortableCols.forEach (columnItem, index) -> if comboxes
				comboxes.forEach (comboItem) ->
					sortableCols.splice index, 1 if comboItem.getDisplayValue() is columnItem.text

		Ext.Array.forEach sortableCols, (col)->
			textDom = col.textEl.el.dom
			[textValueDom] = Ext.DomQuery.select 'div[name=titleValue]', textDom
			textValue = textValueDom?.innerText
			col.text = textValue if textValue
			return
		
		Ext.create 'Ext.data.Store',
			fields: ['text', 'dataIndex']
			data: sortableCols

	createSortingItem: (index, sortBy, value, scStore)->
		me = this

		sortItem = 
			xtype: 'fieldcontainer'
			cls: 'sortingitem'
			layout: 'hbox'
			columns: []
			margin: '0 0 15 0',
			width: 500
			listeners: 
				afterrender: ->
					sortpanel = me.down 'fieldcontainer' 
					if sortpanel.items.length is 1
						sortpanel.setHeight me.sortingItemHeight + me.sortingItemSpacing
					else
						if sortpanel.items.length > 5
							sortpanel.setHeight sortpanel.getHeight()
						else
							sortpanel.setHeight sortpanel.items.length*me.sortingItemHeight + sortpanel.items.length*me.sortingItemSpacing
			items: [
				fieldLabel: 'Sort' + me.buildIndexText index
				labelStyle: 'font-weight: normal;padding-bottom: 4px;'
				labelAlign: 'top'
				labelSeparator: ''
				xtype: 'combobox'
				name: 'columnCombobox'
				store: scStore
				queryMode: 'local'
				displayField: 'text'
				valueField: 'dataIndex'
				value: value
				emptyText: 'Select column'
				width: 260
				index: index
				oldValue: null
				overCls: 'fieldOverCls'
				listeners:
					beforeselect: (combobox) ->
						@oldValue = combobox.getDisplayValue()
	
					change: (combobox) ->
						me.handleSortingtItemSelecting combobox, combobox.getDisplayValue(), combobox.oldValue
			,
				xtype: 'radiogroup'
				margin: '30 0 0 25',
				name: 'sortValue-' + index
				index: index
				width: 200	
				items: [
					me.buildBoxItem sortBy, 'ASC', index
				,
					me.buildBoxItem sortBy, 'DESC', index
				]
			]
		su = Corefw.util.Startup
		if su.getThemeVersion is 2
			sortItem.setWidth 485
			sortItem.items[1].setWidth 185
		return sortItem

	buildBoxItem: (sortBy, iconType, index) ->
		me = this
		su = Corefw.util.Startup
		radioGroupName = "sv-#{index}"
		
		[sortype,name] = if iconType is 'ASC' then ['ASC', 'Ascending'] else ['DESC', 'Descending']

		labelstyle = 'position: relative;left:-2px;font-weight: normal'

		boxLabelTpl = "<span  style='" + labelstyle + "'>" + name + "</span>";
		boxLabel: boxLabelTpl
		name: radioGroupName
		inputValue: sortype
		checked: sortBy is sortype

	applyMultiSoring: (e) ->
		me = this
		sWindow = me.up 'window'
		rq = Corefw.util.Request
		props = sWindow.dataProps
		eventUrlObj = props?.events?[sWindow.sortEvent]
		return unless eventUrlObj
		url = rq.objsToUrl3 eventUrlObj.url
		callbackFunc = rq.processResponseObject
		postData = sWindow.generatePostData props
			
		triggerUipath = props.uipath
		rq.sendRequest5 url, callbackFunc, triggerUipath, postData, '', 'POST', null, null, null
		sWindow.close()

		return

	cancelWindow: (e) ->
		me = this
		sWindow = me.up 'window'
		sWindow.close()
		return

	clearSoringSelections: (e) ->
		me = this
		sWindow = me.up 'window'
		selectionArea = sWindow.child '#selectionArea'
		selectionArea.removeAll true
		sWindow.remainedColumns = Ext.clone sWindow.sortableCols
		scStore = sWindow.createSortingItemStore()
		selectionArea.add sWindow.createSortingItem 1, 'ASC', null, scStore
		return

	generatePostData: (props) ->
		me = this
		postData = {}
		postData.name = props.name
		postData.sortHeaders = sortHeaders = []
		props = me.grid.up('fieldcontainer').cache._myProperties
		originalSortHeaders = props.allContents
		newSortHeaders = me.query '[name=columnCombobox]'
		for header in newSortHeaders
			me.scStore = me.initAllStore()
			record = me.scStore.getAt me.getSelectedIndex header
			index = header.index + ''
			if record
				dataIndex = record.data.dataIndex
				sortValue = me.query("[name=sortValue-#{header.index}]")[0]?.getValue()
				header.sortBy = sortValue['sv-' + index]
				header = me.findSortHeaderByAttrValue originalSortHeaders, 'index', + dataIndex
				if header?
					header.sortBy = sortValue['sv-' + index]
					sortHeaders.push header
		return postData

	findSortHeaderByAttrValue: (sortHeaderumns, attr, value) ->
		for header in sortHeaderumns
			return header if header[attr] is value
		return

	# dynamically create a new sorting item when last item did changing.
	handleSortingtItemSelecting: (combobox, newVal, oldVal) ->
		sWindow = this
		selectionArea = sWindow.child '#selectionArea'
		newItemIndex = selectionArea.items.length + 1

		isCreateNewItem = sWindow.sortableCols.length > selectionArea.items.length
		scStore = sWindow.createSortingItemStore(newVal, oldVal, sWindow.hasEmptyValueCombo())
		if isCreateNewItem and !sWindow.hasEmptyValueCombo()
			selectionArea.add sWindow.createSortingItem newItemIndex, 'ASC', null, scStore

		sWindow.handleComboboxStore scStore
		return

	hasEmptyValueCombo: ->
		comboxes = @query '[name=columnCombobox]'
		comboxes.some (comboItem) ->
			flag = !comboItem.getValue()  or  comboItem.getValue() is null
			return flag
			
	buildIndexText: (index)->
		@indexTextMap[index] or index + 'th'

	getSelectedIndex: (combobox) ->
		value = combobox.getDisplayValue()
		store = @initAllStore()
		return store.find 'text', value

	handleComboboxStore: (store) ->
		comboxes = @query '[name=columnCombobox]'
		comboxes.forEach (comboItem) ->
			comboboxStore = comboItem.getStore()
			comboboxStore.destroy() if comboboxStore
			comboItem.bindStore store
		return store
	
	initAllStore: ->
		me = this
		Ext.Array.forEach me.sortableCols, (col) ->
			textDom = col.textEl.el.dom
			[textValueDom] = Ext.DomQuery.select 'div[name=titleValue]', textDom
			textValue = textValueDom?.innerText
			col.text = textValue if textValue
			return
		
		Ext.create 'Ext.data.Store',
			fields: ['text', 'dataIndex']
			data: me.sortableCols
	

