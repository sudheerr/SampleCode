# contains general rendering functions that don't belong in a specific category

Ext.define 'Corefw.util.Render',
	singleton: true

	pendingLayouts: []

	layoutVars:
		panelRowHeight: 48 # how much room to leave for each row in the panel
		panelHeaderHeight: 24 # how tall the panel header is
		fieldHeight: 40 # actual height of each field, not including white space
	#horizontal margin between fields
		fieldHMargin: 12
	#panel left margin
		leftMargin: 8
	#panel right margin
		rightMargin: 8
		topMargin: 0
	# TODO need below two magic number?
		totalWidthShrinkFudge: 20
		totalHeightExpandFudge: 20

	checkboxTypes: ['CHECKBOX', 'CHECKGROUP', 'RADIOGROUP']
	labelTypes: ['LABEL', 'LINK']
	fieldTypes: ['COMBOBOX', 'TEXTFIELD', 'NUMBERFIELD']
	navTypes: ['NAVIGATION']

	appendPendingLayout: (comp) ->
		Corefw.util.Render.pendingLayouts.push comp
		return

# flush all pending layouts resulting from widget.update
	flushLayouts: ->
		pendingLayouts = Corefw.util.Render.pendingLayouts
		Ext.suspendLayouts()
		for pendingLayout, id in pendingLayouts
			if pendingLayout.isVisible?(true)
				if pendingLayout.layoutManager
					pendingLayout.layoutManager.resize()
				else
					pendingLayout.doLayout()
			else
				pendingLayout.resizeWhenVisible = true
		Ext.resumeLayouts true
		Corefw.util.Render.pendingLayouts = []
		return

# given a view, will attach that perspective's toolbar to the top tab panel
	attachToolbarToTopTabpanel: (perspective) ->
		toppanel = Ext.ComponentQuery.query('toptabpanel')[0]
		toppanel?.addTopToolbar perspective.toolbarObj
		return

	prepareNavConfig: (nav, navType, parentComponent) ->
		su = Corefw.util.Startup
		evt = Corefw.util.Event

		newNavObj =
			cache:
				_myProperties: nav
			xtype: 'button'
			scale: 'small'
			margin: '3 10 3 10'
			uipath: nav.uipath
			coretype: 'nav'
			name: nav.name
			disabled: not nav.enabled
			formBind: nav.onValidationCheck
		if su.getThemeVersion() is 2
			newNavObj.margin = '0 4 0 4'
		if nav.title
			newNavObj.text = nav.title
		else
			newNavObj.text = ' '

		# add toolTip if it exists
		if nav.toolTip
			newNavObj.tooltip = nav.toolTip + '\n<br>'

		if not su.useClassicTheme() and nav.navigationType isnt 'TOOLBAR' and not nav.isToolBar
			# look for the "style" property
			if nav.style and nav.style isnt 'PRIMARY'
				newNavObj.ui = "#{nav.style.toLowerCase()}button"
			else
				newNavObj.ui = 'primarybutton'

		if nav.cssClass
			newNavObj.cls = nav.cssClass

		if nav.style
			if nav.style isnt 'PRIMARY' and nav.style isnt 'SECONDARY'
				if newNavObj.text.trim()
					newNavObj.cls = ''
					newNavObj.ui = 'primarybutton'
					newNavObj.text = '&nbsp;&nbsp;&nbsp;' + newNavObj.text
					newNavObj.iconCls = 'hasIcon icon icon-' + Corefw.util.Cache.cssclassToIcon[nav.style]
				else if navType isnt 'ribbon'
					newNavObj.cls = 'icon icon-' + Corefw.util.Cache.cssclassToIcon[nav.style]

			if nav.cssClass
				newNavObj.iconCls = 'icon icon-' + Corefw.util.Cache.cssclassToIcon[nav.cssClass]


		evt.addEvents nav, 'nav', newNavObj

		menu = nav.menu
		if menu
			newNavObj.coretype = 'navmenubutton'
			# activate event is for LER navigation right click menu feature
			activateEvent = menu.activateEvent
			if activateEvent
				newNavObj.activateEvent = activateEvent

		if nav.started? and nav.interval?
			# Timer Navigation
			newNavObj.started = nav.started
			newNavObj.interval = nav.interval
			newNavObj.hidden = true

		addlConfig = @getAddlConfigByType[navType](nav)
		Ext.apply newNavObj, addlConfig
		return newNavObj

# can this be implemented at backend?
	getNavType: (nav, parentComponent) ->
		if nav.coordinate and (parentComponent?.coretype is 'element' or parentComponent.xtype is 'corefieldset' or (parentComponent?.coretype is 'toolbar' and parentComponent?.layoutManager))
			navType = 'absolute'
		else if nav.type is 'TOOLBAR' or nav.navigationType is 'TOOLBAR' or nav.isToolBar
			navType = 'ribbon'
		else
			navType = 'bottom'
		return navType

	getAddlConfigByType:
		absolute: (nav) ->
			su = Corefw.util.Startup
			if su.getThemeVersion() is 2
				buttonHeight = 28
			else
				buttonHeight = 22
			addlConfig =
				height: buttonHeight
				buttonHeight: buttonHeight
				border: false
				padding: '0 0 0 0'
				margin: ''
			# use componentCls instead of cls since cls has been used for icon style
				componentCls: 'cv-form-abs-btn'
			if su.getThemeVersion() is 2
				if nav.style isnt 'PRIMARY' and nav.style isnt 'SECONDARY'
					addlConfig.margin = '10 0 0 0'

			return addlConfig
		ribbon: (nav) ->
			su = Corefw.util.Startup
			addlConfig =
				height: 28
				minWidth: 37
				border: false
				padding: '0 0 0 0'
				margin: ''
				iconAlign: 'left'
				isToolBar: true
				align: nav.align

			if su.getThemeVersion() is 2
				addlConfig.minWidth = 18
				addlConfig.margin = '0 2 0 0'
				delete addlConfig.padding
				delete addlConfig.height

			if nav.style
				iconCls = Corefw.util.Cache.cssclassToIcon[nav.style]
				if su.getThemeVersion() is 2
					addlConfig.iconCls = "hasIcon icon icon-#{iconCls}" if iconCls
				else if nav.style not in ['PRIMARY', 'SECONDARY']
					addlConfig.iconCls = nav.style
			return addlConfig
		bottom: ->
			return

	prepareNavItems: (nav, parentComponent, navItems, customizeConfig) ->
		su = Corefw.util.Startup
		absoluteItems = navItems.absoluteItems
		ribbonItems = navItems.ribbonItems
		bottomItems = navItems.bottomItems

		navType = @getNavType nav, parentComponent
		navConfig = @prepareNavConfig nav, navType, parentComponent
		layoutManager = parentComponent.layoutManager
		# option #1
		if navType is 'absolute'
			absoluteItems.push navConfig

			# option #2
		else if navType is 'ribbon'
			Ext.apply navConfig, customizeConfig

			if nav.align is 'RIGHT' and ribbonItems.indexOf('->') is -1
				ribbonItems.push '->'

			ribbonItems.push navConfig

			if parentComponent.isBreadcrumb
				navConfig.text = nav.label
				if su.getThemeVersion() is 2
					ribbonItems.push
						xtype: 'label'
						style: 'width:21px; top:1px !important; padding:5px 0;'
						html: '<i style="margin-left:8px; color:#53565A;" class="icon icon-next"></i>'
				else
					ribbonItems.push '>'


			# option #3
		else
			bottomItems.push navConfig
		return

# parentComponent is the component that owns this toolbar
# if attachTop=TRUE, then this is a view's toolbar,
#		and we attach this toolbar to the top level tabpanel
	renderNavs: (objProperties, parentComponent, attachTop, customizeConfig, navAlign) ->
		navs = objProperties.navs
		evt = Corefw.util.Event
		if not navs
			return

		navArray = navs._ar

		if not navArray or not navArray.length
			return

		navItems =
			absoluteItems: []
			bottomItems: []
			ribbonItems: []
		timerNavs = []


		for nav in navArray
			if nav.isRemovedFromUI or not nav.visible
				continue

			if nav.started? and nav.interval?
				config = {}
				evt.addEvents nav, 'nav', config
				Ext.apply nav, config
				timerNavs.push nav
				continue


			# at this point, there are 3 places where this button can go
			# 1. at a specific location as defined in the coordinates property
			# 2. ribbon bar
			# 3. at the bottom of the form, the footer

			@prepareNavItems nav, parentComponent, navItems, customizeConfig

		@renderNavItems parentComponent, navItems, objProperties, attachTop, navAlign

		for timerNav in timerNavs
			if timerNav.interval > 0 and timerNav.eventURLs['ONTIMER']
				@startTask timerNav, parentComponent
		return

	startTask: (timerNav, parentComponent) ->
		me = parentComponent
		rq = Corefw.util.Request
		iv = Corefw.util.InternalVar
		runner = iv.getTaskByUipath timerNav.uipath
		if timerNav.started
			if not runner
				runner = iv.addTaskByUipath timerNav.uipath
			task = runner.tasks[0]
			# need run
			if not task
				startNavTimer = () ->
					postData = me.generatePostData()
					url = rq.objsToUrl3(timerNav.events['ONTIMER'].url)
					rq.sendRequest5 url, rq.processResponseObject, me.uipath, postData
					return

				task = runner.start
					run: startNavTimer
					interval: timerNav.interval
					fireOnStart: false
			else
				#if the interval is updated
				if task.interval isnt timerNav.interval
					runner.stop task
					task.interval = timerNav.interval
					runner.start task
		else
			# need destroy
			if runner
				iv.deleteTaskByUipath timerNav.uipath
		return

	renderNavItems: (parentComponent, navItems, objProperties, attachTop, navAlign) ->
		absoluteItems = navItems.absoluteItems
		ribbonItems = navItems.ribbonItems
		bottomItems = navItems.bottomItems
		me = this

		if absoluteItems.length
			@renderAbsoluteItems parentComponent, absoluteItems

		if ribbonItems.length
			me.renderRibbonItems parentComponent, ribbonItems, objProperties, attachTop

		if bottomItems.length
			@renderBottomItems parentComponent, bottomItems, navAlign
		return

	renderAbsoluteItems: (parentComponent, absoluteItems) ->
		layoutManager = parentComponent.layoutManager
		if not layoutManager or not layoutManager.add
			return
		for item in absoluteItems
			layoutManager.add item
		return

	renderRibbonItems: (parentComponent, ribbonItems, objProperties, attachTop) ->
		su = Corefw.util.Startup
		if parentComponent.isBreadcrumb
			Ext.Array.erase ribbonItems, ribbonItems.length - 1, 1

		widgetType = objProperties.widgetType
		if widgetType is 'TOOLBAR' or widgetType is 'BREADCRUMB'
			parentComponent.removeAll true
			len = ribbonItems.length
			for ribbonItem, ind in ribbonItems
				if ind is len - 1 and widgetType is 'BREADCRUMB' then Ext.apply ribbonItem,
					cls: 'x-btn-lst'
				parentComponent.add ribbonItem

		else if widgetType is 'FORM_BASED_ELEMENT' or widgetType is 'COMPOSITE_ELEMENT'
			# partly done
			Ext.defer -> # render navs when container rendered completely
				return unless (parentComponent.header and parentComponent.header.el)
				if parentComponent?.header?.items?.items[0]?.flex
					delete parentComponent.header.items.items[0].flex
					delete parentComponent.header.items.items[0].flex
				toolbarUipath = objProperties.toolbar.uipath
				pHeader = parentComponent.header
				toolbar = pHeader.down 'toolbar'
				pHeader.remove toolbar if toolbar
				len = ribbonItems.length
				for ribbonItem, ind in ribbonItems
					#Only required for buttons without icons
					if not ribbonItem.iconCls
						ribbonItem.cls = 'toolbarBtn'
						ribbonItem.height = '24px'

					#Adding margin to the last button as it is squished to the end and
					#also getting messed up when scroll bar appears
					if ind is len - 1
						ribbonItem.margin = '0 10'

				toolbarObj =
					xtype: 'toolbar'
					cls: 'panel-tb'
					defaultButtonUI: 'toolbutton'
					flex: 1
					style:
						border: 0
						backgroundImage: 'none'
						backgroundColor: 'transparent'
					uipath: toolbarUipath
					cache:
						_myProperties:
							widgetType: 'TOOLBAR'
							uipath: toolbarUipath
					items: ribbonItems

				pHeader.add toolbarObj
				pHeader.padding = 0
			, 50

		else
			# support navs under perspective
			toolbarObj =
				xtype: 'toolbar'
				ui: 'commandbar'
				dock: 'top'
				padding: 3
				border: '1 1 1 1'
				items: ribbonItems

			parentComponent.toolbarObj = toolbarObj

			if attachTop
				@attachToolbarToTopTabpanel parentComponent
			else
				dockedTopItems = parentComponent.getDockedItems "toolbar[dock='top']"
				parentComponent.removeDocked dockedTopItem for index, dockedTopItem of dockedTopItems
				parentComponent.addDocked toolbarObj
		return

	renderBottomItems: (parentComponent, bottomItems, navAlign) ->
		layoutManager = parentComponent.layoutManager
		if not layoutManager or not layoutManager.addToolbar
			return

		switch navAlign
			when 'left'
				pack = 'start'
			when 'center'
				pack = 'center'
			when 'right'
				pack = 'end'
			else
				pack = 'end'

		toolbarObj =
			xtype: 'container'
			bottomContainer: true
			listeners:
				boxready: (me) ->
					@addCls "bottom-container"
					su = Corefw.util.Startup
					if su.getThemeVersion() is 2
						if me.getWidth() isnt 0
							containerWidth = me.getWidth()
						else
							containerWidth = parentComponent.getWidth()
						maxWidth = 0
						buttonGroup = me.query("button")
						for button in buttonGroup
							if button.getWidth() > maxWidth
								maxWidth = button.getWidth()
						# Buttons in the container margin left 4 and right 4
						# The button container has 10 left and right padding
						if containerWidth > buttonGroup.length * (maxWidth + 8) + 20
							for button in buttonGroup
								button.setWidth(maxWidth)
			layout:
				type: 'hbox'
				pack: pack
			items: bottomItems

		layoutManager.addToolbar toolbarObj
		return

# if error messages exist, adjust the title, and attach a toolTip
	loadErrors: (tab, props) ->
		if not props
			return

		errArray = props.messages?.ERROR
		if errArray and errArray.length and tab

			toolTipText = 'Errors:\n<br>'
			for error in errArray
				toolTipText += error + '\n<br>'

			tab.setTooltip toolTipText
		return

# TODO re-factor Render.addSecondTitle, it's adding title & second title both!
# Add tools & Add Second Title if existed
	addSecondTitle: (comp) ->
		su = Corefw.util.Startup
		if not comp.originalTitle
			if not comp.title
				comp.originalTitle = '&nbsp;'
			else
				comp.originalTitle = comp.title

		gridHeaderText = comp.originalTitle

		iconText = ''
		if comp.collapsible and not su.getThemeVersion()
			gridHeaderText = gridHeaderText.replace /&nbsp;/g, ''
			iconText = '&nbsp;&nbsp;&nbsp;'

		if comp.setTitle
			comp.setTitle iconText + gridHeaderText

		if comp.secondTitle and not comp.secondTitleCmp
			comp.secondTitleCmp = comp.header.add
				html: comp.secondTitle
				xtype: "component"
				cls: "element-second-title"
		return

	destroyThisComponent: (comp) ->
		rq = Corefw.util.Request

		eventName = 'ONCLOSE'
		uipath = comp.uipath

		Corefw.util.InternalVar.clearTimersForUipath(uipath)
		if not comp.eventURLs
			return

		serverUrl = comp.eventURLs[eventName]
		if not serverUrl
			return

		# first, see if ONCLOSE for this perspective is disabled
		# check to see if the function exists on this component
		if comp.isOncloseEventDisabled
			suppressClosing = comp.isOncloseEventDisabled()
			if suppressClosing
				return

		url = rq.objsToUrl3 serverUrl, comp.localUrl

		destroyReply = (respObj) ->

			# if we got a response object, then process it the normal way
			# at this point, the object pointed to by the breadcrumb is already gone
			if respObj
				rq.processResponseObject respObj, null, uipath

			return

		postData = comp.generatePostData()
		rq.sendRequest5 url, destroyReply, uipath, postData

		return



	getStyleRule: (ruleSelectorText, styleSheetHref)->
		doc = document
		styleSheets = doc.styleSheets

		for styleSheet in styleSheets
			if (styleSheetHref)
				if styleSheet.href.indexOf(styleSheetHref) is -1
					continue
			for rule in styleSheet.rules
				if rule.selectorText is ruleSelectorText
					return rule
		return null

	getImageDimensions: (imgStyleRule)->
		defaultSize = {width: 10, height: 30}
		if not imgStyleRule or not imgStyleRule.style or not imgStyleRule.style.backgroundImage
			return defaultSize
		img = new Image()
		img.src = imgStyleRule.style.backgroundImage.replace(/url\(|\)$|"/ig, '')
		return {width: img.width, height: img.height}

	isFormField: (type)->
		type in @checkboxTypes or type in @labelTypes or type in @fieldTypes or type in @navTypes