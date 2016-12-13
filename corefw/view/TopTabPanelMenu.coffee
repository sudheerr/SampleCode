Ext.define 'Corefw.view.TopTabPanelMenu',
	alias: 'plugin.topTabPanelMenu'
	uses: ['Ext.menu.Menu']
	constructor: (config) ->
		config = config or {}
		Ext.apply @, config
		return

	init: (toptabpanel) ->
		me = @
		Ext.apply toptabpanel, me.parentOverrides
		me.toptabpanel = toptabpanel
		toptabpanel.on
			render: ->
				me.tabBar = toptabpanel.tabBar
				me.layout = me.tabBar.layout
				me.layout.overflowHandler.handleOverflow = Ext.Function.bind me.showMenuButton, me
				me.layout.overflowHandler.clearOverflow = Ext.Function.createSequence me.layout.overflowHandler.clearOverflow, me.hideMenuButton, me
				return
			single: true
		return

	showMenuButton: ->
		me = @
		result = Ext.getClass(me.layout.overflowHandler)::handleOverflow.apply(me.layout.overflowHandler, arguments)
		if !me.menuButton
			me.menuButton = me.tabBar.body.createChild({cls: Ext.baseCSSPrefix + 'tab-tabdropmenu-right'},
				me.tabBar.body.child('.' + Ext.baseCSSPrefix + 'box-scroller-right'))
			me.menuButton.on 'click', me.showTabMenu, me
		me.menuButton.show()
		result.reservedSpace += me.menuButton.getWidth()
		return result

	hideMenuButton: ->
		me = @
		if me.menuButton
			me.menuButton.hide()
		return

	showTabMenu: (e) ->
		me = @
		if me.tabsMenu
			me.tabsMenu.removeAll()
		else
			me.tabsMenu = Ext.create 'Ext.menu.Menu',
				showSeparator: false
				cls: 'tabBar-scroller-menu'
			me.toptabpanel.on 'destroy', me.tabsMenu.destroy, me.tabsMenu
		me.showTabMenuItems()
		position = Ext.get e.getTarget()
		buttonPosition = position.getXY()

		buttonPosition[1] += 24
		me.tabsMenu.showAt buttonPosition
		return

	showTabMenuItems: ->
		me = @
		toptabpanel = me.toptabpanel
		toptabpanel.items.each (item) ->
			me.tabsMenu.add me.genMenuItems(item)
			return
		return

	genMenuItems: (item) ->
		displayMenu =
			text: item.title
			handler: @activeTab
			scope: @
			tabToShow: item
		if item.tab.active
			displayMenu.cls = 'tabBar-scroller-menu-item-active'
		return displayMenu

	activeTab: (menuItem) ->
		@toptabpanel.setActiveTab menuItem.tabToShow
		return

