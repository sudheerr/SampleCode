Ext.define 'Corefw.view.layout.BoxLayoutManager',
	extend: 'Corefw.view.layout.LayoutManager'
	# flex cache for layout item
	flexCaches: {}
	# UIPaths of splitters
	splitters: []
	constructor: (config) ->
		@callParent arguments

		comp = config.comp
		type = config.type
		if not (comp.layout instanceof Ext.layout.container.Container)
			comp.layout =
				type: type

		su = Corefw.util.Startup

		@extractLayoutAttrs()
		if @splitters.length > 0
			@splitterWrapper = Ext.create 'Corefw.view.layout.SplitterWrapper',
				compToSplit: comp
				layoutType: type
				splitters: @splitters
		if type is 'hbox' and not @splitters.length
			comp.layout.align = 'stretch'
		return

	removeAll: ->
		comp = @comp
		comp.removeAll()
		return

	initLayout: ->
		rdr = Corefw.util.Render
		su = Corefw.util.Startup
		comp = @comp
		contentDefs = comp.contentDefs
		layoutType = @type

		for contentDef, index in contentDefs
			@applyContentConfig contentDef, index

		contents = comp.add contentDefs
		return

	applyContentConfig: (contentDef, index) ->
		type = @type
		su = Corefw.util.Startup
		if type is 'vbox'
			contentDef.cls = if contentDef.cls then "#{contentDef.cls} vbox-item" else 'vbox-item'
			contentDef.width = '100%' if not contentDef.width
		else if type is 'hbox'
			contentDef.cls = if contentDef.cls then "#{contentDef.cls} hbox-item" else 'hbox-item'

		@applyFlex contentDef
		return

	beforeAddContent: (contentDef, index) ->
		@applyContentConfig contentDef, index

		splitterWrapper = @splitterWrapper
		if splitterWrapper
			splitterWrapper.applyWH contentDef
		return

	afterAddContent: (comp, contentDef) ->
		if not @splitterWrapper or @type is 'hbox'
			return
		prevCmp = comp.previousSibling?()
		nextCmp = comp.nextSibling?()
		if prevCmp?.xtype is 'splitter' or nextCmp?.xtype is 'splitter'
			@splitterWrapper.setVerticalScrollBar comp
		return

	beforeRemoveContent: (content) ->
		splitterWrapper = @splitterWrapper
		if not splitterWrapper
			return
		splitterWrapper.recordWH content
		return

	applyFlex: (contentDef) ->
		props = contentDef.cache._myProperties
		uipath = props.uipath
		flex = @flexCaches[uipath]
		if flex
			contentDef.flex = flex
			props.expanded = true if props.hasOwnProperty 'expanded'
			props.collapsible = false if props.hasOwnProperty 'collapsible'

		return

	addStatus: (statusDef) ->
		statusDef.width = '100%'
		@comp.insert 0, statusDef
		return

	# TODO add toolbar to top
	addToolbar: (toolbarDef) ->
		su = Corefw.util.Startup
		toolbarDef.width = '100%'
		if not (su.getThemeVersion() is 2 and toolbarDef.bottomContainer is true)
			toolbarDef.padding = 10
		@comp.add toolbarDef
		return

	# current flex info is at container.layout, to be removed after flex info is moved at content.layout
	extractLayoutAttrs: ->
		cache = @comp.cache
		layoutItems = cache?._myProperties?.layout?.items
		flexCaches = {}
		splitters = []
		for layoutItem, index in layoutItems
			itemName = layoutItem.name
			uipath = cache[itemName]?._myProperties?.uipath
			if not uipath
				continue
			if layoutItem.flex
				flexCaches[uipath] = layoutItem.flex
			if layoutItem.hasSplitter
				splitters.push uipath
		@flexCaches = flexCaches
		@splitters = splitters
		return