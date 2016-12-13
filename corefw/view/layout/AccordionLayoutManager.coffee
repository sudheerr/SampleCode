Ext.define 'Corefw.view.layout.AccordionLayoutManager',
	extend: 'Corefw.view.layout.LayoutManager'
	constructor: (config) ->
		@callParent arguments
		comp = config.comp
		comp.layout =
			type: 'accordion'
		return

	removeAll: ->
		comp = @comp
		comp.removeAll()
		return
	initLayout: ->
		comp = @comp
		contentDefs = comp.contentDefs
		for contentDef, index in contentDefs
			@applyContentConfig contentDef, index

		comp.add contentDefs
		return
	applyContentConfig: (contentDef, index) ->
		contentDef.autoScroll = true
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			contentDef.margin = "2 0 0 0"
			contentDef.margin = "0 0 0 0" if index is 0
		return
	beforeAddContent: (contentDef, index) ->
		@applyContentConfig contentDef, index
		return
# todo
	addStatus: (statusDef) ->
		return
# todo
	addToolbar: (toolbarDef) ->
		return