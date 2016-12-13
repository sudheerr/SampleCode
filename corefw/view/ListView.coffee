Ext.define 'Corefw.view.ListView',
	extend: 'Ext.grid.Panel'
	alias: 'widget.listview',
	displayField: "displayField"
	valueField: "valueField"
	sortableColumns: false

	scrollToMore: true
	scrollToMoreName: "viewMoreBtn"
	firstSeeItems: 5

	dataPrefix: false #{type:[predefined type 'checkbox','radio','deleteIcon'],onselectionchange:fn} or type, or array
	dataSuffix: false #{type:[predefined type 'checkbox','radio','deleteIcon'],onselectionchange:fn} or type,or array
	border: false
	viewListeners:
		afterrender: ()->
			@panel.createTooltip()
			return
		itemdblclick: (view, record, item, index, e)->
			@panel.fireEvent "itemdblclick", @panel, record, item, index
			return
		itemclick: (view, record, item, index, e)->
			ids = [].concat(record.prefixId).concat(record.suffixId)
			for id in ids
				ele = Ext.get id
				if e.target is ele.dom
					record.handler[id]?.onclick()
			@panel.fireEvent "itemclick", @panel, record, item, index
			return
		refresh: ()->
			@panel.handleSeeMoreBtn()
			@panel.fireEvent "refresh", @panel
			return
	dataDecorators:
		checkbox:
			getHtml: (id)->
				return "<input type='checkbox' style='margin:0px;' id=" + id + ">"
			onselectionchange: (element, selected, listview, record)->
				if selected
					fn = ()->
						element.dom.checked = true
						return
				else
					fn = ()->
						element.dom.checked = false
						return
				setTimeout fn, 100
				return
			onclick: ()->
				return
		radio:
			getHtml: (id, name)->
				return "<input type='radio' style='margin:0px;' name=" + name + " id=" + id + ">"
			onselectionchange: (element, selected, listview, record)->
				if selected
					fn = ()->
						element.dom.checked = true
						return
				else
					fn = ()->
						element.dom.checked = false
						return
				setTimeout fn, 100
				return
			onclick: ()->
				return
		icon:
			getHtml: (id)->
				return
			onselectionchange: (element, selected, listview, record)->
				return
			onclick: ()->
				return
	getNode: (record)->
		@view.getNode record
		return
	onItemSelect: (node)->
		@view.onItemSelect node
		return
	focusNode: (node)->
		@view.focusNode node
		return
	getTooltip: (record)->
		return record.get @displayField
	generateDataDecorator: (cfg)->
		if not cfg
			return {html: ""}
		id = Ext.id()
		if Ext.isString cfg
			decorator = @dataDecorators[cfg]
			if decorator
				id = cfg + "-" + id
				html = decorator.getHtml(id, "displayField")
				return {html: html, id: id, onselectionchange: decorator.onselectionchange, onclick: decorator.onclick}
		return {html: ""}

	generateDataPrefix: (record)->
		if Ext.isArray @dataPrefix
			cfgs = @dataPrefix
		else
			cfgs = [@dataPrefix]
		record.prefixId = []
		handler = {}
		html = []
		for cfg in  cfgs
			prefix = @generateDataDecorator(cfg)
			if prefix.id
				record.prefixId.push prefix.id
				handler[prefix.id] =
					onselectionchange: prefix.onselectionchange
					onclick: prefix.onclick
				html.push prefix.html
		record.handler = Ext.apply record.handler || {}, handler
		return html.join("")

	generateDataSuffix: (record)->
		if Ext.isArray @dataSuffix
			cfgs = @dataSuffix
		else
			cfgs = [@dataSuffix]
		record.suffixId = []
		handler = {}
		html = []
		for cfg in  cfgs
			suffix = @generateDataDecorator(cfg)
			if suffix.id
				record.suffixId.push suffix.id
				handler[suffix.id] =
					onselectionchange: suffix.onselectionchange
					onclick: suffix.onclick
				html.push suffix.html
		record.handler = Ext.apply record.handler || {}, handler
		return html.join("")

	columnRenderer: (value, metaData, record, rowIndex, colIndex, store, view)->
		prefix = "<div style='display:inline-block;height:100%;'>" + @generateDataPrefix(record) + "</div>"
		data = "<div style='display:inline-block;height:100%;padding-left:5px;'>" + @dataRenderer(value, metaData,
			record, rowIndex, colIndex, store, view) + "</div>"
		suffix = "<div style='display:inline-block;height:100%;float:right;'>" + @generateDataSuffix(record) + "</div>"
		return prefix + data + suffix

	dataRenderer: (value, metaData, record, rowIndex, colIndex, store, view)->
		return value

	seeMore: ()->
		@store.loadRecords @allDataStore.data.items
		return
	initComponent: ()->
		me = @
		#in configuration,store has higher priority then listData
		if not @store
			@store = Ext.create 'Ext.data.Store',
				fields: [@displayField, @valueField]
				data: @getStoreData(@listData) || []
		if @scrollToMore
			@fbar = @createViewMoreBar()
			if @addListeners
				me.on @addListeners
		@columns =
			style: "display:none"
			items: [
				dataIndex: @displayField
				renderer: @columnRenderer
				flex: 1
			]
		@callParent arguments
		#su = Corefw.util.Startup
		#rdr = Corefw.util.Render
		#evt = Corefw.util.Event
		#cm = Corefw.util.Common
		gridView = @getView()
		gridView.on @viewListeners
		#add selectionchange event to gridview wont work
		gridView.getSelectionModel().on "selectionchange", (selectionModel, selected)->
			allRecords = selectionModel.store.data.items
			for rec in allRecords
				if Ext.Array.contains selected, rec
					me.callDecoratorHandler rec, true, "selectionchange"
				else
					me.callDecoratorHandler rec, false, "selectionchange"
			return
		delete    @listData
		return
	handleSeeMoreBtn: ()->
		btn = @down '[name=' + @scrollToMoreName + ']'
		if @allDataStore?.getCount() > @firstSeeItems
			btn.up("toolbar").show()
		else
			btn.up("toolbar").hide()
		return
	createViewMoreBar: ()->
		me = @
		@on "show", ()->
			me.handleSeeMoreBtn()
			return
		ret = [
			type: 'button'
			text: 'click to see more'
			name: @scrollToMoreName
			handler: ()->
				me.seeMore()
				@up("toolbar").hide()
				return
		]
		return ret
	createTooltip: ()->
		gridView = @getView()
		me = @
		Ext.create 'Ext.tip.ToolTip',
			target: gridView.el
			delegate: gridView.itemSelector
			trackMouse: true
			renderTo: Ext.getBody()
			listeners:
				beforeshow: (tip)->
					tip.update me.getTooltip(gridView.getRecord(tip.triggerElement))
					return
		return
	callDecoratorHandler: (record, selected, type)->
		ids = [].concat(record.prefixId).concat(record.suffixId)
		for id in ids
			ele = Ext.get id
			if ele
				record.handler[id]["on" + type] ele, selected, @, record
		return

	getStoreData: (records, displayField, valueField)->
		if not records
			return null

		if not displayField
			displayField = @displayField
		if not valueField
			valueField = displayField

		if not (records instanceof Array)
			records = [records]
		data = []
		if records[0] instanceof Ext.data.Model
			for red in records
				tmp = {}
				tmp[displayField] = red.get(displayField)
				tmp[valueField] = red.get(valueField)
				data.push(tmp)
		else
			for red in records
				tmp = {}
				tmp[displayField] = red[dataField]
				tmp[valueField] = red[valueField]
				data.push(tmp)
		return data


	bindStore: (store)->
		if @scrollToMore
			@allDataStore = store
			recs = []
			for item,index in @allDataStore.data.items
				if(index is @firstSeeItems)
					break;
				recs.push item
			newStore = Ext.create 'Ext.data.Store',
				model: store.model
			newStore.loadRecords recs
			@callParent [newStore]
		else
			@callParent arguments
		return
	createPagingToolbar: ()->
		return