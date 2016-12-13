Ext.define 'Corefw.util.Startup',
	singleton: true

	startupJSON: 'startup.json'
	startupUrl: ''
# This can be turned off by passing false in startupObj
	enableSmartPolling: true
#Minimum time to stop polling after inactivity
	timeToStopPolling: 180000
	themeVersion: false

	launch: ->
		# prevent backspace on un-editable compoment.
		@preventBackspaceEventOnDocument()
		@createViewport()
		@createAjaxErrorHandling()
		@createApplication()
		@attachWindowEvent()
		return

# create viewport as a main container
	createViewport: ->
		viewport = Ext.create 'Ext.container.Viewport',
			layout: 'fit'
			overflowX: 'auto'
			minWidth: 1024
		return viewport

	getViewport: ->
		return Ext.ComponentQuery.query('viewport')[0]

	createApplication: ->
		# load the startup file, call processStartupJson() to process the returned object
		@requestStartupJson @processStartupJson
		return

# prepare a container for headBanner and topTabPanel
	prepareContainerConfig: ->
		containerConfig =
			xtype: 'container'
			autoScroll: true,
			layout:
				type: 'vbox'
				align: 'center'
		if Ext.getElementById("citi-application-header")
			containerConfig.margin = '34 0 0 0'
		return  containerConfig

# real content render target
	prepareTopTabPanelConfig: (appObj) ->
		su = Corefw.util.Startup

		# hide tabBar if there is only one visible perspective and its title is blank
		# avoid showing blank tab, then hiding it after rendered
		cache = Corefw.util.Cache
		maincache = cache.getMainCache()
		perspectiveCaches = []
		for key, perspectiveCache of maincache
			if key isnt '_myProperties' and perspectiveCache._myProperties.visible
				perspectiveCaches.push perspectiveCache

		withoutTitlePerspectiveCaches = perspectiveCaches.filter (cache)->
			return Ext.isEmpty(cache._myProperties.title)
		tabBarHidden = withoutTitlePerspectiveCaches.length > 0 and perspectiveCaches.length is withoutTitlePerspectiveCaches.length

		toptabpanelConfig =
			xtype: 'toptabpanel'
			cache: maincache
			width: '100%'
			flex: 1
			appObj: appObj
			isDeferRenderOn: su.getStartupObj().isDeferRender
			tabBar:
				hidden: tabBarHidden
				style: 'margin-left: -2px;'

		if su.getThemeVersion() is 2
			toptabpanelConfig.tabBar.style = 'margin-left: 0px;'
			toptabpanelConfig.plugins =
				ptype: 'topTabPanelMenu'
		return toptabpanelConfig

	requestStartupJson: (callback) ->
		rq = Corefw.util.Request
		rq.sendRequest5 @startupJSON, callback, null, null, 'Unable to find a valid startup file "startup.json", quitting...'
		return

# CALLBACK after "startup.json" file is retrieved from the server
# load the startup URL defined in file startup.json
	processStartupJson: (respObj) ->
		su = Corefw.util.Startup

		su.verifyStartupJson respObj
		su.replaceUrlRoot respObj
		su.startupUrl = su.getQueryUrl respObj
		su.setStartupObj respObj

		# enable externalCallback if available
		if respObj.externalCallback
			Corefw.util.Request.externalCallback = respObj.externalCallback
		su.requestApplicationJson respObj, su.processApplicationJson

		return

	verifyStartupJson: (respObj) ->
		if not respObj
			err = "No startup.json."
		else
			isEmpty = Ext.isEmpty
			err = ''
			if isEmpty respObj.startupUrl
				err += "\nNo startupURL set in startup.json."
			if isEmpty respObj.application
				err += "\nNo application set in startup.json."
			if isEmpty respObj.urlRoot
				err += "\nNo urlRoot set in startup.json"
		if err
			throw err


	replaceUrlRoot: (respObj) ->
		respObj.urlRoot = respObj.urlRoot.replace /;/, '?'
		return

	createContainers: (appObj) ->
		viewport = @getViewport()
		containerConfig = @prepareContainerConfig()
		toptabpanelConfig = @prepareTopTabPanelConfig appObj

		container = viewport.add containerConfig
		container.add toptabpanelConfig
		return

	requestApplicationJson: (respObj, callback) ->
		rq = Corefw.util.Request
		rq.sendRequest5 @startupUrl, callback, null, null, 'Startup URL contents were invalid'
		return

# CALLBACK after top level UI file is retrieved from the server
	processApplicationJson: (appObj) ->
		if not appObj
			return false

		su = Corefw.util.Startup
		#de = Corefw.util.Debug

		applicationContents = appObj.allContents
		if not Ext.isArray(applicationContents) or not applicationContents.length
			startupObj = su.getStartupObj()
			redirectUrl = startupObj.redirectUrl
			redirectUrl and window.location.href = redirectUrl
			return false

		su.setupGlobalConfig appObj
		su.parseApplicationJson appObj
		su.createContainers appObj

		#de.addDebugFunctions()
		title = appObj.title
		if title
			document.title = title
		console.log "processApplicationJson done"
		return true

#TODO cy34944 what this ?
	setupGlobalConfig: (appObj) ->
		ov = Corefw.util.Override
		startupObj = @getStartupObj()

		# apply overrides in common
		ov.columnComponentLayoutOverride()
		ov.columnGetMaxContentWidthOverride()
		ov.workaroundsForNewTheme()
		ov.xhrStatusOverride()
		ov.measureLabelErrorHeightOverride()
		ov.pieChartEnhancementOverride()
		ov.gridHeaderReordererPluginOverride()
		ov.rowModelOverride()
		themeConfig = @setThemeConfig()
		#start polling request if application enablePush
		if  appObj.enablePush
			# disables smartpolling for apps that pass false in startup obj.
			if Ext.isBoolean(startupObj.enableSmartPolling) and not startupObj.enableSmartPolling
				@enableSmartPolling = false
			else
				Corefw.getApplication().lastActivity = Date.now()
				# Tracks user actions.
				# lastActivity will be calculated to stop the polling when no user actions
				updateUserActionTime = ()->
					Corefw.getApplication().lastActivity = Date.now()
					return

				document.addEventListener 'mousedown', updateUserActionTime
				document.addEventListener 'keydown', updateUserActionTime

			@enablePush startupObj
		appObj.themeConfig = themeConfig


	setThemeConfig: ->
		cm = Corefw.util.Common
		startupObj = @getStartupObj()

		config =
			uipath: startupObj.application

		if startupObj.localMode or startupObj.coreTheme is 'classic'
			config.ui = 'default'
		else
			config.ui = 'tabnavigator'

		if @getThemeVersion()
			config.ui = 'primary-tabs'
			config.margin = 0

		cm.setThemeByGlobalVariable startupObj.application, 'topTabPanel', config
		config

# parse the top level response from the server
# all the JSON is parsed before anything is rendered
# the top-level cache is maintained in @maincache
	parseApplicationJson: (appObj) ->
		#de = Corefw.util.Debug
		# if de.printOutRawResponse()
		# 	console.log 'top level raw response from server: ', appObj
		ch = Corefw.util.Cache
		maincache = ch.parseJsonToCache appObj
		# if de.printOutRawResponse()
		# 	console.log "*** top level comp: ", maincache
		ch.setMainCache maincache
		rq = Corefw.util.Request
		rq.initializationSessionAboutToTimeoutTask()
		return

	enablePush: (startupObj) ->
		rq = Corefw.util.Request
		iv = Corefw.util.InternalVar
		pollingInterval = if startupObj.pollingInterval then startupObj.pollingInterval else 500
		this.timeToStopPolling = stopPollingOnNoActivity = if (Ext.isNumber startupObj.timeToStopPolling ) then startupObj.timeToStopPolling else this.timeToStopPolling

		pollingFn = ->
			if Corefw.util.Startup.enableSmartPolling and (Date.now() - Corefw.getApplication().lastActivity > stopPollingOnNoActivity)
				console.log 'polling stopped due to inactivity'
				Corefw.util.Startup.checkForUserAction()
				return

			pushUrl = startupObj.urlRoot.replace(/\?/, '/push')
			userid = iv.getByNameProperty "CoreApp", 'user'
			if userid
				pushUrl += "?sm_user=" + userid
			Ext.Ajax.request
				url: pushUrl
				timeout: 100 * 365 * 24 * 60 * 60 * 1000
				callback: (options, success, response)->
					if success
						rq.runSessionAboutToTimeOutTask()
					try
						obj = Ext.decode(response.responseText)
						if obj
							rq.processResponseObject obj, null, obj.uipath, null, true
					catch e
						console.log e
					finally
						Ext.Function.createDelayed((()->
							pollingFn()
							return
						), pollingInterval)()
					return
			return
		pollingFn()
		return

	checkForUserAction: ()->
		listenToUserActions = ()->
			document.removeEventListener 'mousedown', listenToUserActions
			document.removeEventListener 'keydown', listenToUserActions
			console.log 'polling restarted'
			Corefw.util.Startup.enablePush Corefw.util.Startup.getStartupObj()
			return
		#Attaching events to listen to user actions, this events will be removed once polling starts
		document.addEventListener 'mousedown', listenToUserActions
		document.addEventListener 'keydown', listenToUserActions

		return

# get correct url to access server
#TODO cy34944 startup parser, go to cache?
	getQueryUrl: (respObj) ->
		startupUrl = respObj['startupUrl']
		startupUrlArr = startupUrl.substr(startupUrl.indexOf(";") + 1).split("?")
		startupUrlHost = startupUrlArr[0]
		startupUrlParamJson = if startupUrlArr.length > 1 then Ext.Object.fromQueryString startupUrlArr[1] else {}
		localStorage = window.localStorage
		localUrl = window.location.search
		iv = Corefw.util.InternalVar

		if localUrl
			localUrlParamJson = @getParamsJsonFromUrl localUrl
			userid = localUrlParamJson.sm_user || ""
			iv.setByNameProperty 'CoreApp', 'user', userid

			appName = localUrlParamJson.app
			delete localUrlParamJson.app

			startupUrlParamJson = Ext.apply startupUrlParamJson, localUrlParamJson

		if not appName
			appName = respObj["application"]

		userPreferenceValue = localStorage[appName]
		userPreferenceValue? and Ext.apply startupUrlParamJson, @getUserPreferenceParameter appName
		# paramModel means every event request will be appended the parameters from starup url
		if respObj.paramModel
			respObj.startUpUrlParams = startupUrlParamJson
		queryObj = Ext.Object.fromQueryString startupUrlHost.replace /;/g, "&"
		if queryObj and queryObj["eventURL"]
			queryObj["application"] = respObj['application'] = appName
			queryObj["eventURL"] = appName + "/" + queryObj["eventURL"].substr queryObj["eventURL"].indexOf("/") + 1
			Ext.apply queryObj, startupUrlParamJson

		return respObj["startupUrl"] = respObj.urlRoot + Ext.Object.toQueryString queryObj

#TODO cy34944 startup parser, go to cache?
	getStartupObj: ->
		return Corefw.util.InternalVar.getByNameProperty 'CoreApp', 'startupObj'

#TODO cy34944 startup parser, go to cache?
	setStartupObj: (respObj) ->
		Corefw.util.InternalVar.setByNameProperty 'CoreApp', 'startupObj', respObj
		return
#TODO cy34944 startup parser, go to cache?
	getApplicationName: ->
		startupObj = @getStartupObj()
		return startupObj.application

	getTopTabPanel: ->
		return Ext.ComponentQuery.query('toptabpanel')[0]

#TODO cy34944 startup parser, go to cache?
	isLocalMode: ->
		return this.getStartupObj().localMode

#TODO cy34944 startup parser, go to cache?
	isDebugMode: ->
		startupObj = @getStartupObj()
		if startupObj and startupObj.debugMode
			return true

		return false

# attach window event handlers
	attachWindowEvent: () ->
		me = @
		Ext.EventManager.on window, 'blur', ->
			me.windowOnBlur()
			return

		Ext.EventManager.on window, 'focus', ->
			me.windowOnFocus()
			return

		Ext.EventManager.on window, 'message', (event)->
			me.logoff(event)
		return

	logoff: (event)->
		if event.browserEvent.data
			closeName = 'GatewayLogout'
			message = event.browserEvent.data.toString()
			if message and (message.indexOf(closeName) > -1)
				rq = Corefw.util.Request
				contextName = @getContextName()
				url = '/' + contextName + '/logout/'
				rq.sendRequest5 url, null, null, null, 'Startup URL contents were invalid'
			return
	getContextName: ()->
		pathArray = window.location.pathname.split('/');
		contextName = pathArray[1]
		return  contextName

	useClassicTheme: ->
		if this.isLocalMode() or this.getStartupObj().coreTheme is 'classic'
			return true
		return false

	getThemeVersion: ->
		return this.themeVersion if this.themeVersion
		coreTheme = this.getStartupObj().coreTheme
		theme = location.pathname
		if theme.indexOf("index2.html") > 1 or theme.indexOf("index2H.html") > 1 or theme.indexOf('Vn.jsp') > 1
			coreTheme = "version2"
		switch coreTheme
			when 'citirisk'
				this.themeVersion = 1
			when 'version2'
				this.themeVersion = 2

		return this.themeVersion

	showBrowserNotSupportedMsg: ->
		container = Ext.create 'Ext.container.Container',
			layout:
				type: 'vbox'
				align: 'center'
				pack: 'center'
			height: 280
			width: 460
			border: 1
			style:
				borderColor: '#00BFFF'
				borderStyle: 'solid'
				borderWidth: '1px'
				borderRadius: '20px'
			items: [{
				xtype: 'label'
				cls: 'warnMsg'
				maxHeight: 30
				html: '<h3>&nbsp;&nbsp;Unsupported Browser</h3><br>'
			}
				{
					xtype: 'image'
					height: 100
					width: 220
					src: 'resources/adhoc/images/modern-browser.png'
				}
				{
					xtype: 'label'
					html: '* Chrome can be found under Start -> All Programs -> Google Chrome'
				}]

		Ext.create 'Ext.container.Viewport',
			layout:
				type: 'vbox'
				align: 'center'
				pack: 'center'
			items: [container]
		return

	getUserPreferenceParameter: (appName) ->
		ls = window.localStorage
		if not appName
			return
		userPreference = Ext.decode ls[appName], true
		return userPreference || {}

	getParamsJsonFromUrl: (url) ->
		if url.indexOf('?') < 0
			return
		params = url.split '?'
		if params.length > 0
			return Ext.Object.fromQueryString params[1]
		return

	windowOnFocus: ->
		window.isActive = true
		top = @getTopTabPanel()
		activePerspective = top?.getActiveTab()
		if activePerspective
			activePerspective.startAllHeartBeats()
		return

	windowOnBlur: ->
		window.isActive = false
		top = @getTopTabPanel()
		return unless top
		deactivePerspective = top.getActiveTab()
		if deactivePerspective
			deactivePerspective.stopAllHeartBeats()
		return

	preventBackspaceEventOnDocument: ->
		cm = Corefw.util.Common
		document.onkeydown = cm.preventBackspaceEvent
		return

	createAjaxErrorHandling: ->
		Ext.util.Observable.observe Ext.data.Connection,
			requestexception: (conn, response, options) ->
				if response.status is 500 and Ext.String.startsWith(options.url, 'api/pivot/')
					Corefw.Msg.alert 'Server Error', 'A server error happened'
				return