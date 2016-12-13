# top container for a view that contains subnavigation elements

Ext.define 'Corefw.view.crview.ViewSubnav',
	extend: 'Ext.Container'
	xtype: 'coreviewsubnav'

	layout: 'border'

	initComponent: ->
		@callParent arguments

		uip = Corefw.util.Uipath

		cache = @cache
		props = cache._myProperties
		parentCache = uip.uipathToParentCacheItem props.uipath

		# at this point, we know we have subnav views
		# from parentCache, loop through all views and add subnav views in correct place
		for key, viewCache of parentCache
			if key isnt '_myProperties'
				subnavprops = viewCache._myProperties.subnavigator
				if subnavprops
					newview = Corefw.mixin.Perspective.configView viewCache
					addlConfigs =
						collapsible: subnavprops.collapsible
						collapsed: subnavprops.collapsed
						split: subnavprops.resizable
						cls: 'viewsubnav-nav'

					if subnavprops.collapsible
						addlConfigs.split = true

					if not subnavprops.collapsed
						# set some initial width, will get resized immediately
						addlConfigs.width = 300

					Ext.apply newview, addlConfigs

					subnavAlign = subnavprops.align
					if subnavAlign
						if subnavAlign is 'RIGHT'
							newview.region = 'east'
						else
							newview.region = 'west'

					@add newview


		return

	onResize: ->
		totalWidth = @getWidth()
		allViews = @items.items
		su = Corefw.util.Startup
		#props = @cache._myProperties

		for view in allViews
			if su.getThemeVersion() is 2
				if view.xtype is 'bordersplitter'
					if view.vertical
						view.setWidth 6
			subnavprops = view.cache?._myProperties?.subnavigator
		return