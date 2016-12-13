Ext.define 'Corefw.view.ComplexToolbar',
	extend: 'CitiRiskLibrary.view.CitiRiskFormPanel'
	mixins: ['Corefw.mixin.FieldContainer']
	xtype: 'corecomplextoolbar'

	layout: 'absolute'
	header: false
	style:
		border: 'none'
	bodyStyle:
		border: 'none'

	initComponent: ->
		props = @cache._myProperties
		@coretype = props.coretype
		@uipath = props.uipath
		layout = Corefw.view.layout.Layout
		@layoutManager = layout.create @
		@callParent arguments
		return

	updateUIData: (toolbarCache) ->
		Ext.suspendLayouts()
		@removeAll()
		@cache = toolbarCache
		@renderItemsWithTableLayout @layoutManager
		Corefw.util.Render.appendPendingLayout @
		Ext.resumeLayouts true
		return

	onRender: ->
		@callParent arguments
		@renderItemsWithTableLayout @layoutManager
		return

	renderItemsWithTableLayout: (layoutManager) ->
		me = @
		props = @cache._myProperties
		if not layoutManager.validate()
			return

		fields = me.getFormCacheFields()
		if fields and fields.length
			me.initializeConstants()
			fieldDefs = []
			me.contentDefs = fieldDefs

			for field in fields
				fieldProps = field?._myProperties
				if not fieldProps?.isRemovedFromUI and fieldProps?.visible
					fieldDef = me.genFieldDef field
					fieldDefs.push fieldDef if fieldDef

			layoutManager.initLayout()
			me.renderTooltips fieldDefs
			me.renderMessages()
			me.renderFieldMessages()
			me.deleteConstants()
			me.disableFormEvents = true
			Corefw.util.Data.displayFormData @, @cache
			me.disableFormEvents = false

		for nav in props.navs?._ar
			delete nav.isToolBar

		Corefw.util.Render.renderNavs props, @
		return

	onResize: ->
		if @layoutManager
			@layoutManager.resize @
		return