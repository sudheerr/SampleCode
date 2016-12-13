Ext.define 'Corefw.view.crview.ViewStacked',
	#TODO should extend a container instead of Panel, but current ViewSubNav need Panel
	extend: 'Ext.panel.Panel'
	xtype: 'coreviewstacked'
	listeners:
		beforecollapse: ->
			me = this
			cef = @down 'coreelementform[collapsed=false]'
			if cef.title
				me.setTitle cef.title
			else
				me.setTitle '&nbsp;'

# renders a view with no specified layout
# renders as stacked panels, with the first panel expanded, and the rest collapsed
# the most common type of view
# the outside container is the actual view, and provides scrolling support,
#		but the inside panel is the visible part
	initComponent: ->
		uc = Corefw.util.Common
		su = Corefw.util.Startup
		cache = @cache
		props = cache._myProperties
		config =
			layout: 'auto'
			padding: '10 0'
			overflowY: 'auto'

			cls: 'viewstacked-cls'
		#TODO cy34944 why need an inner panel ?
			items: [
				xtype: 'panel'
				cls: 'viewstacked-panel-cls'
				ui: 'citirisk-view-innerpanel'
				layout:
					type: 'vbox'
					align: 'stretch'
				listeners:
					resize: @updateLayoutWhenResize
			]

		if @needFullHeight()
			config.layout = 'fit'

		if props.hasSubnav or props.subnavigator
			config.padding = 0
			config.layout = 'fit'

		uc.setThemeByGlobalVariable su.getStartupObj().application, 'view', config
		Ext.apply this, config
		# TODO re-factor on @initComponent & @configProps
		@configProps()
		@callParent arguments

		comp = @down 'panel'
		comp.cache = cache
		comp.layoutManager = Corefw.view.layout.Layout.create comp, cache?._myProperties
		@innerPanel = comp
		@layoutManager = comp.layoutManager
		@genElementDefs comp, cache
		return

	#move from View.coffee
	updateUIData: (viewCache) ->
		cm = Corefw.util.Common
		rd = Corefw.util.Render
		props = viewCache._myProperties
		me = this
		cm.updateCommon me, props

		oldTooltip = me.cache?._myProperties?.toolTip
		newTooltip = props.toolTip
		if oldTooltip isnt newTooltip
			me.tab?.setTooltip newTooltip

		innerPanel = me.innerPanel
		me.cache = viewCache
		#TODO update innerPanel cache?
		innerPanel.cache = viewCache

		me.genElementDefs innerPanel, viewCache
		me.updateMessages props
		if me.tab
			rd.loadErrors me.tab, props

		# if a view is not rendered, no need to update its children, since they are initialized at view#afterRender
		if not me.rendered
			return

		# onRefresh is deprecated, Remove onRefresh Event when we don't support
		evt = Corefw.util.Event
		if @viewONREFRESHevent
			evt.fireRenderEvent this

		for key, childCache of viewCache
			continue if key is '_myProperties'
			childProps = childCache._myProperties
			coretype = childProps?.coretype?.toLowerCase()
			switch coretype
				when 'element', 'compositeelement'
					me.updateChildren childCache
		me.updateVisual props
		return

#move from View.coffee
# each view needs to implement this
	replaceChild: (elementCache, ev, isAncestorUpdating) ->
		uip = Corefw.util.Uipath
		panel = @innerPanel
		if not panel
			return
		props = elementCache._myProperties
		name = props.name
		uipath = props.uipath
		elemComp = uip.uipathToComponent uipath

		if not elemComp and not props.visible
			return

		if not isAncestorUpdating
			Ext.suspendLayouts()
		@cache[name] = elementCache
		if elemComp
			props = elementCache._myProperties
			elemComp.updateUIData elementCache
		else
			elementDef = @genElementDef elementCache
			@layoutManager.add elementDef
		if not isAncestorUpdating
			Ext.resumeLayouts true
		return

	#move from view.coffee
	genElementDefs: (comp, viewCache) ->
		elementDefs = []
		for elemKey, elemCache of viewCache
			elemProps = elemCache?._myProperties
			if elemKey isnt '_myProperties' and not elemProps?.isRemovedFromUI and elemProps?.visible
				elementDef = @genElementDef elemCache
				elementDefs.push elementDef if elementDef
		comp.contentDefs = elementDefs
		return

#move from view.coffee
	genElementDef: (elementCache) ->
		props = elementCache._myProperties
		if not props
			return

		compTypeMap =
			FORM_BASED_ELEMENT: 'coreelementform'
			BAR_ELEMENT: 'coreelementbar'
			COMPOSITE_ELEMENT: 'corecompositeelement'

		widgetType = props.widgetType
		compType = compTypeMap[widgetType]

		if not compType
			return

		elementDef =
			xtype: compType
			cache: elementCache
		return elementDef


	updateChildren: (elementCache) ->
		@replaceChild elementCache, '', true
		return


	needFullHeight: ->
		layoutItems = @cache?._myProperties?.layout?.items
		for index, layoutItem of layoutItems
			if layoutItem.flex
				return true
		return false

# add all the elements for this view
	addElements: ->
		rdr = Corefw.util.Render

		# a view consists of the outside container, which is the "real" component,
		# and the inner panel, to which all the elements are added
		@layoutManager.initLayout()
		rdr.renderNavs @cache._myProperties, @innerPanel
		return

	updateLayoutWhenResize: (innerPanel) ->
		needUpdateLayout = (view) ->
			viewEl = view.el
			viewInnerPanelEl = view.innerPanel.el
			viewSize = viewEl.getSize true
			hasScrollBar = false

			if not (view.layout instanceof Ext.layout.container.Auto)
				return false

			if viewSize.height < viewInnerPanelEl.getHeight()
				hasScrollBar = true

			if (view.hasScrollbar and not hasScrollBar) or (not view.hasScrollBar and hasScrollBar)
				view.hasScrollbar = hasScrollBar
				return true

			return false

		view = innerPanel.up 'coreviewstacked'
		needLayout = needUpdateLayout view
		if needLayout
			elements = view.query 'coreelementform[collapsed=false]'
			Ext.each elements, (element) ->
				element.alreadyResize = false
				return
			delayedFn = Ext.Function.createDelayed ->
				view.updateLayout()
				return
			, 1
			delayedFn()
		return

	configProps: ->
		#rdr = Corefw.util.Render
		evt = Corefw.util.Event
		uip = Corefw.util.Uipath
		su = Corefw.util.Startup

		cache = @cache
		props = cache._myProperties

		parentCache = uip.uipathToParentCacheItem props.uipath
		isWorkflowView = parentCache?._myProperties?.layout?.style is 'WORKFLOW_SEQUENTIAL' or 'WORKFLOW_NON_SEQUENTIAL'

		config =
			uipath: props.uipath
			coretype: 'view'
			closable: false
			border: 1

		# new properties for panel
			hideCollapseTool: false
			header: false
			titleCollapse: false

		# corename: corename
			hidden: not props.visible
			disabled: not props.enabled

		# hide header if title is blank
		if props.title
			config.errArray = errArray = props.messages?.ERROR
			config.title = props.title + if not isWorkflowView and errArray and errArray.length then "<span style=\"color:#f00;\">(#{errArray.length})</span>" else ''
		else
			config.header = false
			config.tabBar =
				hidden: true

		if props.toolTip
			config.tabConfig =
				tooltip: props.toolTip + '\n<br>'

		if props.hideBorder
			config.border = false

		if props.closable
			config.closable = true

		evt.addEvents props, 'view', config

		@renderMessages props

		if su.getThemeVersion() is 2
			config.padding = 6
			config.padding = 0 if props.popup
			config.padding = '6 0 0 0' if props.hasSubnav or props.subnavigator
		Ext.apply this, config
		Corefw.customapp.Main.mainEntry 'viewInit', this
		@addListeners()
		return

	renderMessages: (props, isAncestorUpdating) ->
		props = props or @cache._myProperties
		if props.messages
			statusMsgs = @getStatusMessages props.messages
			if statusMsgs.length > 0
				statusView = Ext.create 'Corefw.view.StatusView',
					statusMsgs: statusMsgs
				items = @items
				if isAncestorUpdating
					items = items.items
				if @rendered
					@insert 0, statusView
				else
					items.unshift statusView
		return

#TODO let status view update messages
	updateMessages: (props) ->
		statusView = @down 'statusview'
		if statusView and statusView.ownerCt is this
			@remove statusView
		# if statusView
		# 	Ext.Array.remove @items.items, statusView
		# 	statusView.destroy()
		@renderMessages props, true
		return

	addListeners: ->
		@listeners = @listeners or {}
		additionalListeners =
			beforedestroy: @onViewDestroy
			beforerender: @onViewBeforeRender
		Ext.apply @listeners, additionalListeners
		return

	onViewDestroy: ->
		rdr = Corefw.util.Render
		rdr.destroyThisComponent this
		return

	onViewBeforeRender: ->
		if @up '[removingChild=true]'
			return false
		return true

#TODO merged to listeners?
	onRender: ->
		evt = Corefw.util.Event
		@callParent arguments
		if @viewONLOADevent or @viewONREFRESHevent
			evt.fireRenderEvent this
		return

#TODO merged to listeners?
	afterRender: ->
		@callParent arguments
		rdr = Corefw.util.Render
		evt = Corefw.util.Event

		# lazy adding on element, otherwise, @updateUIData need update its elements if not @rendered
		@addElements()

		me = this
		# need to push this to the end of callback queue, wait for everything else to render
		delayHeight = Ext.Function.createDelayed ->
			# if we're inside a perspective popup window,
			# and if the height of popup is greater than the height of its contents
			# reset popup height to fit the height of its contents
			# TODO remove this logic, same effect now can be achieved without setting popup height.
			popupWindow = me.up('coreperspectivewindow')
			if popupWindow and popupWindow.cache._myProperties.height
				popupHeight = popupWindow.getHeight()

				popupBodyTop = popupWindow.body.getStyle 'top'
				heightStyles = ['border-top-width', 'border-bottom-width', 'padding-top', 'padding-bottom']
				extraHeight = 0
				extraHeight += parseInt (popupWindow.body.getStyle heightStyle) for heightStyle in heightStyles
				extraHeight += parseInt (popupWindow.getEl().getStyle heightStyle) for heightStyle in heightStyles

				expectedHeight = parseInt(popupBodyTop) + me.getHeight() + extraHeight

				if expectedHeight < popupHeight
					popupWindow.setHeight expectedHeight
					popupWindow.doLayout()

			if not me.title
				if me.tab
					me.tab.hide()

				# I assume that if one tab is hidden, that the entire tab bar should be hidden
				tabpanel = me.up 'tabpanel'
				if tabpanel
					tabpanel.tabBar.hide()

			# if I have error messages, adjust the title, and attach a tooltip
			props = me.cache?._myProperties
			if props and not props.workflowType
				rdr.loadErrors me.tab, props

			return
		, 1
		delayHeight()

		# this is a hack
		# re-enable view ONLOAD after 10 seconds
		viewReEnable = Ext.Function.createDelayed ->
			evt.enableUEvent me.uipath, 'ONCLOSE'
			return
		, 10000
		viewReEnable()

		return

	getStatusMessages: (messageObj) ->
		statusMsgs = []
		typesOfMessages = ['ERROR', 'WARNING', 'SUCCESS', 'INFORMATION']

		for msgType in typesOfMessages
			msgArray = messageObj[msgType]
			if msgArray and msgArray.length
				for msg in msgArray
					newStatusMsg =
						level: msgType.toLowerCase()
						text: msg
					statusMsgs.push newStatusMsg
		return statusMsgs

	getActiveStatus: ->
		uip = Corefw.util.Uipath

		props = @cache._myProperties
		if props.popup
			return true

		parentComponent = uip.uipathToParentComponent @uipath
		if not parentComponent
			return true
		return parentComponent.getActiveTab() is this

# for each element, depending on the type of element,
# 	generate post data and add it to the array
	generatePostData: ->
		elementsArray = []
		postData =
			name: @cache._myProperties.name
			allContents: elementsArray
			active: @getActiveStatus()

		compArray = @query 'panel > coreelementform, panel > corecompositeelement'

		for elemComp in compArray
			elementPostData = elemComp.generatePostData()
			elementsArray.push elementPostData

		return postData

# TODO cy34944 looks weird.
	disableOncloseEvents: ->
		iv = Corefw.util.InternalVar
		iv.setByUipathProperty @uipath, 'suppressClosing', true
		return

	enableOncloseEvents: ->
		iv = Corefw.util.InternalVar
		iv.setByUipathProperty @uipath, 'suppressClosing', false
		return

# TODO cy34944 looks weird.
# need to check both the view AND the perspective
	isOncloseEventDisabled: ->
		iv = Corefw.util.InternalVar
		uip = Corefw.util.Uipath
		uipath = @uipath
		suppressClosing = iv.getByUipathProperty uipath, 'suppressClosing'

		if suppressClosing
			return true

		parentUipath = uip.uipathToParentUipath uipath
		suppressClosing = iv.getByUipathProperty parentUipath, 'suppressClosing'

		return suppressClosing

	hasUpload: ->
		forms = @query 'form'
		for form in forms
			if form.getForm().hasUpload()
				return true
		return false

	updateRelatedCache: (json) ->
		Ext.merge @cache._myProperties, json

	updateVisual: (json) ->
		@updateSelfVisual json
		# update related workflow tab visual if exist
		@updateWorkflowVisual json

	updateSelfVisual: (json) ->
		# partly done
		if json.enabled
			@enable()

	updateWorkflowVisual: (json) ->
		# temp use a query
		stepUipath = json.uipath + '/progressStep'
		step = Ext.ComponentQuery.query('[uipath=' + stepUipath + ']')[0]
		if step
			status = step.calStatus json
			if status isnt step.status
				step.setStatus status
		return