Ext.define 'Corefw.view.MessageBox',
	extend: 'Ext.window.MessageBox'
	xtype: 'coremessagebox'
	mixins: []
	closeAction: 'destroy'

	initComponent: ->
		me = @
		su = Corefw.util.Startup
		cache = @cache
		props = cache._myProperties

		config =
			title: props.title
			msg: props.message
			hidden: not props.visible
			disabled: not props.enabled
			messageType: props.messageType
			iconWidth: 48 if su.getThemeVersion() is 2

		okButton = false
		cancelButton = false

		navs = @cache._myProperties.navs
		if navs
			navArray = navs._ar
			if navArray and navArray.length
				for nav in navArray
					if nav.name is 'ok'
						okButton = true
						Ext.MessageBox.buttonText.ok = nav.title
					else if nav.name is 'cancel'
						cancelButton = true
						Ext.MessageBox.buttonText.cancel = nav.title

		if okButton and cancelButton
			config.buttons = Ext.Msg.OKCANCEL
		else if okButton and not cancelButton
			config.buttons = Ext.Msg.OK
		else if not okButton and cancelButton
			config.buttons = Ext.Msg.CANCEL
		else
			config.buttons = Ext.Msg.OKCANCEL

		okCallback = @okCallback
		config.fn = (btn) ->
			if btn is 'ok'
				if okCallback
					okCallback()
				else
					me.triggerOKEvent()
			else if btn is 'cancel'
				me.triggerCancelEvent()
			return

		switch props.messageType
			when 'INFORMATION'
				config.icon = Ext.Msg.INFO
			when 'WARNING'
				config.icon = Ext.Msg.WARNING
			when 'ERROR'
				config.icon = Ext.Msg.ERROR
			when 'CONFIRM'
				config.icon = Ext.Msg.QUESTION
			else
				config.icon = Ext.Msg.INFO

		Ext.apply @uipath, props.uipath

		@callParent arguments

		if su.getThemeVersion() is 2
			for button in me.msgButtons
				button.minWidth = 60
				button.height = 28
			me.topContainer.padding = '15'
		@show config

		console.log 'MESSAGE_BOX: ', @

		if su.getThemeVersion() is 2
			@addtools(@tools)
		return

	findAllNavs: ->
		navs = @cache._myProperties.navs
		if not navs
			return
		return navArray = navs._ar

	findNavFromCache: (navName) ->
		navArray = @findAllNavs()
		if not navArray or not navArray.length
			return
		for nav in navArray
			if nav.name is navName
				return nav
		return

	triggerOKEvent: ->
		@triggerEvent 'ok'
		return

	triggerCancelEvent: ->
		@triggerEvent 'cancel'
		return

	triggerEvent: (buttonLabel) ->
		cm = Corefw.util.Common
		rq = Corefw.util.Request
		uip = Corefw.util.Uipath

		nav = @findNavFromCache buttonLabel
		if nav and nav.events and nav.events._ar
			if nav.events['ONCLICK']
				url = rq.objsToUrl3(nav.events['ONCLICK'].url)
				parentComp = uip.uipathToParentComponent @cache._myProperties.uipath
				if parentComp? and parentComp isnt undefined
					postData = parentComp.generatePostData()
					rq.sendRequest5 url, rq.processResponseObject, @cache._myProperties.uipath, postData
				else
					rq.sendRequest5 url, rq.processResponseObject, @cache._myProperties.uipath, undefined
			else if nav.events['ONDOWNLOAD']
				@processFile Ext.ComponentQuery.query('[uipath=' + @triggerUipath + ']:last')[0], rq.objsToUrl3(nav.events['ONDOWNLOAD'].url), cm.download
			else if nav.events['ONREDIRECT']
				@processFile Ext.ComponentQuery.query('[uipath=' + @triggerUipath + ']:last')[0], rq.objsToUrl3(nav.events['ONREDIRECT'].url), cm.redirect
		return

	afterHide: ->
		@callParent arguments
		@destroy()
		return

	addtools: (tools) ->
		for tool in tools
			if tool.type is 'close'
				tool.addCls "#{Ext.baseCSSPrefix}window-close-btn"
				tool.setWidth 18
				tool.setHeight 18
		return

	processFile: (button, url, func) ->
		cm = Corefw.util.Common
		uip = Corefw.util.Uipath
		uipath = button.uipath
		parentCache = uip.uipathToParentCacheItem uipath
		props = parentCache._myProperties
		searchXtype = cm.getSearchXtypeForDownload props
		if searchXtype
			comp = button.up searchXtype
			if not comp
				if props.widgetType is 'TOOLBAR'
					comp = uip.uipathToPostContainer uipath
				else
					comp = uip.uipathToComponent button.uipath
			func.call cm, comp, url
		return