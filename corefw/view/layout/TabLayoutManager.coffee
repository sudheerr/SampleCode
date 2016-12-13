Ext.define 'Corefw.view.layout.TabLayoutManager',
	extend: 'Corefw.view.layout.LayoutManager'
	constructor: (config) ->
		@callParent arguments
		su = Corefw.util.Startup
		comp = @comp
		@tabPanelContainer = comp
		comp.layout = 'fit'
		innerTabPanel =
			xtype: 'tabpanel'
			ui: "tabnavigator-#{comp.xtype}"

		if su.getThemeVersion() is 2
			innerTabPanel.ui = 'secondary-tabs-elements'
			innerTabPanel.plugins =
				ptype: 'topTabPanelMenu'

		# add title to tabBar
		props = comp?.cache?._myProperties
		if su.getThemeVersion() is 2 and (not Ext.isEmpty props?.title)
			titleLabel =
				xtype: 'label'
				text: props.title
				cls: 'compEl-tab-tabBar-header'
			innerTabPanel.listeners =
				afterRender: () ->
					this.tabBar.insert 0, titleLabel
					return

		comp.items = [innerTabPanel]
		return

	removeAll: ->
		comp = @comp
		comp.removeAll()
		return

	initLayout: ->
		comp = @tabPanelContainer
		contentDefs = comp.contentDefs
		for contentDef in contentDefs
			@applyContentConfig contentDef
		tabPanel = comp.down 'tabpanel'
		tabPanel.contentDefs = contentDefs
		@comp = tabPanel
		tabPanel.add contentDefs
		tabPanel.setActiveTab 0
		# enable vertical scrollbar if flex is set
		if @tabPanelContainer.flex
			@enableContentsVScrollbar()
		return

	enableContentsVScrollbar: ->
		comp = @comp
		tabChilds = comp.query ">coreelementform"
		Ext.each tabChilds, (child) ->
			child.setAutoScroll true
			child.setOverflowXY 'hidden', 'auto'
		return

	beforeAddContent: (contentDef) ->
		@applyContentConfig contentDef
		return

	applyContentConfig: (contentDef) ->
		props = contentDef.cache?._myProperties
		if props
			props.expanded = true
			props.collapsible = false
		return

	afterAddContent: (content, contentDef, index, isAncestorUpdating) ->
		if not isAncestorUpdating
			comp = @comp
			comp.setActiveTab index
		return

	getActiveTabPath: () ->
		return @comp?.activeTab?.uipath

	setActiveTab: (activeTabPath) ->
		uip = Corefw.util.Uipath
		activeTab = uip.uipathToComponent activeTabPath
		if activeTab
			@comp.setActiveTab activeTab
		return
