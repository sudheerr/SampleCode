Ext.define 'Corefw.controller.Nav',
	extend: 'Ext.app.Controller'

	init: ->
		this.control
			"[navONCLICKevent]":
				click: this.onThrottledNavClick
			"[coretype=contextmenubutton]":
				click: this.contextMenuButtonClick
			"[coretype=gridheaderdropdownmenubutton]":
				click: this.gridheaderDropdownMenuButtonClick
			"[coretype=navmenuitembutton]":
				click: this.navMenuButtonClick
			"[coretype=formgridaddrow]":
				click: this.gridAddRow
			"[coretype=formgriddeleterow]":
				click: this.gridDeleteRow
			"[navONDOWNLOADevent]":
				click: this.downloadFile
			"[navONREDIRECTevent]":
				click: this.redirectFile
		return

	onThrottledNavClick: (button, ev) ->
		me = @
		throttledNavClick = @throttledNavClick
		navClickEvent = (button, ev) ->
			me.onNavClickEvent button, ev
			return

		if not throttledNavClick
			throttledNavClick = Ext.Function.createInterceptor navClickEvent, (button) ->
				curTime = Ext.Date.now()
				lastNavClickTime = button.lastNavClickTime
				if not lastNavClickTime or curTime > lastNavClickTime + 1000
					button.lastNavClickTime = curTime
					return true
				return false

			@throttledNavClick = throttledNavClick

		throttledNavClick button, ev
		return


	onNavClickEvent: (button, ev) ->
		cm = Corefw.util.Common
		rq = Corefw.util.Request
		uip = Corefw.util.Uipath

		uipath = button.uipath
		parentCache = uip.uipathToParentCacheItem uipath
		eventstr = 'ONCLICK'
		hasFileUpload = (cmp)->
			if cmp.getForm
				return cmp.getForm().hasUpload()
			if cmp.hasUpload
				return cmp.hasUpload()
			return false
		props = parentCache._myProperties
		if props.coretype is 'view' # fix the issue: view is not correct type to generate post data
			parent = button.up 'form'
			props = parent.cache._myProperties if parent?

		searchXtype = cm.getSearchXtypeForDownload(props)
		url = rq.objsToUrl3 button.eventURLs[eventstr], button.localUrl
		perspectiveWindowOfTriggerNav = (uip.uipathToComponent uipath)?.up 'coreperspectivewindow'
		if searchXtype
			comp = button.up searchXtype
			if not comp
				if props.widgetType is 'TOOLBAR'
					comp = uip.uipathToPostContainer uipath
				else
					comp = uip.uipathToComponent uipath

		postData = comp.generatePostData()
		opts =
			needFormSubmit: hasFileUpload comp
			filefields: comp.query 'filefield'

		if perspectiveWindowOfTriggerNav
			rq.sendRequest5 url, perspectiveWindowOfTriggerNav.processResponseObject, uipath, postData, undefined, undefined, perspectiveWindowOfTriggerNav, ev, opts
		else
			rq.sendRequest5 url, rq.processResponseObject, uipath, postData, undefined, undefined, undefined, ev, opts
		return

	contextMenuButtonClick: (button, ev) ->
		rq = Corefw.util.Request
		cm = Corefw.util.Common

		contextOwner = button.contextOwner
		comp = button.component
		console.log 'context button click: inside this button, grid or tree, component: ', button, contextOwner, comp

		eventURLs = button.eventURLs
		if not eventURLs
			return

		record = button.record || {}
		record.isEditing = true
		postData = comp.generatePostData()
		if comp.grid
			props = comp.cache._myProperties;
			postData.rowindex = props.rowindex
			postData.columnUipath = props.columnUipath
			postData.columnPath = props.columnPath

		if eventURLs.ONREDIRECT
			url = rq.objsToUrl3 eventURLs.ONREDIRECT, null
			cm.redirect comp, url
		if eventURLs.ONDOWNLOAD
			url = rq.objsToUrl3 eventURLs.ONDOWNLOAD, null
			cm.download comp, url

		else
			url = rq.objsToUrl3 eventURLs.ONCLICK, null
			rq.sendRequest5 url, rq.processResponseObject, comp.uipath, postData, undefined, undefined, undefined, ev
		record.isEditing = false
		return

	gridheaderDropdownMenuButtonClick: (button, ev) ->
		rq = Corefw.util.Request

		grid = button.grid
		console.log 'dropdown menu button click: inside this button, grid: ', button, grid

		eventURLs = button.eventURLs
		if not eventURLs
			return

		url = rq.objsToUrl3 eventURLs.ONCLICK, null

		record = button.record || {}
		record.isEditing = true
		postData = grid.generatePostData()

		rq.sendRequest5 url, rq.processResponseObject, grid.uipath, postData, undefined, undefined, undefined, ev

		record.isEditing = false
		return

	navMenuButtonClick: (button, ev) ->
		rq = Corefw.util.Request
		uip = Corefw.util.Uipath
		cm = Corefw.util.Common

		parentCache = button.parentCache
		parentProps = parentCache._myProperties
		uipath = parentProps.uipath

		parentComp = uip.uipathToComponent uipath

		# make sure it's a type that we're expecting
		coretype = parentProps.coretype
		if coretype is 'perspective' or coretype is 'view'
			postData = parentComp.generatePostData()
		else
			return

		eventArray = button.cache?.events
		if not eventArray
			eventArray = button.cache?._myProperties?.events
			if not eventArray
				return

		for eventItem in eventArray
			eventURL = eventItem.url
			url = rq.objsToUrl3 eventURL
			if eventItem.type is 'ONCLICK'
				rq.sendRequest5 url, rq.processResponseObject, uipath, postData, undefined, undefined, undefined, ev
			else if eventItem.type is 'ONDOWNLOAD'
				cm.download parentComp, url
			else if eventItem.type is 'ONREDIRECT'
				cm.redirect parentComp, url

		return

	gridAddRow: (button) ->
		# add a row to this grid
		grid = button.up 'grid'
		grid.addRowToGrid()
		return


# delete the selected rows
	gridDeleteRow: (button) ->
		# add a row to this grid
		grid = button.up 'grid'
		grid.deleteRowsFromGrid()
		return

	downloadFile: (button) ->
		rq = Corefw.util.Request
		cm = Corefw.util.Common
		uip = Corefw.util.Uipath
		uipath = button.uipath
		parentCache = uip.uipathToParentCacheItem uipath
		props = parentCache._myProperties
		url = rq.objsToUrl3 button.eventURLs['ONDOWNLOAD']
		searchXtype = cm.getSearchXtypeForDownload props
		if searchXtype
			comp = button.up searchXtype
			if not comp
				if props.widgetType is 'TOOLBAR'
					comp = uip.uipathToPostContainer uipath
				else
					comp = uip.uipathToComponent button.uipath
			cm.download comp, url
		return

	redirectFile: (button) ->
		rq = Corefw.util.Request
		cm = Corefw.util.Common
		uip = Corefw.util.Uipath
		uipath = button.uipath
		parentCache = uip.uipathToParentCacheItem uipath
		props = parentCache._myProperties
		url = rq.objsToUrl3 button.eventURLs['ONREDIRECT']
		searchXtype = cm.getSearchXtypeForDownload props
		if searchXtype
			comp = button.up searchXtype
			if not comp
				if props.widgetType is 'TOOLBAR'
					comp = uip.uipathToPostContainer uipath
				else
					comp = uip.uipathToComponent button.uipath
		cm.redirect comp, url
		return