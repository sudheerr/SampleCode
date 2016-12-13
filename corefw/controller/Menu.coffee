Ext.define 'Corefw.controller.Menu',
	extend: 'Ext.app.Controller'

	init: ->
		this.control
			"[corefieldtype=objectgrid]":
				cellcontextmenu: this.onCellCtxMenuGrid
			"[corefieldtype=rcgrid]":
				cellcontextmenu: this.onCellCtxMenuGrid
			"coretreegrid treepanel[isLocked!=true]":
				cellcontextmenu: this.onTreeCellCtxMenu
			"coretreesimple treepanel":
				cellcontextmenu: this.onTreeCellCtxMenu
			"[coretype=navmenubutton]:not([activateEvent])":
				click: this.onNavMenuClick
			"[coretype=navmenubutton][activateEvent=ONRIGHTCLICK]":
				contextmenu: this.onNavMenuClick
				afterrender: this.onRCNavAfterRender
			"menu[menutype=popup]":
				hide: this.onMenuHide
			"menu[menutype!=popup]":
				beforeshow: @onMenuBeforeShow
		return

	onRCNavAfterRender: (comp) ->
		comp.el.on 'contextmenu', (event) ->
			comp.fireEvent 'contextmenu', comp, event
			return
		return

	onMenuBeforeShow: (menu) ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			menu.showSeparator = false
		activeHeader = menu.activeHeader
		if not activeHeader
			return
		grid = activeHeader.ownerLayout.grid
		grid.reconfigMenuItems menu
		menuArray = menu.items.items
		for menuArrayItem in menuArray
			if menuArrayItem.menu
				menuArrayItem.cls = "hasSubMenu"
		grid.setHeaderActive activeHeader
		return

	onMenuHide: (comp) ->
		Ext.destroy comp
		return

# create a menu item specific to this cell
# if none exists, try creating a grid-wide context menu
# cell menu takes precedence over grid menu, will only show one or the other
	createCellMenuItems: (component, insideObj, cache, e, eOpts, record, rowindex, columnindex, column)->
		menuCache = cache?._myProperties?.menu
		if menuCache
			options =
				menutype: 'context'
				contextOwner: insideObj
				component: component
				record: record
			this.createMenuItems menuCache, e, options
		else
			@createContextMenu component, insideObj, record, rowindex, columnindex, e, eOpts, column
		return

	onTreeCellCtxMenu: (dataview, td, columnindex, record, tr, rowindex, e, eOpts)->
		component = dataview.up 'coretreegrid, coretreesimple'
		column = dataview.getHeaderByCell td

		this.createCellMenuItems component, component.tree, column.cache, e, eOpts, record, rowindex, columnindex, column
		return

	onCellCtxMenuGrid: (dataview, td, columnindex, record, tr, rowindex, e, eOpts)->
		component = dataview.up 'corercgrid'
		if not component
			component = dataview.up 'coreobjectgrid'
		column = dataview.getHeaderByCell td

		this.createCellMenuItems component, component.grid, column.cache, e, eOpts, record, rowindex, columnindex, column
		return

	createContextMenu: (comp, insideObj, record, rowindex, columnindex, e, eOpts, column) ->
		cm = Corefw.util.Common
		return false if cm.processProhibited comp
		cache = comp.cache
		props = cache?._myProperties
		if not props
			return
		rightClickEvent = props.events?.ONRIGHTCLICK
		if rightClickEvent
			if comp.grid
				@processGridRightClickEvent comp, insideObj, record, rowindex, columnindex, e, column
			else if comp.tree
				@processTreeRightClickEvent comp, insideObj, record, rowindex, columnindex, e, column
			return

		if comp.grid
			dataview = comp.grid.getView()
			if dataview.locked
				col = column
			else
				col = dataview.getHeaderAtIndex columnindex
			props.rowindex = rowindex
			props.columnUipath = col?.cache?._myProperties?.uipath
			props.columnPath = col?.cache?._myProperties?.pathString


		menuCache = props.menu
		#console.log 'menuCache: ', menuCache
		if not menuCache
			return

		options =
			menutype: 'context'
			contextOwner: insideObj
			component: comp
			record: record

		info =
			component: comp
			contextOwner: insideObj
			cache: cache
			record: record
			rowindex: rowindex
			columnindex: columnindex
			e: e

		#console.log 'right clicked in grid or tree, info: ', info

		this.createMenuItems menuCache, e, options

		return false

	processTreeRightClickEvent: (comp, insideObj, record, rowindex, columnindex, e, column) ->
		me = this
		rq = Corefw.util.Request
		uipath = comp.uipath
		props = comp.cache._myProperties
		url = rq.objsToUrl3 props.events.ONRIGHTCLICK

		processMenuResponse = (menuObj, ev, uipath) ->
			if menuObj.messageType
				me.showSessionTimeoutMsgBox menuObj
				return

			options =
				menutype: 'context'
				contextOwner: insideObj
				component: comp
				record: record
			me.createMenuItems menuObj, ev, options
			return

		record.isEditing = true
		postData = comp.generatePostData()
		rq.sendRequest5 url, processMenuResponse, uipath, postData, undefined, undefined, undefined, e
		record.isEditing = false
		e.stopEvent()
		return

	processGridRightClickEvent: (comp, insideObj, record, rowindex, columnindex, e, column) ->
		me = this
		rq = Corefw.util.Request
		uipath = comp.uipath
		props = comp.cache._myProperties
		url = rq.objsToUrl3 props.events.ONRIGHTCLICK

		dataview = comp.grid.getView()
		if dataview.locked
			col = column
		else
			col = dataview.getHeaderAtIndex columnindex
		#column = dataview.getHeaderAtIndex columnindex
		columnUipath = col?.cache?._myProperties?.uipath
		columnPath = col?.cache?._myProperties?.pathString


		# if we can't get the uipath, there's no point in sending the request
		if not columnUipath
			return

		# we're sending the column UIpath because the columnindex on the client can be different than
		# the server, due to "automatic" columns like checkboxes, or grouped headers
		# sending the column uipath is guaranteed to refer to the correct column
		postData =
			name: props.name
			rowindex: rowindex
			columnUipath: columnUipath
			columnPath: columnPath
		host = comp.grid
		if host
			selection = host.getSelectionModel?()?.getSelection()
			if selection.length > 0
				valueItems = props.items
				valueItems.forEach (i)-> i.selected = false
				for item in selection
					if valueItems.length > 0
						if host.store.isGrouped
							valueItems[item.data.__index].selected = true
						else
							valueItems[item.index].selected = true
					postData.items = valueItems

		processMenuResponse = (menuObj, ev, uipath) ->
			if menuObj.messageType
				me.showSessionTimeoutMsgBox menuObj
				return

			options =
				menutype: 'context'
				contextOwner: insideObj
				component: comp
				record: record
			me.createMenuItems menuObj, ev, options
			return

		rq.sendRequest5 url, processMenuResponse, uipath, postData, undefined, undefined, undefined, e
		e.stopEvent()
		return

	showSessionTimeoutMsgBox: (menuObj) ->
		ch = Corefw.util.Cache
		msgCache = ch.parseJsonToCache menuObj
		for key, oneCache of msgCache
			Ext.create 'Corefw.view.MessageBox',
				cache: oneCache
		return

	addOffset: (args) ->
		me = args
		location = [ 10, 10 ]
		location[0] = me[0] + 10 if me[0]
		location[1] = me[1] + 10 if me[1]
		location

	createMenuItems: (menuCache, domEvent, options) ->
		su = Corefw.util.Startup
		if not menuCache.visible
			domEvent.stopEvent()
			return
		#console.log 'createMenuItems: menu cache: ', menuCache
		items = []
		tempMenuConfig =
			items: items
			menutype: 'popup'

		menuArray = menuCache._ar
		if not menuArray
			menuArray = []
			# add all the allContents and allNavigations items together
			if menuCache.allContents
				for menuitem in menuCache.allContents
					menuArray.push menuitem
			if menuCache.allNavigations
				for menuitem in menuCache.allNavigations
					menuArray.push menuitem

		if menuArray and menuArray.length
			this.createMenuItemsWorker menuArray, items, options

		if su.getThemeVersion() is 2
			tempMenuConfig.showSeparator = false
			tempMenuConfig.cls = 'menuNoIcon'

		tempmenu = Ext.create 'Ext.menu.Menu', tempMenuConfig

		tempmenu.showAt @addOffset(domEvent.getXY())
		domEvent.stopEvent()
		return


	createMenuItemsWorker: (menuArray, menuParent, options) ->
		su = Corefw.util.Startup
		evt = Corefw.util.Event
		for menuItemCache in menuArray
			if not menuItemCache.group
				menuItemCache.group =
					index: -1
		menuArray.sort (item0, item1)->
			item0.group.index - item1.group.index
		if menuArray.length
			lastIndex = menuArray[menuArray.length - 1].group.index
			for index in [menuArray.length - 1..0] by -1
				if menuArray[index].group.index isnt lastIndex
					lastIndex = menuArray[index].group.index
					sep = xtype: 'menuseparator'
					if su.getThemeVersion() is 2
						sep.margin = '0 6 0 6'
					menuArray.splice index + 1, 0, sep
		for menuItemCache in menuArray
			menuitem = {}
			props = menuItemCache._myProperties
			if not props
				props = menuItemCache
			if menuItemCache.xtype is 'menuseparator'
				menuParent.push menuItemCache
				continue
			menuitem.text = props.title
			menuitem.name = props.name
			menuitem.tooltip = props.toolTip
			menuitem.hidden = not props.visible
			menuitem.disabled = not props.enabled
			menuitem.cache = menuItemCache
			menuitem.uipath = menuItemCache.uipath
			evt.addEvents props, 'menu', menuitem
			if options
				if options.menutype is 'context'
					menuitem.coretype = 'contextmenubutton'
					menuitem.contextOwner = options.contextOwner
					menuitem.record = options.record
					menuitem.component = options.component
				else if options.menutype is 'nav'
					menuitem.coretype = 'navmenuitembutton'
					menuitem.parentCache = options.parentCache

			nextMenuArray = menuItemCache._ar
			if not nextMenuArray
				nextMenuArray = []
				# add all the allContents and allNavigations items together
				if menuItemCache.allContents
					for nextmenuitem in menuItemCache.allContents
						nextMenuArray.push nextmenuitem
				if menuItemCache.allNavigations
					for nextmenuitem in menuItemCache.allNavigations
						nextMenuArray.push nextmenuitem
			if nextMenuArray and nextMenuArray.length
				newAr = []
				menuitem.menu =
					items: newAr
				menuitem.cls = 'hasSubMenu'
				if su.getThemeVersion() is 2
					menuitem.menu.showSeparator = false
					menuitem.menu.cls += ' menuNoIcon'
				menuParent.push menuitem
				this.createMenuItemsWorker nextMenuArray, newAr, options
			else
				menuParent.push menuitem
		return


	onNavMenuClick: (button, ev) ->
		uip = Corefw.util.Uipath
		# assumption:
		#		navs with menus will always be inside a toolbar

		toolbarUipath = uip.uipathToParentUipath button.uipath
		uipathParentCache = uip.uipathToParentCacheItem toolbarUipath
		if not uipathParentCache
			uipathParentCache = uip.uipathToParentCacheItem button.uipath

		options =
			menutype: 'nav'
			parentCache: uipathParentCache

		#console.log 'onNavMenuClick: button, uipathParentCache: ', button, uipathParentCache
		@createMenuItems button?.cache?._myProperties?.menu, ev, options

		return