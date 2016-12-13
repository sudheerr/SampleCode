Ext.define 'Corefw.store.DomainTreeNode',
	extend: 'Ext.data.TreeStore'
	requires: [ 'Corefw.model.DomainTreeNode' ]
	model: 'Corefw.model.DomainTreeNode'
	autoLoad: false
	clearOnLoad: true
	constructor: (config) ->
		@currentSearchPath = null
		@domainName = null
		# set sendRequest to false will stop loading data
		@sendRequest = true
		@callParent arguments
		return
	proxy:
		type: 'rest'
		appendId: false
		actionMethods:
			read: 'POST'
		url: 'api/pivot/domainTree'
		reader:
			type: 'json'
	listeners:
		beforeload: (me, operation, eOpts) ->
			console.time 'Tree load finished'
			nodeId = undefined
			isCallForFocus = operation.params.isCallForFocus
			path = operation.params.path
			@currentSearchPath = path
			if operation is null
				return false
			node = operation.node
			search_s = Ext.String.trim(@ownerTree.down('combo').rawValue)
			if search_s.length > 2
				@sendRequest = true
			else
				search_s = ''
			if node and node.data
				console.log 'load children for node:' + node.data.text
				nodeId = node.data.path
			if node.isRoot()
				# a seperate small loading mark will be shown
				# up each time expanding a child node
				nodeId = null
				me.ownerTree.setLoading 'Loading'
			#TBD: fake getNodesMD()
			p = 
				getNodesMD: ->
					'All'
				getDepth: ->
					'5'
				getProminence: ->
					'Med'
				getFilterBy: ->
					'NAME'
			operation.params =
				domainName: @domainName
				uipath: @uipath
				parentPathString: nodeId
				searchString: ''
				searchMeasureDimension: p.getNodesMD()
				searchDepth: p.getDepth().toString()
				searchProminence: p.getProminence()
				searchFilterBy: p.getFilterBy()
				isCallForFocus: isCallForFocus
				path: path
			true
		load: (th, node, records, successful, eOpts) ->
			console.timeEnd 'Tree load finished'
			me = th
			tc = undefined
			if successful
				f_val = Ext.String.trim me.ownerTree.down('combo').rawValue
				if f_val.length > 2
					@applySnapshot f_val
					tc = @getLeafCount me.getRootNode()
					Ext.Array.each me.getRootNode().childNodes, ((item, index) ->
						if index is 0
							@expandNode item, true
							return false
						return
					), me.ownerTree
					if th.currentSearchPath
						path = th.currentSearchPath
						root = th.getRootNode()
						currentRoot = root.childNodes[1]
						breakFlag = false
						v = me.ownerTree
						while not breakFlag
							if currentRoot
								v.expandNode currentRoot, false
								currentChildNodes = currentRoot.childNodes
								i = 0
								while i < currentChildNodes.length
									if currentChildNodes[i].get('leaf')
										i++
										continue
									if path.indexOf(currentChildNodes[i].get('path')) isnt -1
										i++
										continue
									if path is currentChildNodes[i].get 'path'
										v.expandNode currentChildNodes[i], false
										breakFlag = true
										break
									else
										loc = path.indexOf currentChildNodes[i].get('path')
										curLength = currentChildNodes[i].get('path').length
										substring = path.substring(loc + curLength)
										if substring.charAt(0) is '/'
											v.expandNode currentChildNodes[i], false
										else
											i++
											continue
									currentRoot = currentChildNodes[i]
									break
									i++
							if breakFlag
								break
				else
					@sendRequest = false
					delete @snapshot
					Ext.Array.each me.getRootNode().childNodes, ((item, index) ->
						@expandNode item, false
						return
					), me.ownerTree
			else
				Corefw.Msg.alert 'Error', 'Tree data load error.'
			#TBD: following two lines are temporarily commented out
			#p =Ext.ComponentQuery.query('toptabpanel')[0].getActiveTab();
			#me.ownerTree.changeSettings(p);
			me.ownerTree.setLoading false
			return
	getLeafCount: (Mynode) ->
		tc = 0

		recurFunc = (Node) ->
			if Node.hasChildNodes()
				tc += Node.childNodes.length
				Node.eachChild recurFunc
			else
				return 0
			return

		if Mynode.hasChildNodes()
			tc += Mynode.childNodes.length
			Mynode.eachChild recurFunc
		tc
	applyFilters: (filters) ->
		me = this
		decoded = me.decodeFilters(filters)
		i = 0
		length = decoded.length
		node = undefined
		visibleNodes = []
		resultNodes = []
		root = me.getRootNode()
		flattened = me.tree.flatten()
		items = undefined
		item = undefined
		fn = undefined

		###*
		# @property {Ext.util.MixedCollection} snapshot
		# A pristine (unfiltered) collection of the records in this store. This is used to reinstate
		# records when a filter is removed or changed
		###

		me.snapshot = me.snapshot or me.getRootNode().copy(null, true)
		i = 0
		while i < length
			me.filters.replace decoded[i]
			i++
		#collect all the nodes that match the filter
		items = me.filters.items
		length = items.length
		i = 0
		while i < length
			item = items[i]
			fn = item.filterFn or (item) ->
				item.get(item.property) is item.value
			visibleNodes = Ext.Array.merge(visibleNodes, Ext.Array.filter(flattened, fn))
			i++
		#collect the parents of the visible nodes so the tree has the corresponding branches
		length = visibleNodes.length
		i = 0
		while i < length
			node = visibleNodes[i]
			node.bubble (n) ->
				if n.parentNode
					resultNodes.push n.parentNode
				else
					return false
				return
			i++
		visibleNodes = Ext.Array.merge(visibleNodes, resultNodes)
		#identify all the other nodes that should be removed (either they are not visible or are not a parent of a visible node)
		resultNodes = []
		root.cascadeBy (n) ->
			if !Ext.Array.contains(visibleNodes, n)
				resultNodes.push n
			return
		#we can't remove them during the cascade - pulling rug out ...
		length = resultNodes.length
		i = 0
		while i < length
			resultNodes[i].remove()
			i++
		#has to enable if we have to async-load trees
		#root.getOwnerTree().getView().refresh();
		return
	filter: (filters, value) ->
		@applyFilters filters
		return
	applySnapshot: (f_val) ->
		me = this
		delete me.snapshot
		delete me.searchS
		me.searchS = f_val
		me.snapshot = me.getRootNode().copy null, true
		return
	clearFilter: (suppressEvent) ->
		me = this
		me.filters.clear()
		if me.isFiltered()
			me.setRootNode me.snapshot
			delete me.snapshot
		return
	isFiltered: ->
		snapshot = @snapshot
		! !snapshot and snapshot isnt @getRootNode()