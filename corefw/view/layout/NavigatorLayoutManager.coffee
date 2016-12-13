Ext.define 'Corefw.view.layout.NavigatorLayoutManager',
	extend: 'Corefw.view.layout.LayoutManager'
	constructor: (config) ->
		@callParent arguments
		@defaultCfg =
			defaultColumns: 2
			layoutAsVboxItemsQty: 2
		defaultColumns = @defaultCfg.defaultColumns
		comp = config.comp
		comp.layout =
			type: 'table',
			columns: defaultColumns,
			tdAttrs:
				style: "width:" + (100 / defaultColumns) + "%;vertical-align:top;"
		meLayout = @
		addtionalListener =
			boxready: (me)->
				me.setAutoScroll true
				me.setBodyStyle
					"overflowX": "hidden"
					"overflowY": "auto"
				return
			resize: (me, width, height, oldWidth, oldHeight)->
				meLayout.ajustItmesSize();
				return
		comp.on addtionalListener
		return
	initLayout: ->
		comp = @comp
		contentDefs = comp.contentDefs
		comp.add contentDefs
		return
	removeAll: ->
		comp = @comp
		comp.removeAll()
		return
	ajustItmesSize: ()->
		cmp = @comp
		unitWidth = cmp.getWidth() / @defaultCfg.defaultColumns
		Ext.suspendLayouts()
		for item in cmp.items.items
			item.setWidth unitWidth * (item.colspan || 1)
		Ext.resumeLayouts(true)
		return
	add: (contentDef, index) ->
		defaultColumns = @defaultCfg.defaultColumns
		cmp = @comp
		itemsNum = cmp.items.getCount()
		if itemsNum >= @defaultCfg.layoutAsVboxItemsQty
			needColspan = (itemsNum + 1) % defaultColumns
			for item,index in cmp.items.items
				item.colspan = 1
		else
			needColspan = 1
		additionCfg =
			colspan: defaultColumns - needColspan + 1
		Ext.apply contentDef, additionCfg
		cmp.add contentDef
		@ajustItmesSize()
		return
	