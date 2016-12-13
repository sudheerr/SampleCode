Ext.define 'Corefw.view.ProgressIndicator',
	extend: 'Ext.panel.Panel'
	xtype: 'coreprogressindicator'
	padding: '6 0 6 0'
	border: false
	cls: 'progressIndicator'

	listeners:
		add: (ct, comp, index) ->
			len = ct.visibleViews.length
			if comp.xtype isnt 'coreprogressseparator' and index < (2 * len - 2)
				ct.add
					xtype: 'coreprogressseparator'
					isSequential: ct.isSequential
		afterrender: (ct, eOpts) ->
			version = Corefw.util.Startup.getThemeVersion()
			if version is 2
				if ct.isSequential
					steps = @getSteps()
					i = 1
					for step in steps
						step.el.dom.children[0].innerHTML = i++
	layout:
		type: 'hbox'
		align: 'left'

	items: []

	initComponent: ->
		version = Corefw.util.Startup.getThemeVersion()
		if version is 2
			@padding = '10 0 0 10'
			if @isSequential
				@addCls "workflow-sequential"
			else
				@addCls "workflow-nonsequential"
		steps = @prepareSteps()
		@items = steps
		@callParent arguments
		me = @
		Ext.merge me.layout, me.initialConfig.layout
		# to show scrollers
		me.layout.align = 'left'
		me.layout.overflowHandler = new Ext.layout.container.boxOverflow.Scroller me.layout

	prepareSteps: (cache) ->
		items = []
		visibleViews = @visibleViews = []
		perspectiveCache = cache or @cache
		for key, oneCache of perspectiveCache
			if key isnt '_myProperties' and oneCache._myProperties.widgetType.toLowerCase() is 'view'
				viewProps = oneCache._myProperties
				if viewProps.visible and not viewProps.popup
					visibleViews.push viewProps

					navConfig =
						xtype: 'coreprogressstep'
						viewProps: viewProps

					items.push navConfig

		return items

	getSteps: ->
		return @query 'coreprogressstep'

	updateIndicator: (cache) ->
		isDirty = @checkCacheStructureDirty cache
		if isDirty
			@recreateSteps cache
		else
			@updateSteps cache
		return

	checkCacheStructureDirty: (cache) ->
		keys = Object.keys cache
		visibleViewKeys = keys.filter (key) ->
			props = cache[key]._myProperties
			return key isnt '_myProperties' and props.widgetType is 'VIEW' and props.visible and not props.popup
		currentKeys = @visibleViews.map (view) ->
			return view.name

		return visibleViewKeys.length isnt currentKeys.length or not visibleViewKeys.every (key, index) ->
				return key is currentKeys[index]

	recreateSteps: (cache) ->
		@suspendLayout = true
		@removeAll()
		steps = @prepareSteps cache
		@add steps
		@suspendLayout = false
		Corefw.util.Render.appendPendingLayout @
		@doLayout()

	updateSteps: (cache) ->
		steps = @getSteps()
		for step in steps
			name = step.viewProps.name
			newProps = cache[name]._myProperties
			newStatus = step.calStatus newProps
			if newStatus isnt step.status
				step.setStatus newStatus