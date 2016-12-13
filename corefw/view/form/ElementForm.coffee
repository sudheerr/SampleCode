Ext.define 'Corefw.view.form.ElementForm',
	extend: 'CitiRiskLibrary.view.CitiRiskFormPanel'
	mixins: ['Corefw.mixin.FieldContainer', 'Corefw.mixin.Refreshable']
	xtype: 'coreelementform'

	formtype: 'elementform'
	layout: 'absolute'
	titleCollapse: true
	hideCollapseTool: true
	style:
		border: 'none'
	bodyStyle:
		border: 'none'
	defaults: {}
	suppressClosing: true
	initComponent: ->
		@elementInitialize()

		# put here for bar element overrides
		if @additionalConfig
			@additionalConfig()

		@addListeners()
		@callParent arguments
		@addCls 'elementform-cls'
		return

	elementInitialize: ->
		me = this
		iv = Corefw.util.InternalVar
		evt = Corefw.util.Event
		su = Corefw.util.Startup
		layout = Corefw.view.layout.Layout

		# get the cache object for this perspective
		cache = me.cache

		props = cache._myProperties
		uipath = props.uipath

		me.layoutManager = layout.create me

		config =
			frame: false
			closable: false
			coretype: 'element'
			autoScroll: false
			collapsible: props.collapsible
			border: 1
			uipath: uipath
			hidden: not props.visible
			disabled: not props.enabled
			secondTitle: props.secondTitle

		if su.getThemeVersion() is 2
			if @isChildWithHeader cache
				me.addCls 'element-child-with-header'
			for key, value of cache
				if key isnt '_myProperties'
					valueprops = value._myProperties
					if valueprops and valueprops.widgetType is 'TREE_NAVIGATION'
						config.bodyStyle =
							background: '#53565A'
							border: '0px'
						config.header =
							style: 'background: #686A6D; color: #FFFFFF'
						treesinelement = valueprops.treesinelement
						if treesinelement
							delete valueprops.treesinelement
						else
							allTopLevelNodes = valueprops.allTopLevelNodes
							for eachnode, val of allTopLevelNodes
								val.cls = 'topnodecls'


		elementCss = props.cssclass
		me.addCls elementCss if elementCss


		if props.hideBorder
			config.border = false
			config.style = {border: '0px'}

		if props.closable
			config.closable = true

		if props.toolTip
			config.header = config.header or {}
			titleEl =
				autoEl:
					'data-qtip': props.toolTip
			# using title is causing conflicts, it is not considering other tooltips for components on the toolbar.
			# Also we need to use Extjs tooltips instead of html title attribute.
			Ext.apply config.header, titleEl

		if props.toolbar
			config.header = config.header or {}
			headerCft =
				padding: '0 7 0 5'
				minHeight: 30
				listeners:
					click: (th, e, eOpts) ->
						# toggling the form only when the header is clicked.
						# ignoring clicks on buttons/textfield,..
						if e.target.tagName is 'DIV'
							form = th.up 'coreelementform'
							if form and form.collapsible
								form.toggleCollapse()
						return
			if not su.getThemeVersion()
				Ext.apply config.header, headerCft

		if not su.useClassicTheme()
			config.ui = 'citiriskfixedpanel'

		config.collapsed = not props.expanded

		# always expand blank titles, and hide the header
		# we put this here because we need this to override the previous lines of code,
		# which set the expanded/collapsed status
		if not props.title
			config.header = false
			config.collapsed = false
			me.addCls 'element-without-header'
		else
			config.title = props.title
			me.addCls 'element-with-header'

		if me.autoScroll
			config.autoScroll = true

		if me.flex
			delete config.autoScroll
			config.overflowY = 'auto'

		evt.addEvents props, 'element', config

		Ext.apply me, config
		return

	# render logic common to all elements
	elementMixinRender: ->
		evt = Corefw.util.Event
		if @elementONLOADevent or @elementONREFRESHevent
			evt.fireRenderEvent this
		return

	generatePostData: ->
		fcMixin = @mixins['Corefw.mixin.FieldContainer']
		postData = fcMixin.generatePostData.call this
		postData.expanded = not @collapsed
		return postData

	onRender: ->
		su = Corefw.util.Startup
		@disableFormEvents = true

		@callParent arguments
		@rendered = true
		if @xtype isnt 'coreelementbar'
			@layoutMain()
			@renderTooltips()
		@elementMixinRender()
		if @title and @collapsible
			if @collapsed
				@addCls 'panelcolltxtclr'
			else
				@addCls 'panelexptxtclr'

		return

	afterRender: ->
		@callParent arguments
		@restoreFieldFocus()

		#if @collapsible
		@addSecondTitle()
		delete @disableFormEvents

		evt = Corefw.util.Event
		evt.enableUEvent @uipath, 'ONCLOSE'
		
		return

	isOncloseEventDisabled: ->
		return @suppressClosing

	# adds an icon denoting the grid's collapsed state
	addSecondTitle: ->
		if @isBarElement
			return
		rdr = Corefw.util.Render
		rdr.addSecondTitle this
		return

	restoreFieldFocus: ->
		me = this
		iv = Corefw.util.InternalVar
		#bc = Corefw.util.Breadcrumb
		uip = Corefw.util.Uipath
		uipath = @uipath

		fieldUipath = iv.getByUipathProperty uipath, 'formfieldfocus'
		if fieldUipath
			fieldComp = uip.uipathToComponent fieldUipath
			if not fieldComp
				return
			else
				# do not restore the focus status if field has blur event.
				return if fieldComp.eventURLs?.ONBLUR

			delayFunc = Ext.Function.createDelayed ->
				if fieldComp.fieldONSELECTevent
					origSelectEvent = true
					delete fieldComp.fieldONSELECTevent
				if fieldComp.fieldONLOOKUPevent
					origLookupEvent = true
					fieldComp.isStop = true
					delete fieldComp.fieldONLOOKUPevent
				me.restoreFieldCursorPosition fieldComp
				if fieldComp.xtype isnt 'coregridpicker'
					fieldComp.focus()
				# delete fieldComp.suspendChangeEvents
				iv.deleteUipathProperty uipath, 'formfieldfocus'
				iv.deleteByNameProperty 'radiofocus'
				if origSelectEvent
					fieldComp.fieldONSELECTevent = true
				if origLookupEvent
					fieldComp.fieldONLOOKUPevent = true
					fieldComp.isStop = false
				return
			, 1
			delayFunc()
			console.log 'field focus component found: ', fieldUipath, fieldComp
		return


	restoreFieldCursorPosition: (field) ->
		iv = Corefw.util.InternalVar
		uipath = field.uipath
		cursPos = iv.getByUipathProperty uipath, 'fieldcursorposition'

		if not cursPos
			# even if cursor position is 0, no action needs to be taken
			# it's set at 0 by default
			return

		console.log 'restoring cursor position = ', cursPos

		dom = field.getEl()?.dom
		return unless dom
		node = Ext.dom.Query.selectNode 'input', dom
		if not node
			node = Ext.dom.Query.selectNode 'textarea', dom
			if not node
				return
		try
			node.selectionStart = cursPos
			node.selectionEnd = cursPos
		catch
			console.log 'failed to restore field cursor'
		return



	onResize: ->
		# alreadyResize to prevent infinite resize loop
		# collapsed is to do lazy resize
		me = this
		if me.alreadyResize or me.collapsed
			return

		me.alreadyResize = true
		me.callParent arguments
		me.layoutManager.resize()
		# delete this in 2 seconds
		myFunc = Ext.Function.createDelayed ->
			delete me.alreadyResize
			return
		, 1000
		myFunc()
		return

	addListeners: ->
		@listeners = @listeners or {}
		additionalListeners =
			beforeexpand: @onPanelExpand
			beforecollapse: @onPanelCollapse
			afterlayout: @afterPanelLayout
			close: @onElementClose
			beforedestroy: @beforeElementDestroy
			destroy: @afterPanelDestroy

		Ext.apply @listeners, additionalListeners
		return

	beforeElementDestroy: ->
		rdr = Corefw.util.Render
		rdr.destroyThisComponent this
		return

	onElementClose: ->
		@suppressClosing = false
		return

	afterPanelDestroy: ->
		@tooltipManager?.destroy?()
		delete tooltipManager
		return

	afterPanelLayout: ->
		if @resizeWhenVisible
			@layoutManager?.resize?()
			delete @resizeWhenVisible
		return

	onPanelExpand: (form) ->
		# TODO verify whether we still need below css
		form.removeCls 'panelcolltxtclr'
		form.addCls 'panelexptxtclr'

		if @.eventURLs['ONELEMENTEXPAND']
			rq = Corefw.util.Request
			uipath = @.uipath
			url = rq.objsToUrl3 @.eventURLs['ONELEMENTEXPAND']
			postData = @.generatePostData()
			postData.expanded = true
			method = 'POST'
			rq.sendRequest5 url, rq.processResponseObject, @.uipath, postData
		return

	onPanelCollapse: (form) ->
		# TODO verify whether we still need below css?
		form.removeCls 'panelexptxtclr'
		form.addCls 'panelcolltxtclr'
		return

	# determine whether the element content component has header
	isChildWithHeader: (cache) ->
		for contentKey, contentCache of cache
			if contentKey isnt '_myProperties'
				contentProps = contentCache._myProperties
				switch contentProps?.widgetType
					when 'FIELD', 'FIELDSET'
						return false
					when 'MIXED_GRID'
						if not Ext.isEmpty contentProps.title
							hasTitleBar = true
					when 'OBJECT_GRID', 'RCGRID', 'TREE_GRID', 'HIERARCHY_OBJECT_GRID', 'PIVOTGRID', 'TREE', 'DYNAMIC_TREE'
						if contentProps.showTitleBar is true
							hasTitleBar = true
		return hasTitleBar

	###
    	@override
    	@param {boolean} isInitLoading if true, before loading record, will suspend all change event and reset original value of the form fields
	###
	loadRecord: (record, isInitLoading = false) ->
		form = @getForm()
		if isInitLoading
			form.trackResetOnLoad = true
			form.getFields().items.forEach (field) ->
				field.suspendCheckChange++
				return

		@callParent arguments

		if isInitLoading
			form.trackResetOnLoad = false
			form.getFields().items.forEach (field) ->
				field.lastValue = field.getValue()
				field.suspendCheckChange--
				return
		return