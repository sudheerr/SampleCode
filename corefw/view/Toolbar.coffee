Ext.define 'Corefw.view.Toolbar',
	extend: 'Ext.toolbar.Toolbar'
	mixins: ['Corefw.mixin.FieldContainer', 'Corefw.mixin.Refreshable']
	xtype: 'coretoolbar'
	isBreadcrumb: false

	initComponent: ->
		me = this
		props = @cache._myProperties
		@coretype = props.coretype
		@uipath = props.uipath
		@callParent arguments
		if Corefw.util.Startup.getThemeVersion() is 2
			me.height = 34
		return

	onRender: ->
		@callParent arguments
		@renderItemsWithDefaultLayout()
		return

	updateUIData: (toolbarCache) ->
		Ext.suspendLayouts()
		@removeAll()
		@cache = toolbarCache
		@renderItemsWithDefaultLayout()
		Ext.resumeLayouts true
		return

	renderItemsWithDefaultLayout: ->
		me = this
		props = @cache._myProperties
		Corefw.util.Render.renderNavs props, me

		fields = me.getFormCacheFields()
		if fields and fields.length
			me.initializeConstants()
			leftFieldDefs = []
			rightFieldDefs = []

			me.contentDefs = leftFieldDefs

			for field in fields
				fieldProps = field?._myProperties
				if not fieldProps?.isRemovedFromUI and fieldProps?.visible
					fieldDef = me.genFieldDef field
					if fieldDef and fieldProps.align is 'LEFT'
						leftFieldDefs.push fieldDef
					else if fieldDef and fieldProps.align is 'RIGHT'
						rightFieldDefs.push fieldDef
			if leftFieldDefs
				me.add leftFieldDefs
			if rightFieldDefs
				me.add '->'
				me.add rightFieldDefs

			me.renderTooltips leftFieldDefs
			me.renderTooltips rightFieldDefs
			me.renderFieldMessages()
			me.deleteConstants()
			me.disableFormEvents = true
			Corefw.util.Data.displayFormData me, me.cache
			me.disableFormEvents = false
		return

	onResize: ->
		if @layoutManager
			@layoutManager.resize this
		return

	setFieldLabel: (newObj, fieldProps) ->
		newObj.fieldLabel = ''
		if fieldProps.title
			newObj.emptyText = fieldProps.title
		return

	loadRecord: (record) ->
		#console.log 'loadRecord data', record.data
		for key, val of record.data
			fieldArr = @query '[name=' + key + ']'
			if fieldArr and fieldArr.length
				field = fieldArr[0]
				#console.log 'loadRecord key, val, field', key, val, field
				if field
					field.setValue val

		return this