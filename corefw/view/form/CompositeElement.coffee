Ext.define 'Corefw.view.form.CompositeElement',
	extend: 'CitiRiskLibrary.view.CitiRiskFormPanel'
	xtype: 'corecompositeelement'
	navAlign: 'left'
	suppressClosing: true

	initComponent: ->
		me = this

		#rdr = Corefw.util.Render
		evt = Corefw.util.Event
		su = Corefw.util.Startup
		layout = Corefw.view.layout.Layout
		me.layoutManager = layout.create me

		cache = me.cache

		props = cache._myProperties
		contentDefs = me.genContentDefs()

		config =
			coretype: 'element'
			uipath: props.uipath
			disabled: not props.enabled
			contentDefs: contentDefs
			overflowY: 'auto'
			collapsible: props.collapsible
			hidden: not props.visible
			collapsed: not props.expanded
			closable: false
			title: props.title
			secondTitle: props.secondTitle
			titleCollapse: true
			hideCollapseTool: true
			style:
				border: 'none'
			bodyStyle:
				border: 'none'

		if su.getThemeVersion() is 2
			@navAlign = 'right'
			if @isChildWithHeader cache
				me.addCls 'element-child-with-header'
			if props.name is 'treeElement'
				config.bodyStyle = 'background-color: #53565A; border: none'
				config.cls = 'treeselementcls'
				contentDefs = config.contentDefs
				for eachitem in contentDefs
					eachitemcache = eachitem.cache
					if eachitemcache.tree
						eachitemprops = eachitemcache.tree._myProperties
						eachitemprops.treesinelement = 'treesinelement'


		# hide header when title is empty and no toolbar or
		# compositeelement with tab layout in version2 (title show in tabBar instead)
		if (not config.title and Ext.isEmpty props?.toolbar) or (su.getThemeVersion() is 2 and props?.layout?.type.toLowerCase() is 'tab')
			config.header = false
			config.collapsed = false
			me.addCls 'element-without-header'
		else if su.getThemeVersion() is 2 and props?.layout?.type.toLowerCase() is 'tab'
			me.addCls 'compEl-tab-header'
		else
			config.title = config.title
			config.header = config.header or {}
			me.addCls 'element-with-header'
			titleEl =
				autoEl:
					'data-qtip': props.toolTip
			Ext.apply config.header, titleEl

		if props.toolbar and not su.getThemeVersion()
			config.header = config.header or {}
			headerCft =
				padding: '0 7 0 5'
				minHeight: 30
			Ext.apply config.header, headerCft

		#TODO Use css to control the padding, same as ElementForm
		if config.collapsible and config.title and not su.getThemeVersion()
			config.title = '&nbsp;&nbsp;&nbsp;' + config.title

		if props.closable
			config.closable = true

		elementCss = props.cssclass
		me.addCls elementCss if elementCss

		evt.addEvents props, 'compositeElement', config

		Ext.apply me, config
		@addListeners()
		@callParent arguments
		return

	addListeners: ->
		@listeners = @listeners or {}
		additionalListeners =
			beforeexpand: @beforePanelExpand
			expand: @afterPanelExpand
			beforecollapse: @beforePanelCollapse
			close: @onElementClose
			beforedestroy: @beforeElementDestroy

		Ext.apply @listeners, additionalListeners

	afterPanelExpand: (compositeElement) ->
		elements = compositeElement.query 'coreelementform'
		if not compositeElement.elementsResized
			for element, index in elements
				element.layoutManager?.resize?()
			compositeElement.elementsResized = true
		return

	beforePanelExpand: ->
		# TODO verify whether we still need below css
		if @collapsible
			@removeCls 'panelcolltxtclr'
			@addCls 'panelexptxtclr'
		return

	beforePanelCollapse: ->
		# TODO verify whether we still need below css
		if @collapsible
			@removeCls 'panelexptxtclr'
			@addCls 'panelcolltxtclr'
		return

	onElementClose: ->
		@suppressClosing = false
		return

	beforeElementDestroy: ->
		rdr = Corefw.util.Render
		rdr.destroyThisComponent this
		return

	onRender: ->
		evt = Corefw.util.Event
		su = Corefw.util.Startup
		@callParent arguments
		if @compositeElementONLOADevent or @compositeElementONREFRESHevent
			evt.fireRenderEvent this
		if su.getThemeVersion() is 2
			if @title and @collapsible
				if @collapsed
					@addCls 'panelcolltxtclr'
				else
					@addCls 'panelexptxtclr'

		return

	generatePostData: ->
		elementsArray = []
		postData =
			name: @cache._myProperties.name
			allContents: elementsArray
			expanded: not @collapsed
		selector = '> coreelementform, > corecompositeelement'
		if @layoutManager.type is 'tab'
			selector = '>> coreelementform, >> corecompositeelement'
		contents = @query selector

		for elemComp in contents
			elementPostData = elemComp.generatePostData()
			elementsArray.push elementPostData
		return postData

	afterRender: ->
		su = Corefw.util.Startup
		layoutManager = @layoutManager
		if not layoutManager.validate()
			return
		layoutManager.initLayout()
		@callParent arguments
		Corefw.util.Render.renderNavs @cache._myProperties, this, null, null, @navAlign
		Corefw.util.Render.addSecondTitle this

		return

	isOncloseEventDisabled: ->
		return @suppressClosing

	genContentDefs: ->
		cache = @cache
		contentDefs = []
		for contentKey, contentCache of cache
			contentProps = contentCache?._myProperties
			if contentKey isnt '_myProperties' and not contentProps?.isRemovedFromUI and contentProps?.visible
				contentDef = @genContentDef contentCache
				contentDefs.push contentDef if contentDef
		return contentDefs

	genContentDef: (contentCache) ->
		contentDef = {}
		props = contentCache._myProperties

		if not props
			return

		compTypeMap =
			FORM_BASED_ELEMENT: 'coreelementform'
			BAR_ELEMENT: 'coreelementbar'
			COMPOSITE_ELEMENT: 'corecompositeelement'

		widgetType = props.widgetType
		compType = compTypeMap[widgetType]

		if not compType
			return

		if not props.title
			props.collapsible = false
			props.expanded = true

		contentDef =
			xtype: compType
			cache: contentCache
			uipath: props.uipath
		return contentDef


	replaceChild: (elementCache, ev, isAncestorUpdating) ->
		uip = Corefw.util.Uipath

		props = elementCache._myProperties
		name = props.name
		uipath = props.uipath
		elemComp = uip.uipathToComponent uipath
		if not elemComp and not props.visible
			return

		if not isAncestorUpdating
			Ext.suspendLayouts()
		@cache[name] = elementCache
		if elemComp
			if @layoutManager.type is 'tab' and not props.visible or props.isRemovedFromUI
				@layoutManager.remove elemComp
				if not isAncestorUpdating
					Ext.resumeLayouts true
				return
			elemComp.updateUIData elementCache
		else
			elementDef = @genContentDef elementCache
			@layoutManager.add elementDef, undefined, isAncestorUpdating

		if not isAncestorUpdating
			Ext.resumeLayouts true

		return

	updateChild: (elementCache) ->
		@replaceChild elementCache, '', true
		return

#be invoked by View#replaceChild
#				CompositeElement#replaceChild -> CompositeElement#updateUIData
	updateUIData: (compositeElementCache) ->
		me = this
		cm = Corefw.util.Common
		props = compositeElementCache._myProperties
		layoutManager = me.layoutManager

		cm.updateCommon me, props
		me.cache = compositeElementCache
		newContentDefs = me.genContentDefs()
		layoutManager.updateContentDefs newContentDefs
		bottomContainerArr = Ext.ComponentQuery.query('container[bottomContainer=true]', this)
		if bottomContainerArr
			Ext.Array.each bottomContainerArr, (bottomContainer) ->
				if bottomContainer.ownerCt is me
					me.remove bottomContainer
					return
		Corefw.util.Render.renderNavs props, this, null, null, @navAlign
		me.elementsResized = false

		if not me.rendered
			return

		# onRefresh is deprecated, Remove onRefresh Event when we don't support
		evt = Corefw.util.Event
		if @compositeElementONREFRESHevent
			evt.fireRenderEvent this

		if layoutManager.type is 'tab'
			previousActiveTabPath = layoutManager.getActiveTabPath()

		# if layoutManager instanceof Corefw.view.layout.TabLayoutManager
		for key, childCache of compositeElementCache
			continue if key is '_myProperties'
			props = childCache._myProperties
			coretype = props?.coretype?.toLowerCase()
			switch coretype
				when 'element', 'compositeelement'
					if props.active
						targetActiveTabPath = props.uipath
					me.updateChild childCache

		if layoutManager.type is 'tab'
			if previousActiveTabPath isnt targetActiveTabPath
				layoutManager.setActiveTab targetActiveTabPath
		return

# determine whether the compositeelement content component has header
	isChildWithHeader: (cache) ->
		for contentKey, contentCache of cache
			if contentKey isnt '_myProperties'
				contentProps = contentCache._myProperties
				switch contentProps?.widgetType
					when 'COMPOSITE_ELEMENT', 'FORM_BASED_ELEMENT'
						if not Ext.isEmpty contentProps.title
							hasTitleBar = true
					when 'PIVOTGRID'
						if contentProps.showTitleBar is true
							hasTitleBar = true
		return hasTitleBar