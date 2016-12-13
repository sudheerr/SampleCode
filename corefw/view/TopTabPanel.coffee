# the very top panel in the application to which perpsectives are added
# also holds any global objects

Ext.define 'Corefw.view.TopTabPanel',
	extend: 'Ext.tab.Panel'
	xtype: 'toptabpanel'

	margin: 8
	plain: true

# toolbars placed above tabs
	topToolbars: {}
	style:
		border: 'none'
	bodyStyle:
		border: 'none'

#   appObj is the json response get from the call with the startupUrl in startup.json and with additional info
#   that used when init app. the listed property is supposed to be used
#   usage:1  it is mainly used for load the css configured in application level
#         2  get the passed theme config
	appObj:
		themeConfig: {}
		name: null
		cssbyPath: null

#   this property is from the config in startup.json , and set from Startup.js->prepareTopTabPanelConfig()
	isDeferRenderOn: false

	listeners:
		added: (me, container, pos, eOpts)->
			if Corefw.util.Startup.getThemeVersion() isnt 2
				me.dynamicLoadStyleSheet()
			me.deferRender()
			return

	initComponent: ->
		Ext.apply this, @prepareThemeConfig()
		@uipath = @cache._myProperties.uipath
		Corefw.customapp.Main.mainEntry 'topPanelInit', this
		@addListeners()
		@callParent arguments
		return

	deferRender: ->
		if not @isDeferRenderOn
			@addBreadcrumb()
			@addPerspectives()
		return

	addSeparatorLine: (perspective) ->
		if perspective
			tabbar = @tabBar
			breadcrumb = @breadcrumbObj
			toolBars = @query("coretoolbar")
			if perspective.toolbarObj and toolBars.length > 0
				toolbarPath = perspective.toolbarObj.uipath
				for toolBar in toolBars
					if toolBar.uipath is toolbarPath
						toolbar = toolBar
			progresstracker = perspective.progressIndicator

			hasTabbar = tabbar and !tabbar.isHidden()
			hasBreadcrumb = breadcrumb and !breadcrumb.isHidden()
			hasToolbar = toolbar and !toolbar.isHidden()
			hasTracker = progresstracker and !progresstracker.isHidden()
			# add separator lines for tab bar
			if hasTabbar and (hasBreadcrumb or hasToolbar or hasTracker)
				tabbar.addCls("bar-separator-bottom-line")

			# add separator lines for breadcrumb
			if hasBreadcrumb and hasTabbar
				breadcrumb.addCls("bar-separator-top-line")

			if hasBreadcrumb and (hasToolbar or hasTracker)
				breadcrumb.addCls("bar-separator-bottom-line")

			# add separator lines for tool bar
			if hasToolbar and (hasTabbar or hasBreadcrumb)
				toolbar.addCls("bar-separator-top-line")

			if hasToolbar and hasTracker
				toolbar.addCls("bar-separator-bottom-line")

			# remove separator lines if there is a tab bar between breadcrumb and tool bar
			if hasBreadcrumb and hasToolbar
				child = perspective.child(0)
				if child instanceof Ext.tab.Bar and !child.isHidden() and perspective.activeTab and perspective.activeTab.title
					breadcrumb.removeCls("bar-separator-bottom-line")
					toolbar.removeCls("bar-separator-top-line")

			# remove separator lines if there is a tab bar between tab bar and tool bar
			if hasTabbar and !hasBreadcrumb and hasToolbar
				child = perspective.child(0)
				if child instanceof Ext.tab.Bar and !child.isHidden() and perspective.activeTab and perspective.activeTab.title
					tabbar.removeCls("bar-separator-bottom-line")
					toolbar.removeCls("bar-separator-top-line")

			# add separator lines for progress tracker
			if hasTracker and (hasTabbar or hasBreadcrumb or hasToolbar)
				progresstracker.addCls("bar-separator-top-line")

			@doLayout()
		return

	prepareThemeConfig: ->
		return @appObj?.themeConfig || {}

	addListeners: ->
		@listeners = @listeners or {}
		additionalListeners =
			tabchange: @onRawTabChange
		# this is fired in onRawTabChange func
			tabchangeactual: @onRealTabChange

		Ext.apply @listeners, additionalListeners
		return

	dynamicLoadStyleSheet: ->
		[name, list, me ]=[@appObj.name, @appObj.cssbyPath, @]
		if list and list.length
			callback = ->
				me.doLayout()
				return

			for styleSheet, i in list
				styleSheetName = name + '-' + 'DynamicStyleSheet' + i
				Ext.util.CSS.swapStyleSheet styleSheetName, styleSheet
				@styleOnload styleSheetName, callback

		return

	styleOnload: (styleSheetName, callback) ->
		isLoaded = false
		link = Ext.DomQuery.selectNode '#' + styleSheetName

		readProp = ->
			try
			# chrome/safari
				if (link.sheet and link.sheet.cssRules.length > 0) or (link.styleSheet and link.styleSheet.cssText.length > 0) or (link.innerHTML and link.innerHTML.length > 0)
					isLoaded = true
			catch ex
			# FF not complete
				if ex.name and ex.name is 'NS_ERROR_DOM_SECURITY_ERR'
					isLoaded = true

			if isLoaded
				callback()
				Ext.TaskManager.destroy task

			return

		task = Ext.TaskManager.start
			run: readProp
			interval: 100
			repeat: 100
		return



	showTopToolbar: (toolbarPath) ->
		topToolbar = @topToolbars[toolbarPath]
		topToolbar.show() if topToolbar
		return

#TODO cy34944 why called in render ?
	addTopToolbar: (toolbar) ->
		@suspendLayout = true
		uip = Corefw.util.Uipath

		@hideAllTopToolbars()

		#need remove old toolbar firstly if it is exist
		toolbarPath = toolbar.uipath
		oldToolbarComp = uip.uipathToComponent toolbarPath
		@removeDocked oldToolbarComp if oldToolbarComp

		topToolbars = @topToolbars
		addedComponents = @addDocked toolbar, 1
		topToolbars[toolbarPath] = addedComponents[0] if addedComponents[0]
		@suspendLayout = false
		@doLayout()
		return

	hideAllTopToolbars: ->
		topToolbars = @topToolbars
		for uipath, topToolbar of topToolbars
			if topToolbar.coretype is 'toolbar'
				topToolbar.hide()
		return

	addBreadcrumb: ->
		maincache = Corefw.util.Cache.getMainCache()
		for key, oneCache of maincache
			if oneCache._myProperties?.widgetType is 'BREADCRUMB'
				@replaceBreadcrumb oneCache
		return

	replaceBreadcrumb: (breadcrumbCache) ->
		breadcrumbProps = breadcrumbCache._myProperties

		breadcrumbItems = @getDockedItems "toolbar[isBreadcrumb=true]"
		@removeDocked breadcrumbItem for index, breadcrumbItem of breadcrumbItems

		if breadcrumbProps.navs?._ar?.length
			if not breadcrumbProps?.isRemovedFromUI and breadcrumbProps?.visible
				breadcrumb = @prepareBreadcrumbConfig breadcrumbCache
				addedBreadcrumbComp = @addDocked breadcrumb, 0
				@breadcrumbObj = addedBreadcrumbComp[0] if addedBreadcrumbComp[0]
		if Corefw.util.Startup.getThemeVersion() is 2
			@addSeparatorLine @activeTab
		return

	prepareBreadcrumbConfig: (cache) ->
		breadcrumb =
			xtype: 'coretoolbar'
			ui: 'commandbar'
			dock: 'top'
			padding: if Corefw.util.Startup.getThemeVersion() is 2 then '3 10 3 10' else '2 10 2 10'
			border: if Corefw.util.Startup.getThemeVersion() is 2 then '0 0 0 0' else '1 0 1 0'
			defaultButtonUI: 'breadcrumbBtn'
			isBreadcrumb: true
			cache: cache
		return breadcrumb

# gets called with every tab change
# there are many tab changes that we're not interested in,
#		so this filters out the unwanted changes
#  TODO ys55821  too many noise event ,it is a waste of resource, can we  optimize?
#  TODO ys55821 callStack is  Request.processResponseObj->processRendering => TopTabpanel.replaceChild ->setReplaceActivePerspective
	onRawTabChange: (me, newCard, oldCard) ->
		oldName = oldCard?.cache?._myProperties?.uniqueKey
		newName = newCard?.cache?._myProperties?.uniqueKey

		cardChange = @cardChange
		if not cardChange
			cardChange = {}
			@cardChange = cardChange

		if newName and newName isnt cardChange.newName
			cardChange.oldName = cardChange.newName
			cardChange.newName = newName
			me.fireEvent 'tabchangeactual', me, newCard, oldCard
		return


# only gets called on "real" tab changes between perspectives
	onRealTabChange: (me, newCard, oldCard) ->
		@hideAllTopToolbars()
		toolbarPath = newCard.toolbarObj?.uipath
		@showTopToolbar toolbarPath if toolbarPath
		@breadcrumbObj.show() if @breadcrumbObj
		if Corefw.util.Startup.getThemeVersion() is 2
			@addSeparatorLine @activeTab
		return

# add perspectives to this top panel
	addPerspectives: ->
		#de = Corefw.util.Debug
		# if de.printOutRawResponse()
		# 	console.log "-----before @addOnePerspective  ->",maincache
		@addOnePerspective perspectiveCache for key, perspectiveCache of @cache when key isnt '_myProperties'
		@setInitActivePerspective()
		return

# add a single perspective to the top tab, as described by perspectiveCache
	addOnePerspective: (perspectiveCache, insertFlag, insertIndex) ->
		props = perspectiveCache._myProperties
		validation = @verifyPerspective props
		if not validation
			return

		perspectiveType = @getPerspectiveType props
		comp = @renderPerspective perspectiveType, perspectiveCache, insertFlag, insertIndex

		# after check the code, this was only used inside init perspectives #addPerspectives()
		if props.active
			@selectedActiveTab = comp
		return comp

	renderPerspective: (perspectiveType, cache, insertFlag, insertIndex) ->
		newPerspective =
			xtype: perspectiveType
			cache: cache

		if insertFlag and insertIndex >= 0
			comp = @insert insertIndex, newPerspective
		else
			comp = @add newPerspective
		return comp

	verifyPerspective: (props) ->
		if props.widgetType isnt 'PERSPECTIVE' or not props.visible
			return false
		return true

	getPerspectiveType: (props) ->
		layoutStyle = props.layout?.style
		if layoutStyle is 'WORKFLOW_SEQUENTIAL' or layoutStyle is 'WORKFLOW_NON_SEQUENTIAL'
			perspectiveType = 'coreperspectiveworkflow'
		else
			perspectiveType = 'coreperspective'
		return perspectiveType

	setInitActivePerspective: ->
		if typeof @activeTab is 'undefined' or @activeTab is null
			@setActiveTab @selectedActiveTab or 0
		return

	setReplaceActivePerspective: (props, currentActiveIndex, origTabNumber, disablePageSwitch) ->
		if not disablePageSwitch and (props.respIndex is 0 or currentActiveIndex is origTabNumber)
			if origTabNumber >= 0
				@setActiveTab origTabNumber
			else
				# activate the last thing
				len = @items.getCount()
				@setActiveTab len - 1
		return


# replace a perspective if it already exists,
# otherwise create a new perspective
# if returned perspective is marked as isRemovedFromUI, simply try to remove it
	replaceChild: (perspectiveCache, ev, disablePageSwitch) ->
		uip = Corefw.util.Uipath
		cache = Corefw.util.Cache
		props = perspectiveCache._myProperties
		cm = Corefw.util.Common

		uipath = props.uipath
		origTabNumber = uip.uipathToTabNumber uipath
		perspectiveToUpdate = uip.uipathToComponent uipath
		if @doLogicRemoval perspectiveToUpdate, props
			return

		if perspectiveToUpdate?.hasSubnavViews?()
			@remove perspectiveToUpdate
			newPerspective = @addOnePerspective perspectiveCache, true, origTabNumber
			@setActiveTab newPerspective
			return
		Ext.suspendLayouts()
		# get the current active tab index before all things
		currentActiveIndex = @getCurrentActiveIndex()
		if perspectiveToUpdate
			perspectiveToUpdate.updateUIData perspectiveCache
		else
			# render the new component
			perspectiveToUpdate = @addOnePerspective perspectiveCache, true, origTabNumber

		# activate the correct tab
		@setReplaceActivePerspective props, currentActiveIndex, origTabNumber, disablePageSwitch

		# disabePageSwitch is from push, which means if resposne is from push and not current active tab, hide its toptoolbar
		if disablePageSwitch and origTabNumber isnt currentActiveIndex
			@hidePerspectiveTopToolbar perspectiveToUpdate

		Ext.resumeLayouts true

		cache.updateMaincache perspectiveCache

		return

	hidePerspectiveTopToolbar: (perspective) ->
		toolbarPath = perspective?.toolbarObj?.uipath
		if not toolbarPath
			return
		topToolbar = @topToolbars[toolbarPath]
		topToolbar?.hide?()
		return



	doLogicRemoval: (comp, props) ->
		# if isRemovedFromUI, try to remove it and return
		if props.isRemovedFromUI or not props.visible
			@remove comp
			return true
		return false


	getCurrentActiveIndex: ->
		currentActiveTab = @getActiveTab()
		currentActiveIndex = @items.indexOf currentActiveTab
		return currentActiveIndex

	reEnableOnClose: (perspective) ->
		iv = Corefw.util.InternalVar
		# after removal, delete the "suppress close" variable
		delVariable = Ext.Function.createDelayed ->
			iv.deleteUipathProperty perspective.uipath, 'suppressClosing'
		, 1
		delVariable()
		return
