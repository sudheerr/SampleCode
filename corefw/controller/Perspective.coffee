Ext.define 'Corefw.controller.Perspective',
	extend: 'Ext.app.Controller'

	init: ->
		@control
			'toptabpanel >> tab':
				click: @tabClick
			'coreperspectivewindow gridpanel':
				viewready: @whenGridViewOnPerspectiveWindow
			# click on a view tab under a regular perspective
			'coreperspective tab[coreview][disabled!=true]':
				click: @tabClick
			# tab under tabpanel
			'tab[disabled!=true][hidden=false]':
				click: @tabClickForDeactive
				activate: @activateTab
			'corecompositeelement tab[disabled!=true]':
				click: @tabClick
			'coreiframefield ^ coreperspective':
				activate: @activateIframeField

		return

	activateTab: (tab) ->
		rq = Corefw.util.Request
		evt = Corefw.util.Event
		comp = tab.card
		uipath = comp.uipath

		if not uipath or not comp.isVisible()
			return

		if comp.up '[replacingChild=true]'
			return

		activateUrl = comp.eventURLs['ONACTIVATE']

		if not activateUrl
			return

		# ONACTIVATE event is disabled at the first time when there is an onload event.
		activateEnabled = activateUrl and evt.getEnableUEventFlag uipath, 'ONACTIVATE'
		if not activateEnabled
			evt.enableUEvent uipath, 'ONACTIVATE'
			return

		postData = comp.generatePostData()
		activateUrl = rq.objsToUrl3 activateUrl
		rq.sendRequest5 activateUrl, rq.processResponseObject, uipath, postData
		return

	#on tab switch, Iframe with flex screens not showing up
	#**Note: this will only trigger for perspectives containing iframe
	activateIframeField: (tabPanel, newCard, oldCard, eOpts) ->
		iframe = tabPanel.down 'coreiframefield'
		Ext.defer (->
			iframe.setWidth iframe.getWidth() if iframe?.el?.dom
			return
		), 200

		return

	tabClick: (tab, ev) ->
		if ev and (tab.closeEl?.el?.dom is ev.target)
			tab.tabBar.closeTab tab
			return
		if not tab.doBuffered
			tab.doBuffered = Ext.Function.createBuffered ->
				rq = Corefw.util.Request
				evt = Corefw.util.Event
				comp = tab.card
				uipath = comp?.uipath
				# If have ONLOAD/ONCLICK both, at the first time, just trigger the ONLOAD event.
				notLoaded = comp?.eventURLs['ONLOAD'] and evt.getEnableUEventFlag uipath, 'ONLOAD'
				if notLoaded
					return
				onClickEventUrl = comp?.eventURLs['ONCLICK']
				if not onClickEventUrl
					return
				postData = comp.generatePostData()
				onClickEventUrl = rq.objsToUrl3 onClickEventUrl
				rq.sendRequest5 onClickEventUrl, rq.processResponseObject, uipath, postData
			, 200

		tab.doBuffered()

		return


	whenGridViewOnPerspectiveWindow: (grid) ->
		perspectiveWindow = grid.up 'coreperspectivewindow'
		position = perspectiveWindow.cache._myProperties.position
		if position is 'SCREEN_CENTER'
			perspectiveWindow.center()
		return

	tabClickForDeactive: (tab, ev) ->
		rq = Corefw.util.Request
		card = tab.card
		return unless (card and card.cache)
		nextContainerName = card.cache._myProperties.name
		uipath = card.uipath
		parentContainer = card.up()
		activeContainer = parentContainer.getActiveTab()
		onDeactivateUrl = activeContainer.eventURLs?.ONDEACTIVATE

		if not onDeactivateUrl
			return

		postData = activeContainer.generatePostData()
		switch card.xtype
			when 'coreelementform'
				postData.nextActiveElementName = nextContainerName
			when 'coreviewstacked'
				postData.nextActiveViewName = nextContainerName
			when 'coreperspective'
				postData.nextActivePerspectiveName = nextContainerName
		url = rq.objsToUrl3 onDeactivateUrl
		rq.sendRequest5 url, rq.processResponseObject, uipath, postData, undefined, undefined, undefined, ev
		return