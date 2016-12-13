# contains functions common to all Perspectives
# this file is needed because a perspective can be a popup window,
#		requiring two different base classes

Ext.define 'Corefw.mixin.Perspective',

	# TODO: create ViewBorder class, then create that class with the "real" view inside
	# do it in the function below
	# before this, figure out if subnavigator exists in the perspective or not

	statics:
	# this is called by subnavigator view creation, which is why it's put here
		configView: do ->
			layoutDef =
				HBOX:
					layout:
						type: 'hbox'
						align: 'stretch'
				VBOX:
					layout:
						type: 'vbox'
						align: 'stretch'
			getLayoutType = (viewCache) ->
				layoutProps = viewCache?._myProperties?.layout
				layoutType = layoutProps?.type
				layoutDefObj = layoutDef[layoutType]

				if not layoutType or layoutType is 'DEFAULT' or not layoutDefObj or (layoutType is 'VBOX' and not layoutProps.hasFlex)
					return 'stacked'
				return
			_configView = (viewCache) ->
				layoutType = getLayoutType viewCache

				switch layoutType
					when 'stacked'
						viewXtype = 'coreviewstacked'
				newview =
					xtype: viewXtype
					cache: viewCache

				if viewCache?._myProperties?.type is 'PIVOT'
					newview.xtype = 'coreviewpivot'
					newview.title = viewCache._myProperties.title
					newview.closable = viewCache._myProperties.closable

				return newview
			return _configView


# TODO: in view's initComponent, set the title and tab bar configs one level up

	addOneView: (viewCache, insertFlag, insertIndex) ->
		props = viewCache._myProperties
		if props.subnavigator
			# don't render right now if it's a subnavigator view
			return

		newview = Corefw.mixin.Perspective.configView viewCache

		if @cache._myProperties.hasSubnavViews
			childview = newview
			childview.cache._myProperties.hasSubnav = true

			newview =
				xtype: 'coreviewsubnav'
				cache: viewCache
				title: props.title
				items: [
					xtype: childview.xtype
					cache: childview.cache
					region: 'center'
				]

		# if any view titles are blank, hide the tab bar
		if not props.title
			@hideTabBar = true

		if insertFlag and insertIndex >= 0
			comp = @insert insertIndex, newview
		else
			comp = @add newview

		# set the current view to its tab as the name "coreview" for easily getting view from tab
		if comp.tab
			comp.tab.coreview = comp
		return comp



	addToolbarNew: (toolbarCache, attachTop) ->
		rdr = Corefw.util.Render
		props = toolbarCache._myProperties
		su = Corefw.util.Startup

		toolbar = {}
		if props.layout?.type is 'TABLE'
			toolbar = @configComplexToolbar toolbarCache
		else
			toolbar = @configSimpleToolbar toolbarCache

		if su.getThemeVersion()
			toolbar.border = '0px'

		toolbar.uipath = props.uipath
		if props.cssClass
			toolbar.cls = props.cssClass

		@toolbarObj = toolbar
		if attachTop
			rdr.attachToolbarToTopTabpanel @
		else
			@up()?.hideAllTopToolbars?()
			dockedTopItems = @getDockedItems "toolbar[dock='top'],panel[dock='top']"
			@removeDocked dockedTopItem for index, dockedTopItem of dockedTopItems
			@addDocked toolbar

		return toolbar

	configComplexToolbar: (toolbarCache) ->
		toolbar =
			xtype: 'corecomplextoolbar'
			dock: 'top'
			padding: 3
			border: '1 1 1 1'
			cache: toolbarCache
		return toolbar

	configSimpleToolbar: (toolbarCache) ->
		toolbar =
			xtype: 'coretoolbar'
			ui: 'commandbar'
			dock: 'top'
			padding: '3px 3px 3px 10px'
			border: '1 1 1 1'
			cache: toolbarCache
		return toolbar

	updateUIData: (perspectiveCache) ->
		cm = Corefw.util.Common
		rd = Corefw.util.Render
		props = perspectiveCache._myProperties
		cm.updateCommon @, props

		oldTooltip = @cache?._myProperties?.toolTip
		newTooltip = props.toolTip
		if oldTooltip isnt newTooltip
			@tab?.setTooltip newTooltip

		if @tab
			rd.loadErrors @tab, props

		isTabBarHidden = false

		@cache = perspectiveCache

		previousActiveTab = @selectedActiveTab

		# onRefresh is deprecated, Remove onRefresh Event when we don't support
		evt = Corefw.util.Event
		if @perspectiveONREFRESHevent and @rendered
			evt.fireRenderEvent @

		# Even if a perspective is not rendered,
		# we still need to iterate all its views/toolbars to do update,
		# since views/toolbar are added when perspective is added to toptabpanel.
		# TODO
		# we may consider add views/toolbar after perspective is rendered, in order not to update those un-rendered views.

		for key, contentCache of perspectiveCache
			continue if key is "_myProperties"
			contentProps = contentCache._myProperties
			coretype = contentProps?.coretype?.toLowerCase()
			switch coretype
				when 'view'
				# support subnavigator, might re-factor subnavigator to Border layout
					if contentProps.subnavigator
						props.hasSubnavViews = true

					# Don't render its popup when a perspective is returned
					if not contentProps.popup
						@updateChild contentCache
						if contentProps.visible and not contentProps.title
							isTabBarHidden = true
				when 'toolbar'
					@updateToolbar contentCache

		@createOrUpdateProgressIndicator?()

		if not (@ instanceof Corefw.view.PerspectiveWorkflow) and @tabBar?.isHidden?() and not isTabBarHidden
			@tabBar.setVisible true

		currentActiveTab = @selectedActiveTab
		if previousActiveTab isnt currentActiveTab
			@setActiveTab currentActiveTab
		return

# updateToolbar: (toolbarCache) ->
# 	@replaceToolbar toolbarCache, true
# 	return

	updateToolbar: (toolbarCache) ->
		toolbarObj = @toolbarObj
		if not toolbarObj
			@addToolbar toolbarCache
		else
			toolbarUIPath = toolbarObj.uipath
			toolbarComp = @down "[uipath=#{toolbarUIPath}]"
			if not toolbarComp
				toptabPanel = @up 'toptabpanel'
				toolbarComp = toptabPanel.topToolbars?[toolbarUIPath]
			# dynamic toolbar?
			toolbarComp.updateUIData toolbarCache
			@toolbarObj.cache = toolbarCache
		toptabPanel = @up 'toptabpanel'
		if toptabPanel?.activeTab is @
			@startTimerAndHeartBeats()
		return

	updateChild: (viewCache) ->
		@replaceChild viewCache, '', '', true
		return

	replaceChild: (viewCache, ev, disablePageSwitch, isAncestorUpdating) ->
		#cm = Corefw.util.Common
		uip = Corefw.util.Uipath
		cm = Corefw.util.Common
		props = viewCache._myProperties
		name = props.name
		uipath = props.uipath
		me = this

		origTabNumber = uip.uipathToTabNumber uipath
		if origTabNumber is -1 and @cache[name]
			origTabNumber = @getViewOrderFromCache name

		@cache[name] = viewCache


		# when there is a popup view comes, just recreate the popupview.
		if props.popup
			@createPopupview viewCache, ev, props
			return

		# remove this component if it already exists
		viewComp = uip.uipathToComponent uipath

		if not isAncestorUpdating
			me.createOrUpdateProgressIndicator?()
			Ext.suspendLayouts()

		# if isRemovedFromUI, try to remove it and return
		if props.isRemovedFromUI or not props.visible
			if viewComp
				@removingChild = true
				@remove viewComp
				delete @removingChild
			Ext.resumeLayouts true if not isAncestorUpdating
			return

		if viewComp

			viewComp.disableOncloseEvents?()

			hasSubnav = viewComp?.cache?._myProperties?.hasSubnav
			if hasSubnav
				# component exists, and lives in a border layout
				borderParent = viewComp.up 'coreviewsubnav'
				if borderParent.contains viewComp
					borderParent.remove viewComp

				childview = Corefw.mixin.Perspective.configView viewCache
				childview.cache._myProperties.hasSubnav = true

				newview =
					xtype: childview.xtype
					cache: childview.cache
					region: 'center'
				borderParent.add newview
				Ext.resumeLayouts true if not isAncestorUpdating
				return
			viewComp.updateUIData viewCache
			if props.active
				@selectedActiveTab = viewComp

			if not viewComp.rendered
				if not props.popup and not disablePageSwitch and not hasSubnav and props.respIndex is 0
					# if (not disablePageSwitch or currentActiveIndex is origTabNumber) and not hasSubnav and (props.respIndex is 0 or currentActiveIndex is origTabNumber)
					uip.uipathActivateTab uipath
				if not isAncestorUpdating
					Ext.resumeLayouts true
				return


			delVariable = Ext.Function.createDelayed ->
				Corefw.util.InternalVar.deleteUipathProperty uipath, 'suppressClosing', 1
			delVariable()
		else
			viewComp = @addOneView viewCache, true, origTabNumber
			if props.active
				@selectedActiveTab = viewComp

		if not props.popup
			if not disablePageSwitch and not hasSubnav and props.respIndex is 0
				# if (not disablePageSwitch or currentActiveIndex is origTabNumber) and not hasSubnav and (props.respIndex is 0 or currentActiveIndex is origTabNumber)
				uip.uipathActivateTab uipath

		if not isAncestorUpdating
			Ext.resumeLayouts true

		return

	getViewOrderFromCache: (viewName2Find) ->
		viewOrder = -1
		pCache = @cache
		for viewName, viewProps of pCache
			if viewName isnt '_myProperties'
				viewOrder++
			if viewName is viewName2Find
				return viewOrder
		return -1


	createPopupview: (viewCache, ev, props) ->
		persUipath = props.uipath + 'PerspectiveWindow'

		config =
			cache: viewCache
			title: props.title.toUpperCase()
			uipath: persUipath
			coretype: 'perspective'

		if props.position is 'ON_MOUSE' and ev
			config.x = ev.getX()
			config.y = ev.getY()

		if props.height and (Ext.getBody().getHeight() < props.height)
			config.y = 0

		# assumption: only 1 popup window is active/visible at a time
		# all others should be closed

		# there is a bug here, when a popup is displaying on page and back end send back a new popup
		# it's gona break
		# reproduce: 1. a popup with ONLOAD and ONCLOSE on page 2. return it again in it's ONLOAD handler with
		# different name (setName)
		[win] = Ext.ComponentQuery.query "coreperspectivewindow[uipath=#{persUipath}]"
		if win
			view = win.down 'coreviewstacked'
			view and view.disableOncloseEvents()
			win.destroy()
		return if props.closed is true or props.visible is false
		perspectiveWindow = Ext.create 'Corefw.view.PerspectiveWindow', config
		perspectiveWindow.addOneView viewCache
		view = perspectiveWindow.down 'coreviewstacked'
		view and view.enableOncloseEvents()
		if props.position is 'SCREEN_CENTER' and config.y isnt 0
			perspectiveWindow.center()
		return

# do any of the views have a "subnavigator" property?
	hasSubnavViews: ->
		cache = @cache
		for key,view of cache
			if key is '_myProperties'
				continue
			if view._myProperties.subnavigator
				return true
		return false


# adds a fake view right after the current view
	addFakeViewAfter: (currView) ->
		currTabNumber = @items.indexOf currView

		# add a blank tab after this one, to prevent rendering of any "real" tabs after this one
		# return the current tab number
		fakeview =
			xtype: 'panel'
			tabConfig:
				hidden: true

		fakeObj = @insert currTabNumber, fakeview
		@setActiveTab fakeObj

		return fakeObj



	disableOncloseEvents: ->
		iv = Corefw.util.InternalVar
		iv.setByUipathProperty @uipath, 'suppressClosing', true
		return


	isOncloseEventDisabled: ->
		iv = Corefw.util.InternalVar
		suppressClosing = iv.getByUipathProperty @uipath, 'suppressClosing'
		return suppressClosing


	onPerspectiveDestroy: ->
		rdr = Corefw.util.Render
		rdr.destroyThisComponent this
		return

	startTimerAndHeartBeats: ->
		@updateTimerNavs()
		if window.isActive
			@startAllHeartBeats()
		return

	onPerspectiveActive: ->
		@startTimerAndHeartBeats()
		return

	updateTimerNavs: () ->
		allTimerNavs = @findAllTimerNavs()
		me = @
		rdr = Corefw.util.Render
		for timerNav in allTimerNavs
			if timerNav.interval > 0 and timerNav.events['ONTIMER']
				rdr.startTask timerNav, me
		return

# startAllTimerNavs: () ->
# 	allTimerNavs = @findAllTimerNavs()
# 	if allTimerNavs and allTimerNavs.length
# 		for timerNav in allTimerNavs
# 			if timerNav.interval > 0
# 				@startTask timerNav
# 	return

# startTask: (timerNav) ->
# 	me = @
# 	rq = Corefw.util.Request
# 	iv = Corefw.util.InternalVar
# 	runner = iv.getTaskByUipath timerNav.uipath
# 	if timerNav.started
# 		if not runner
# 			runner = iv.addTaskByUipath timerNav.uipath
# 		task = runner.tasks[0]
# 		# need run
# 		if not task
# 			startNavTimer = () ->
# 				postData = me.generatePostData()
# 				url = rq.objsToUrl3(timerNav.events['ONTIMER'].url)
# 				rq.sendRequest5 url, rq.processResponseObject, me.uipath, postData
# 				return

# 			task = runner.start
# 				run: startNavTimer
# 				interval: timerNav.interval
# 	else
# 		# need destroy
# 		if runner
# 			iv.deleteTaskByUipath timerNav.uipath

	startAllHeartBeats: () ->
		heartBeats = @cache._myProperties.heartBeats
		if heartBeats
			for hb in heartBeats
				@startHeartBeat hb
		return

	startHeartBeat: (heartBeat) ->
		iv = Corefw.util.InternalVar
		#rq = Corefw.util.Request
		props = @cache._myProperties

		runner = iv.getTaskByUipath props.uipath, heartBeat.name
		if not runner
			runner = iv.addTaskByUipath props.uipath, heartBeat.name

		task = runner.tasks[0]
		if not task
			if heartBeat.url and heartBeat.url isnt ""
				startHB = () ->
					Ext.Ajax.request
						url: heartBeat.url
					console.log "-------------- start heart beat!!!", heartBeat.name
					return

				task = runner.start
					run: startHB
					interval: heartBeat.interval
		else
			if task.stopped
				Ext.TaskManager.start task

	onPerspectiveDeactive: ->
		@stopAllHeartBeats()
		return

	findAllTimerNavs: ->
		allTimerNavs = []
		toolbarObj = @toolbarObj
		navsAr = toolbarObj?.cache?._myProperties?.navs?._ar

		if navsAr and navsAr.length
			for nav in navsAr
				if nav.started? and nav.interval?
					allTimerNavs.push nav
		return allTimerNavs


	stopAllHeartBeats: () ->
		heartBeats = @cache._myProperties.heartBeats
		if heartBeats
			for hb in heartBeats
				@stopHeartBeat hb
		return

	stopHeartBeat: (heartBeat) ->
		iv = Corefw.util.InternalVar
		runner = iv.getTaskByUipath @cache._myProperties.uipath, heartBeat.name
		if runner and runner.tasks.length and not runner.tasks[0].stopped
			Ext.TaskManager.stop runner.tasks[0]
			console.log "-------------STOP heart beat", heartBeat.name
		return