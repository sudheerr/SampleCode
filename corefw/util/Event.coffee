# contains general events config/manager methods
Ext.define 'Corefw.util.Event',
	singleton: true

# cacheProperties: _myProperties from cache that contains the events
# componentLevel: 'view', or 'element', or wherever you want to attach the events to
# configObj: target object of Sencha component,
#		or config object that will turn into a Sencha component
	addEvents: (cacheProperties, componentLevel, configObj) ->
		su = Corefw.util.Startup
		#de = Corefw.util.Debug

		events = cacheProperties.events
		eventURLs = {}
		numEventsFound = 0

		# private
		addOneEvent = (e)->
			eventStr = "#{componentLevel}#{e.type}event"
			if e.isFrontOnly
				configObj[eventStr] = 'local'
			else
				configObj[eventStr] = 'remote'
			eventURLs[e.type] = e[remoteUrlProp]

			if su.isLocalMode() and e.localUrl
				configObj.localUrl = e.localUrl

			# if de.printOutRawResponse() and eventStr is 'ONCLOSE' and componentLevel is 'view'
			# 	console.log 'view ONCLOSE: ', cacheProperties
			return

		if events
			remoteUrlProp = 'url'
			for key, event of events
				numEventsFound++
				if key isnt '_ar'
					addOneEvent(event)

			configObj.eventURLs = eventURLs

		# if no events were seen
		if componentLevel is 'nav' and not numEventsFound
			# all buttons need at least 1 event
			# need to add ONCLICK event, with blank URL
			eventStr = 'navONCLICKevent'
			configObj[eventStr] = 'local'
			eventURLs.ONCLICK = ''

		return

	addHeartBeats: (cacheProperties) ->
		iv = Corefw.util.InternalVar
		heartBeats = cacheProperties?.heartBeats
		if heartBeats
			for hb in heartBeats
				uipath = cacheProperties.uipath
				runner = iv.getTaskByUipath uipath, hb.name
				if not runner
					iv.addTaskByUipath uipath, hb.name

		return

# sets a global variable to disable similar events for this component
	disableUEvent: (uipath, eventName) ->
		iv = Corefw.util.InternalVar
		eventDisableName = "event#{eventName}disable"
		iv.setByUipathProperty uipath, eventDisableName, true
		return

# returns TRUE if event enabled, FALSE if disabled
	getEnableUEventFlag: (uipath, eventName) ->
		iv = Corefw.util.InternalVar
		eventDisableName = "event#{eventName}disable"
		disableFlag = iv.getByUipathProperty uipath, eventDisableName
		if not disableFlag
			return true

		return false

# re-enables an event if it has been previously disabled
	enableUEvent: (uipath, eventName) ->
		iv = Corefw.util.InternalVar
		eventDisableName = "event#{eventName}disable"
		iv.deleteUipathProperty uipath, eventDisableName
		return

	toggleUEvent: (uipath, eventName) ->
		flag = @getEnableUEventFlag uipath, eventName
		if flag
			@disableUEvent uipath, eventName
		else
			@enableUEvent uipath, eventName
		return not flag

# onload event will be fired only at the first time, onrefresh will handle the rest
	fireRenderEvent: (widgetContainer) ->
		rq = Corefw.util.Request
		uip = Corefw.util.Uipath
		uipath = widgetContainer.uipath
		onloadEventFlag = @getEnableUEventFlag uipath, 'ONLOAD'
		onrefreshEventFlag = @getEnableUEventFlag uipath, 'ONREFRESH'
		eventURL = widgetContainer.eventURLs['ONLOAD']
		if eventURL and onloadEventFlag
			eventName = 'ONLOAD'
			@disableUEvent uipath, eventName
			@disableUEvent uipath, 'ONACTIVATE'
			@toggleUEvent uipath, 'ONREFRESH'
			if widgetContainer.grid?.remoteLoadStoreData
				widgetContainer.grid.remoteLoadStoreData()
				return
		else
			eventURL = widgetContainer.eventURLs['ONREFRESH']
			if eventURL
				eventName = 'ONREFRESH'
				onrefreshEventFlag = @toggleUEvent uipath, eventName
				if onrefreshEventFlag
					return
			else
				return

		if widgetContainer.coretype is 'element'
			parentCache = uip.uipathToCacheItem uipath
			props = parentCache._myProperties
			parentType = props.type

			if parentType is 'table'
				@loadPage 1
				return

		@disableUEvent uipath, 'ONCLOSE'

		url = rq.objsToUrl3 eventURL, widgetContainer.localUrl
		rq.sendRequest5 url, rq.processResponseObject, uipath

		return