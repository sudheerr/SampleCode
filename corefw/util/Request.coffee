Ext.define 'Corefw.util.Request',
	singleton: true

	loadingMaskDelay: 500		# milliseconds before loading mask appears
	loadingMaskHideDelay: 200	# milliseconds before hide loading mask
	requestsInProgress: 0		# how many requests we are currently waiting on
	currentLoadMask: null		# pointer to current loading mask, if one is visible
	externalCallback: ''
	totalPendingRequests: 0

	# builds a URL with eventURL passed in
	# can also pass in objects of parameters as 3rd, 4th, etc parameters
	# which will automatically get added to the end of the request
	objsToUrl3: (eventURL, localURL,lookupString) ->
		su = Corefw.util.Startup
		if lookupString
			lookupString = encodeURIComponent lookupString
		if not eventURL
			return

		if su.isLocalMode()
			if not localURL
				console.log 'localUrl not found for :', eventURL
				return
			return localURL

		serverUrl = @getServerUrl eventURL, lookupString, arguments
		return serverUrl

	getParamObj: (eventURL, startupObj) ->
		if Ext.isObject(eventURL)  and eventURL.url
			eventURL = eventURL.url

		paramObj =
			application: startupObj.application
			eventURL: eventURL
		return paramObj

	getServerUrl: (eventURL, lookupString, args) ->
		su = Corefw.util.Startup
		startupObj = su.getStartupObj()
		paramObj = @getParamObj eventURL, startupObj
		paramstr = @getParamStr paramObj, args
		serverUrl = startupObj.urlRoot + paramstr
		serverUrl = @appendQueryStrs serverUrl, lookupString
		console.log serverUrl
		return serverUrl

	getParamStr: (paramObj, args) ->
		newArgs = []
		for arg in args
			newArgs.push arg

		newArgs = newArgs[3... ]
		for arg in newArgs
			# make sure this is actually an object
			if typeof arg is 'object'
				Ext.apply paramObj, arg

		return Ext.Object.toQueryString paramObj

	appendQueryStrs: (serverUrl, lookupString) ->
		iv = Corefw.util.InternalVar
		d = new Date()
		timezoneOffset = d.getTimezoneOffset()
		serverUrl += "&timezoneOffset=" + timezoneOffset
		if lookupString isnt undefined
			serverUrl += "&lookupString=" + lookupString
		userid = iv.getByNameProperty "CoreApp", 'user'
		if userid
			serverUrl += "&sm_user=" + userid
		return serverUrl

	isValidResponse: (succ, resp) ->
		if not succ or not resp
			return false
		return true

	isValidResponseObj: (obj) ->
		return this.isValidResponse obj.success, obj.result

	prepareUnknowErrorMessage: ->
		return 'An unknown error occured on the server'

	prepareViolationMessage: (respObj) ->
		msgArray = respObj.result.violationMessages
		allMsg = ''
		for msg in msgArray
			allMsg += msg + '<br>'
		allMsg += '<br>'
		return allMsg

	hideLoadingMaskTask: null
	hideLoadMask: (opts)->
		if not Corefw.util.Request.hideLoadingMaskTask
			Corefw.util.Request.hideLoadingMaskTask = new Ext.util.DelayedTask @hideLoadMaskHandle, this
		if opts.isProgressEnd
			delayTime = if opts.loadingMaskHideDelay then opts.loadingMaskHideDelay else @loadingMaskHideDelay
			Corefw.util.Request.hideLoadingMaskTask.delay delayTime
		return

	hideLoadMaskHandle: ->
		me = this
		rq = Corefw.util.Request
		currentLoadMask = me.currentLoadMask
		if rq.totalPendingRequests > 0
			rq.totalPendingRequests -= 1
		if currentLoadMask and rq.totalPendingRequests is 0
			currentLoadMask.hide()
			currentLoadMask.destroy()
			me.currentLoadMask = null
		return
	# @uipath: uipath is used to get perspective window
	# @target: load mask target, it is from sendRequest5 parameter, opts.loadMaskTarget
	showLoadMask: (uipath, target,opts)->
		uip = Corefw.util.Uipath
		rq = Corefw.util.Request
		rq.totalPendingRequests += 1
		if  opts.isProgressEnd or @currentLoadMask
			rq.totalPendingRequests -= 1
			return false
		perspectiveWindow = (uip.uipathToComponent uipath)?.up 'coreperspectivewindow'
		viewport = Ext.ComponentQuery.query('viewport')[0]
		if target is undefined or target is null  or target.hidden is true
			target = perspectiveWindow
		target = target or perspectiveWindow or viewport

		if target and target.rendered and !target.hidden
			loadMask = target.setLoading msg: 'Loading'
			if loadMask
				loadMask.getTargetEl().setStyle 'z-index', 99999
				loadMask.getMaskEl().setStyle 'z-index', 99998
			@currentLoadMask = loadMask
			return true

		return false


	getShortUrl: (url) ->
		su = Corefw.util.Startup
		startupObj = su.getStartupObj()
		if startupObj and startupObj.urlRoot and startupObj.application
			origUrl = startupObj.urlRoot
			if Ext.String.startsWith origUrl, 'data/'
				return startupObj.urlRoot

			retUrl = url.replace startupObj.urlRoot, ''
			retUrl = retUrl.replace 'application='+startupObj.application+'&eventURL='+startupObj.application, ''
			retUrl = retUrl.replace /%2F/g, '/'
		return retUrl


	applyOptions: (opts, triggerUipath) ->
		rq = Corefw.util.Request
		opts = opts or {}
		defaultOpts =
			beforeRequestFn : (opts)->
				rq.showLoadMask triggerUipath, opts.loadMaskTarget, opts
				return
			afterRequestFn : (opts)->
				rq.hideLoadMask opts
				return
			isProgressEnd : false
			needFormSubmit : false
			filefields : []
		Ext.apply defaultOpts,opts
		return defaultOpts


	verifyUrl: (url, triggerUipath) ->
		if not url or not url.length
			return false
		return true


	verifyResponse: (success, response, errMsg, config) ->
		# show error message box when response is timedout
		if response.timedout is true
			@showTimeoutMsg errMsg
			return false
		if not @isValidResponse success, response
			@showInvalidResponseMsg success, response, errMsg
			return false
		if response.responseText
			try
				obj = Ext.decode response.responseText
			catch error
				# To fix C1615346-6785
				# TODO It might better be done at backend
				if /<HTML>.*siteminderagent.*<\/HTML>/.test response.responseText
					Ext.Msg.alert 'WARN', "Session timeout. Please relogin!"
					return
				throw error
			if obj is null
				return false
			if obj.success isnt null and obj.result
				if not @isValidResponseObj obj
					@showInvalidResponseObjMsg obj, config
					return false
		return true


	showTimeoutMsg: (errMsg) ->
		iv = Corefw.util.InternalVar
		errMsg = iv.getByNameProperty 'msg', 'timedout'
		errMsg = errMsg or 'The request you sent is timed out!'
		Ext.Msg.alert 'ERROR', errMsg
		return

	sessionAboutToTimeoutTask: null
	maxInactiveInterval: null
	initializationSessionAboutToTimeoutTask: ->
		mainCache = Corefw.util.Cache.getMainCache()
		if mainCache._myProperties?.maxInactiveInterval?   and mainCache._myProperties.maxInactiveInterval > 0
			Corefw.util.Request.maxInactiveInterval = (mainCache._myProperties.maxInactiveInterval - 60)  * 1000
			Corefw.util.Request.sessionAboutToTimeoutTask =  new Ext.util.DelayedTask @showSessionAboutToExpireMsg, this
			return
		return
	runSessionAboutToTimeOutTask: ->
		rq = Corefw.util.Request
		rq.sessionAboutToTimeoutTask?.delay rq.maxInactiveInterval
		return

	showSessionAboutToExpireMsg: ->
		iv = Corefw.util.InternalVar
		errMsg = iv.getByNameProperty 'msg', 'timedout'
		errMsg = errMsg or 'Your session will expire in <span class="countDownNum"></span> seconds. ' +
		'Would you like to continue your session?'
		warnMessageBox = Ext.Msg.show
			title: 'WARN'
			msg: errMsg
			buttons: Ext.Msg.YES
			fn: ->
				Corefw.util.Request.runSessionAboutToTimeOutTask()
				Ext.TaskManager.stop countDownTask
				Corefw.util.Request.activeSession()
				return
			icon: Ext.Msg.QUESTION
		countDownNumEl = warnMessageBox.el.down '.countDownNum'
		countDownNum = 60
		countDownTask = Ext.TaskManager.start
			interval: 1000
			repeat: 61
			run: ->
				if countDownNum is 0
					eDateTime = Ext.Date.format new Date(), 'm/d/Y H:i:s'
					Ext.Msg.alert 'WARN', "Your session was expired at <span style='font-weight: 600'>#{eDateTime}</span>. Please relogin!"
				countDownNumEl.setHTML countDownNum--
				return
		return

	activeSession: ->
		rq = Corefw.util.Request
		mainCache = Corefw.util.Cache.getMainCache()
		aciveSessionEvent = mainCache._myProperties.events?['ONACTIVESESSION']
		if not aciveSessionEvent
			return
		eventURL = rq.objsToUrl3 aciveSessionEvent
		rq.sendRequest5 eventURL


	showInvalidResponseMsg: (success, response, errMsg) ->
		if errMsg
			console.log errMsg
		else
			console.error 'Did not receive a valid response for the element event object: success, response: ', success, response
		return


	showInvalidResponseObjMsg: (obj, config) ->
		violationMessages = obj.result?.violationMessages or []
		violationType = obj.result?.violationType or 'Error'
		violationType = violationType.charAt(0).toUpperCase() + violationType.slice 1
		errorMsg = violationMessages.join ","
		errorMsg = errorMsg or 'Server Error.'
		Ext.Msg.alert 'ERROR', violationType + ": " + errorMsg
		console.error 'ERROR: invalid response for URL:'
		console.error '      ', @getShortUrl config.url
		console.error '   Message type, errors: ', violationType, violationMessages
		return


	prepareCallback: (options, errMsg, callbackFunc, scope, ev, triggerUipath) ->
		rq = Corefw.util.Request
		
		callback = (config, success, response) ->
			# manage loading mask
			# clear mask if all the requests in this batch have returned
			#@requestsInProgress -= 1
			options.isProgressEnd = true
			rq.runSessionAboutToTimeOutTask()
			options.afterRequestFn(options)

			if not rq.verifyResponse success, response, errMsg, config
				return

			obj = Ext.decode response.responseText

			if callbackFunc
				if scope
					callbackFunc.call scope, obj, ev, triggerUipath
				else
					callbackFunc obj, ev, triggerUipath
			else
				console.log 'no callback found'
			return

		return callback


	prepareConfig: (url, callback, postData, method, isAsync) ->
		config =
			async: isAsync
			url: url
			method: method or 'POST'
			callback: callback

		@setAjaxTimeout config
		@setRequestHeaders config, postData
		return config


	prepareRequest: (url, callbackFunc, triggerUipath, postData, errMsg, method, scope, ev, options, isAsync) ->
		rq = Corefw.util.Request

		triggerComp = Corefw.util.Uipath.uipathToComponent triggerUipath;
		if triggerComp and triggerComp.showLoadMaskOnMe
			options.loadMaskTarget = triggerComp.getLoadMaskTarget()
			options.loadingMaskDelay = triggerComp.loadingMaskDelay
			options.loadingMaskHideDelay = triggerComp.loadingMaskHideDelay

		ajaxCallback = @prepareCallback options, errMsg, callbackFunc, scope, ev, triggerUipath

		needFormSubmit = options.needFormSubmit
		if needFormSubmit
			form = @createFormForSubmit options, postData
			submitUrl = url.replace 'api/delegator',"api/delegator/fileupload"
			requestFn = Ext.Ajax.upload
			reqHandler =
				success : (resq)->
					# ensure html tag won't be filtered out
					resq.responseText = resq.responseXML.body.innerHTML
					Ext.removeNode form if form
					ajaxCallback null, true, resq
					return
			requestArgs = [form, submitUrl, null, reqHandler]
		else
			config = @prepareConfig url, ajaxCallback, postData, method, isAsync
			requestFn = Ext.Ajax.request
			requestArgs = [config]

		request =
			send: ->
				rq.setLoadingMask options
				requestFn.apply Ext.Ajax, requestArgs
				return

		return request


	setAjaxTimeout: (config) ->
		su = Corefw.util.Startup
		iv = Corefw.util.InternalVar
		startupObj = su.getStartupObj()
		if startupObj
			timeout = startupObj.ajaxTimeout
			errMsg = startupObj.ajaxTimeoutMessage
			iv.setByNameProperty 'msg','timedout',errMsg
			if timeout
				config.timeout = timeout
		return


	setRequestHeaders: (config, postData) ->
		if postData
			config.headers =
				"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
			encStr = Ext.encode postData
			postObj =
				data: encStr
			postStr = Ext.Object.toQueryString postObj
			config.params = postStr
		return


	createFormForSubmit: (options, postData) ->
		filefields = options.filefields
		form = document.createElement 'form'
		for file in filefields
			continue if file.isInvalid
			form.appendChild file.fileInputEl.dom
			inp = document.createElement 'input'
			inp.name = "fieldUIPath"
			inp.value = file.up().uipath
			form.appendChild inp
		input = document.createElement 'input'
		input.name = 'data'
		input.value = Ext.encode postData
		form.appendChild input
		Ext.get(form).hide()
		Ext.getBody().appendChild form
		return form


	setLoadingMask: (options) ->
		# show loading mask only after @loadingMaskDelay milliseconds
		# if it returns sooner, loading mask will not be visible
		#@requestsInProgress += 1
		delay = if options.loadingMaskDelay then options.loadingMaskDelay else @loadingMaskDelay
		func = Ext.Function.createDelayed ->
			options.beforeRequestFn(options)
			return
		, delay
		func()
		return

	# send a request to the server
	# callbackFunc is called with the Javascript object parsed from the response, if successful
	# if failed, will print the errMsg to the console, and return undefined
	# triggerUipath: the component that made this call
	sendRequest5: (url, callbackFunc, triggerUipath, postData, errMsg, method, scope, ev, opts, isAsync = true) ->
		return if not Corefw.util.Observer.isEventGranted triggerUipath, @getEventTypeByUrl url
		if not @verifyUrl url, triggerUipath
			return
		url = @processRequestUrl url,
			triggerUipath: triggerUipath

		options = @applyOptions opts, triggerUipath
		request = @prepareRequest url, callbackFunc, triggerUipath, postData, errMsg, method, scope, ev, options, isAsync

		request.send()
		return

	getEventTypeByUrl: (url = '') ->
		matchStr = url.match /ON[A-Z]*/
		return url if not matchStr
		return matchStr[0]

	processResponseObject: (respObj, ev, triggerUipath, preProcess, disablePageSwitch) ->
		rq = Corefw.util.Request
		uip = Corefw.util.Uipath
		ch = Corefw.util.Cache
		Observer = Corefw.util.Observer
		Observer.disableAllEvents triggerUipath
		Observer.updateStateFromResponse respObj, Observer.States.SYNCED
		Observer.suspend()
		if not respObj  #TODO  what is this logic? error exists here
			comp = uip.uipathToComponent(uipath) or {}
			editorHost = comp.grid or comp.tree
			if editorHost
				editorHost.ctrl?.eventsCount--
				editorHost.stopOpeningEditor = false
			return

		respObjList = if not Ext.isArray respObj then [respObj] else respObj
		
		if rq.externalCallback
			rq.doExternalCallback triggerUipath, respObjList, ev

		for oneRespObj, index in respObjList
			continue if not oneRespObj or oneRespObj.isIgnored
			if not oneRespObj.widgetType
				rq.processUpdating oneRespObj
				continue
			newCache = ch.parseJsonToCache oneRespObj, index
			rq.processRendering newCache, ev, preProcess, disablePageSwitch, triggerUipath
			rq.processUserPrefrence oneRespObj
			Corefw.util.Render.flushLayouts()
		Observer.resume()
		return

	###
		process the request url additionally
		@param {String} url
			the request url
		@param {Object} opts
			- startupObj
			- triggerUipath
	###
	processRequestUrl:(url,opts={})->
		if not opts.startupObj
			st = Corefw.util.Startup
			startupObj = st.getStartupObj() or {}
		else
			startupObj = opts.startupObj
		triggerUipath = opts.triggerUipath
		# startUpUrlParams will be created in Corefw.util.Startup#getQueryUrl, not come from startup.json
		startUpUrlParams = startupObj.startUpUrlParams
		# paramModel means every event request will be appended the parameters from starup url
		if startupObj.paramModel and startUpUrlParams and triggerUipath
			if 0 > url.indexOf '?'
				url = url + '?'
			else
				url = url + '&'
			url = url + Ext.Object.toQueryString startUpUrlParams
		return url

	# async
	doExternalCallback: (triggerUipath, respObjList, ev) ->
		me = @
		asyncFunc = Ext.Function.createDelayed ->
			try
				eval me.externalCallback + '(triggerUipath, respObjList, ev)'
			catch e
				console.log 'Error or no external callback "' + me.externalCallback + '" defined in startup.json found.', e
			return
		, 1
		asyncFunc()
		return

	processUpdating: (oneRespObj) ->
		uipath = oneRespObj.uipath
		# we assume unrecognizable type is going to update existing component's visual
		comp = Ext.ComponentQuery.query('[uipath=' + uipath + ']')[0]
		if not comp
			console.error 'Undefined type and no component can be found!'
			return
		comp.updateRelatedCache?(oneRespObj)
		comp.updateVisual?(oneRespObj)

	processRendering: (newCache, ev, preProcess, disablePageSwitch, triggerUipath) ->
		uip = Corefw.util.Uipath
		cq = Ext.ComponentQuery
		for key, oneCache of newCache
			props = oneCache._myProperties
			preProcess? props

			coretype = props?.coretype?.toLowerCase()
			uipath = props.uipath
			parentComp = uip.uipathToParentComponent uipath
			# TODO eliminate switch
			switch coretype
				when 'perspective', 'view', 'element', 'compositeelement', 'field', 'fieldset'
					if parentComp
						#replacingChild is to indicate it's replacing child, used to suspend event
						parentComp.replacingChild = true
						parentComp.replaceChild oneCache, ev, disablePageSwitch
						parentComp.replacingChild = false
				when 'toolbar'
					if parentComp
						parentComp.updateToolbar oneCache
				when 'breadcrumb'
					if parentComp
						parentComp.replaceBreadcrumb oneCache
				when 'messagebox'
					# here's how messagebox should be implemented:
					p = oneCache._myProperties
					if p.closed is true
						cq.query("messagebox[uipath=#{uipath}]").forEach (m)-> m.destroy()
						break
					Ext.create 'Corefw.view.MessageBox',
						cache: oneCache
						triggerUipath: triggerUipath
						uipath: uipath
				when 'notification'
					Corefw.view.ntf.NotificationBoard.notify oneCache
				when 'nav'
					if parentComp and parentComp.updateNavigation
						parentComp.updateNavigation oneCache
					# then, in the initComponent of MessageBox, configure the component any way you like,
					#		using the "cache" property
					# because "autoShow" is TRUE, the window will be shown when it's created
					# you should configure autoShow in the MessageBox class, and delete it here
					# make sure you destroy the component when the user is done with it
		return


	# store the user preference to the local storage
	processUserPrefrence: (oneRespObj) ->
		su = Corefw.util.Startup
		userPreference = oneRespObj.userPreference
		if userPreference?
			userPreferenceValue = Ext.encode userPreference.preferenceMap
			application = su.getStartupObj().application
			window.localStorage[application] = userPreferenceValue
		return


	# url is a event url processed by function objsToUrl3
	getEventTypeByUrl: (url) ->
		if Ext.isEmpty url
			return null
		else
			reqParams = url.split '&'
			for p in reqParams
				[name,value] = p.split '='
				break if name is 'eventURL'
			urlUnits = value?.split '%2F'
			return urlUnits[urlUnits.length - 1] if urlUnits and urlUnits.length > 0


