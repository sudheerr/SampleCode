# functions to target a specific component in the app, using the "uipath" property
#		attached to each component from the server

Ext.define 'Corefw.util.Uipath',
	singleton: true


# assumption: uipath property is in cache._myProperties.uipath
	cacheToUipath: (cache) ->
		return cache?._myProperties?.uipath

# return the component that matches this "uipath"
	uipathToComponent: (uipath) ->
		if uipath
			ar = Ext.ComponentQuery.query "[uipath=\"#{uipath}\"]"
			if ar and ar.length
				return ar[0]
		return

	uipathToComponentInElement: (uipath, element) ->
		if uipath
			ar = Ext.ComponentQuery.query "[uipath=\"#{uipath}\"]", element
			if ar and ar.length
				return ar[0]
		return


	uipathToParentUipath: (uipath) ->
		if uipath
			ar = uipath.split '/'
			ar.pop()
			return ar.join '/'
		return ''


	uipathToParentComponent: (uipath) ->
		parentUipath = @uipathToParentUipath uipath
		if parentUipath
			return @uipathToComponent parentUipath
		return


# return the last part of the path
	uipathToShortName: (uipath) ->
		if uipath
			ar = uipath.split '/'
			if ar and ar.length
				return ar[ar.length - 1]
		return ''


# given a uipath, will return the tab number of the component
	uipathToTabNumber: (uipath) ->
		# get tab number based on uipath
		comp = @uipathToComponent uipath
		if not comp
			return -1

		cache = comp.cache
		props = cache?._myProperties

		if not props
			return 0

		uniqueKey = props.uniqueKey
		name = props.name
		if not name and not uniqueKey
			return 0

		parentComponent = comp.up 'tabpanel'
		items = parentComponent?.items?.items

		if not items
			return 0

		tabnum = 0
		for item, i in items
			if uniqueKey
				if item.uniqueKey is uniqueKey
					tabnum = i
					break
			else if item.cache and item.cache._myProperties.name is name
				tabnum = i
				break

		return tabnum


	uipathActivateTab: (uipath) ->
		cache = @uipathToCacheItem uipath
		props = cache?._myProperties

		uniqueKey = props.uniqueKey
		name = props.name

		comp = @uipathToComponent uipath
		parentComponent = comp.up 'tabpanel'
		items = parentComponent.items.items

		for item in items
			if uniqueKey
				if item.uniqueKey is uniqueKey
					parentComponent.setActiveTab item
					return
			else if item.cache and item.cache._myProperties.name is name
				parentComponent.setActiveTab item
				if item.coretype is 'view'
					toptabpanel = parentComponent.up 'toptabpanel'
					toptabpanel?.setActiveTab parentComponent
				return

		return

# if cache scope is assigned then regressively search, otherwise search for existing component and find its' related cache
	uipathToCacheItem: (uipath, cache) ->
		if not uipath
			return
		if cache
			for item, oneCache of cache
				if item is '_myProperties'
					if oneCache.uipath is uipath
						return cache
				else if oneCache._myProperties
					result = arguments.callee uipath, oneCache
					if result
						return result
		else
			comp = @uipathToComponent uipath
			if comp
				return comp.cache
		return

# given a breadcrumb, will return the cache item associated with that object
	uipathToParentCacheItem: (uipath) ->
		comp = @uipathToParentComponent uipath
		if comp
			return comp.cache
		return

# toolbar in workflow is weird, partly method here
	uipathToPostContainer: (uipath) ->
		uip = Corefw.util.Uipath
		parentUipath = uip.uipathToParentUipath uipath
		if parentUipath
			comp = uip.uipathToComponent parentUipath
		if comp.coretype is 'perspective'
			return comp

		return uip.uipathToPostContainer parentUipath