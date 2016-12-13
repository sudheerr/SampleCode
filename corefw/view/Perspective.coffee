Ext.define 'Corefw.view.Perspective',
	extend: 'Ext.tab.Panel'
	xtype: 'coreperspective'
	mixins: ['Corefw.mixin.Perspective']

	plain: true
	closable: false
	layout: 'fit'
	coretype: 'perspective'

	listeners:
		added: (me, container, pos, eOpts)->
			#   this method removed from the end of TopTabpanel->addOnePerspective() when perspective is add
			#   all its children should be added to
			me.addToolbarAndViews()
			return

	initComponent: ->
		su = Corefw.util.Startup
		#rdr = Corefw.util.Render
		evt = Corefw.util.Event
		cm = Corefw.util.Common
		#de = Corefw.util.Debug
		# get the cache object for this perspective
		cache = @cache
		props = cache._myProperties

		config =
			title: props.title
			uniqueKey: props.uniqueKey
			uipath: props.uipath
			border: 1
			hidden: not props.visible
			disabled: not props.enabled

		# hide header if title is blank
		if props.title
			errArray = props.messages?.ERROR
			config.title = props.title + if errArray and errArray.length then "<span style=\"color:#f00;\">(#{errArray.length})</span>" else ""
		else
			config.header = false

		if props.toolTip
			config.tabConfig =
				tooltip: props.toolTip + '\n<br>'

		if props.hideBorder
			config.border = false

		if props.closable
			config.closable = true

		evt.addEvents props, 'perspective', config
		evt.addHeartBeats props, 'perspective'

		cm.setThemeByGlobalVariable su.getApplicationName(), props.uniqueKey, config

		if not su.useClassicTheme()
			config.ui = 'tabnavigator'

		if su.getThemeVersion()
			config.ui = 'secondary-tabs-views'
			config.plain = false

		# save the results of the function call in a property
		if @hasSubnavViews()
			props.hasSubnavViews = true

		viewCaches = []
		for key, oneCache of cache
			if key isnt '_myProperties' and oneCache._myProperties.coretype is 'view' and oneCache._myProperties.visible
				viewCaches.push oneCache

		withoutTitleViewCaches = viewCaches.filter (cache)->
			return Ext.isEmpty(cache._myProperties.title)
		tabBarHidden = withoutTitleViewCaches.length > 0 and viewCaches.length is withoutTitleViewCaches.length

		config.tabBar =
			hidden: tabBarHidden
			style: 'margin-left: -2px;'

		if su.getThemeVersion() is 2
			config.tabBar.style = 'margin-left: 0px;'
			config.plugins =
				ptype: 'topTabPanelMenu'

		Ext.apply this, config

		# set the current pers to its tab as the name "coreperspective" for easily getting perspective from tab
		if @tab
			@tab.coreperspective = @
		Corefw.customapp.Main.mainEntry 'perspectiveInit', this
		@addListeners()
		@callParent arguments
		# if de.printOutRawResponse()
		# 	console.log 'PERSPECTIVE: ', props.uipath, cache
		return

	addListeners: ->
		@listeners = @listeners or {}
		additionalListeners =
			close: @onPerspectiveClose
			beforedestroy: @beforePerspectiveDestroy
			activate: @activatePerspective
			deactivate: @deactivatePerspective

		Ext.apply @listeners, additionalListeners

	onPerspectiveClose: ->
		iv = Corefw.util.InternalVar
		uipath = @cache._myProperties.uipath
		# enableUEvents is used somewhere else with different logic, so below part cannot be moved into
		# enable ONLOAD/ONREFRESH when popup is closed
		iv.deleteByUipathCascade uipath
		return

	beforePerspectiveDestroy: ->
		@onPerspectiveDestroy()
		return

	activatePerspective: ->
		@onPerspectiveActive()
		return

	deactivatePerspective: ->
		@onPerspectiveDeactive()
		return

	onRender: ->
		evt = Corefw.util.Event
		@callParent arguments
		if @perspectiveONLOADevent or @perspectiveONREFRESHevent
			evt.fireRenderEvent @
		return


	afterRender: ->
		@callParent arguments

		rdr = Corefw.util.Render
		evt = Corefw.util.Event
		evt.enableUEvent @uipath, 'ONCLOSE'

		me = this
		# if my title is blank, hide my tab
		if not me.title
			me.tab.hide()

			# I assume that if one tab is hidden, that the entire tab bar should be hidden
			tabpanel = me.up 'tabpanel'
			if tabpanel
				tabpanel.tabBar.hide()

		else
			# tab bar is visible
			# if I have error messages, adjust the title, and attach a toolTip
			rdr.loadErrors me.tab, me.cache?._myProperties

		# this is a hack
		# re-enable view ONLOAD after 10 seconds
		perspectiveReEnable = Ext.Function.createDelayed ->
			evt.enableUEvent me.uipath, 'ONCLOSE'
			return
		, 10000
		perspectiveReEnable()

		return


	getActiveStatus: ->
		parentComponent = Ext.ComponentQuery.query('toptabpanel')[0]
		return parentComponent?.getActiveTab() is this


# attach post data for each view in perspective
	generatePostData: ->
		props = @cache._myProperties

		viewPostArray = []
		postData =
			name: props.uniqueKey
			allContents: viewPostArray
			active: @getActiveStatus()

		compArray = @query '[coretype=view]'
		for viewComp in compArray
			if viewComp.cache._myProperties.popup
				continue
			viewPostData = viewComp.generatePostData()
			viewPostArray.push viewPostData

		toolbarComp = @down 'coretoolbar'
		if toolbarComp
			toolbarPostData = toolbarComp.generatePostData()
			postData.toolbar = toolbarPostData
		else
			toolbarComp = @down 'corecomplextoolbar'
			if toolbarComp
				toolbarPostData = toolbarComp.generatePostData()
				postData.toolbar = toolbarPostData

		return postData


# this function will be overridden in workflow perspective
	addToolbar: (toolbarCache) ->
		@addToolbarNew toolbarCache, null
		return

	addNavs: (props) ->
		rdr = Corefw.util.Render
		rdr.renderNavs props, this, null, @toolbarConfig
		return

	addToolbarAndViews: ->
		cache = @cache
		props = cache._myProperties
		# default tab to set
		@selectedActiveTab = 0
		hasToolbar = false

		for key, oneCache of cache
			oneProps = oneCache._myProperties
			if key isnt '_myProperties' and not oneProps?.isRemovedFromUI and oneProps?.visible
				if oneProps.coretype is 'view'
					# if not oneProps.suppressPrinting and de.printOutViews()
					# 	console.log " -> ", key, oneCache
					# else
					# 	oneProps.suppressPrinting = true

					if not oneProps.popup
						if oneProps.workflowType
							oneCache._myProperties.workflowType = true

						comp = @addOneView oneCache
						if oneProps.active
							@selectedActiveTab = comp
				else if oneProps.coretype is 'toolbar'
					@addToolbar oneCache
					hasToolbar = true

		if not hasToolbar
			@addNavs props

		if typeof @activeTab is 'undefined' or @activeTab is null
			@setActiveTab @selectedActiveTab

		@createOrUpdateProgressIndicator?()
		return