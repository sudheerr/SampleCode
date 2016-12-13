Ext.define 'Corefw.view.tree.DomainTree',
	extend: 'Ext.tree.Panel'
	alias: 'widget.domainTree'
	requires: [
		'Ext.tree.plugin.TreeViewDragDrop'
		'Corefw.store.DomainTreeNode'
		'Corefw.view.filter.plugin.MenuFactory'
		'Corefw.store.DomainTreeLNode'
	]
	mixins: [
		'Corefw.mixin.Sharable'
		'Corefw.mixin.UiPathAware'
	]
	border: true
	autoScroll: true
	height: '100%'
	cls: 'orr-tree'
	overflowY: 'auto'
	plugins:
		ptype: 'filtermenufactory'
		extraParams: ->
			return domainName: @getShared 'domainName'
		beforecreate: (view, record) ->
			if record.isLeaf() and not record.get('isItemList')
				return true
	viewConfig:
		plugins:
			ptype: 'treeviewdragdrop'
			enableDrop: false
			appendOnly: true
			dragGroup: 'treeDrop'
	selModel:
		xtype: 'rowmodel'
		mode: 'MULTI'
	rootVisible: false
	treeCollapse: true
	constructor: ->
		@isRootLoaded = false
		@forceReloadRoot = false
		@timeOfPreviousChangeEvent = 0
		@timeOfCurrentChangeEvent = 0
		@settings =
			prominence: null
			nodesMD: null
			filterBy: null
			depth: null

		@changeSettings = (setting) ->
			presentSetting = @settings
			equal = presentSetting.prominence is setting.getProminence() and 
				presentSetting.nodesMD is setting.getNodesMD() and 
				presentSetting.filterBy is setting.getFilterBy() and 
				presentSetting.depth is setting.getDepth()
			if equal
				false
			else
				presentSetting.prominence = setting.getProminence()
				presentSetting.nodesMD = setting.getNodesMD()
				presentSetting.filterBy = setting.getFilterBy()
				presentSetting.depth = setting.getDepth()
				true

		@callParent arguments
		return

	listeners:
		beforeitemclick: (me, record, item, index, e) ->
			if e.ctrlKey
				return false
			return
		afterrender: ->
			@binduipath()
			domainName = @getShared 'domainName'
			if domainName
				@loadDomainData domainName, @parentuipath
			else
				@onSharedUpdate 'domainName', (domainName) ->
					@loadDomainData domainName, @parentuipath
				, this
			return

	locateNodeByPath: (path, domains, startIndex) ->

		expandParentNode = (node, callback) ->
			pNode = node.parentNode
			if !pNode or pNode.isExpanded()
				if callback
					callback()
			else
				pNode.expand false, ->
					expandParentNode pNode, callback
					return
			return

		if not domains
			domains = []
			pathSeprator = /\/D:[^:]+-[RI]:[^:\/]+/g
			result = pathSeprator.exec path
			while result
				domains.push result[0]
				result = pathSeprator.exec path
		if not startIndex
			startIndex = 1
		lastNode = undefined
		me = this
		i = startIndex
		while i <= domains.length
			targetPath = domains.slice(0, i).join ''
			node = @getNodeByPath targetPath, true, lastNode
			if not node.isExpanded()
				if targetPath is path
					selModel = @getView().getSelectionModel()
					expandParentNode node, ->
						selModel.select node
						return
				else
					node.expand false, ->
						me.locateNodeByPath path, domains, i + 1
						return
				break
			else
				lastNode = node
			i++
		return
	getNodeByPath: (path, deepSearch, node) ->
		if not node
			node = @getStore().getRootNode()
		node.findChild 'path', path, deepSearch
	collapseAllOthers: (node) ->
		p = undefined
		c = undefined
		p = node.parentNode
		if not p or not p.parentNode
			return
		c = p.childNodes

		# use the table-view of the tree-panel,instead of nodeInterface to collapse other nodes,
		# in case that the child nodes will duplicate

		tree = @view
		Ext.each c, (cNode, nodeIndex, allChildNodes) ->
			if cNode isnt node and cNode.isExpanded()
				tree.collapse cNode, true
			return
		return
	dockedItems:
		xtype: 'toolbar'
		dock: 'top'
		layout: 'hbox'
		listeners: beforerender: (me, eOpts) ->
			su = Corefw.util.Startup
			if su.getThemeVersion() is 2
				me.margin = '6 0 0 0'
				me.style = backgroundColor: '#d5d6d7'
			return
		items: [
			{
				xtype: 'combo'
				flex: 1
				emptyText: 'Enter Minimum 3 chars'
				hideTrigger: true
				cls: 'search-tree-node'
				queryMode: 'remote'
				valueField: 'text'
				displayField: 'text'
				minChars: 3
				typeAhead: false
				hideLabel: true
				store: Ext.create 'Corefw.store.DomainTreeLNode',
					listeners:
						beforeload: (me, operation, eOpts) ->
							if operation.params.query is ''
								return false
							operation.params =
								domainName: me.view.up('domainTree').getShared 'domainName'
								searchString: operation.params.query
								prominence: 'Med'
							me.removeFilter()
							me.removeAll()
							true
						load: (me, records) ->
							getPathDepth = (path) ->
								reg = /\/D:([^-:\/]+)(-I:|-L:|-R:)([^-:\/]+)/g
								result = undefined
								pathDepth = 0
								loop
									result = reg.exec(path)
									if result
										if not pathDepth
											pathDepth += 2
										else
											pathDepth++
									else
										break
								pathDepth
							me.view.removeCls 'no-border'
							lastMinDepthIndex = -1
							count = 0
							minDepth = Ext.Array.min(records.map((rec)->getPathDepth(rec.data.path))) or -1
							me.addFilter [ (item) ->
								if item.data.path
									if getPathDepth(item.data.path) <= minDepth
										item.data.isMinDepth = true
										count++
										if lastMinDepthIndex isnt -1
											records[lastMinDepthIndex].data.isLastMinDepth = false
											lastMinDepthIndex = item.index
											records[lastMinDepthIndex].data.isLastMinDepth = true
										else
											lastMinDepthIndex = item.index
											records[lastMinDepthIndex].data.isLastMinDepth = true
										if count is records.length
											records[lastMinDepthIndex].data.isLastMinDepth = false
										return true
									else
										item.data.isMinDepth = false
										return false
								return
							]
							return
				listeners:
					beforerender: (me, eOpts) ->
						su = Corefw.util.Startup
						if su.getThemeVersion() is 2
							me.overCls = 'fieldOverCls'
							me.height = 24
							delete me.cls
							me.fieldStyle =
								lineHeight: '22px'
								paddingLeft: '26px'
						return
					boxready: (me) ->
						w = me.getWidth() - 2
						@listConfig.emptyText = '<div class="x-boundlist-item" style="width:' + w + 'px;">No matching found.</div>'
						return
					resize: (me) ->
						viewSize = Ext.getBody().getSize()
						@listConfig.maxHeight = viewSize.height - (me.getXY()[1]) - 30
						@listConfig.maxWidth = viewSize.width - 30
						return
				matchFieldWidth: false
				listConfig:
					loadingText: 'Searching...'
					resizable: true
					cls: 'no-border'
					listeners:
						itemclick: (list, record, e) ->
							if record.data.isLastMinDepth
								record.data.isLastMinDepth = false
								list.getStore().removeFilter()
							false
						render: (v, eOpts) ->
							v.store.view = v
							v.dragZone = Ext.create 'Ext.dd.DragZone', v.getEl(),
								ddGroup: 'treeDrop'
								getDragData: (e) ->
									sourceEl = e.getTarget(v.itemSelector, 10)
									itemIndex = v.getRecord(sourceEl).index
									if v.store.isFiltered()
										Ext.Array.each v.store.data.items, (item, i, self) ->
											if item.index is itemIndex
												itemIndex = i
												return false
											return
									if sourceEl
										d = sourceEl.getElementsByTagName('span')[0].cloneNode(true)
										d.id = Ext.id()
										return {
											view: v
											ddel: d
											sourceEl: sourceEl
											repairXY: Ext.fly(sourceEl).getXY()
											records: [ v.store.getAt(itemIndex) ]
											sourceStore: v.store
											draggedRecord: v.getRecord(sourceEl)
										}
									return
								getRepairXY: ->
									@dragData.repairXY
							return
				tpl: Ext.create 'Ext.XTemplate',
					'<tpl for=".">',
					'<div class="x-boundlist-item iem-Combo textOverFlowCls" data-qtitle="{[this.title(values)]}" data-qtip="{[values.path]}">',
					'<span class="x-grid-row x-grid-data-row"> {[this.getMatch(values) + " (" + this.getPath(values) + ")"]}</span>',
					'{[this.getOption(values)]}',
					'</div>', '</tpl>',
					title: (input) ->
						(if input.measure then 'Measure' else 'Dimension') + ' - ' + input.prominence
					highlightMatch: (input) ->
						searchQuery = Ext.String.trim(input.qtip)
						searchQueryRegex = new RegExp('(' + searchQuery + ')', 'i')
						highlightedMatch = '<span class="searchMatch">$1</span>'
						input.text.replace searchQueryRegex, highlightedMatch
					getMatch: (input) ->
						searchQuery = Ext.String.trim(input.qtip)
						searchQueryRegex = new RegExp('(' + searchQuery + ')', 'i')
						highlightedMatch = '$1'
						input.text.replace searchQueryRegex, highlightedMatch
					getPath: (input) ->
						input.facadePathString
					getOption: (input) ->
						str1 = '<br><span class="x-grid-row x-grid-data-row" align="left">Click to view more...</span>'
						if input.isLastMinDepth
							str1
						else
							return
				editable: true
			}
			{
				xtype: 'tool'
				type: 'gear'
				cls: 'icon-settings'
				tooltip: 'Settings'
				width: 24
				height: 24
				hidden: true
				padding: '2 2 2 2'
				handler: (e, toolEl, owner, tool) ->
					return
				setHidden: ->
					@toolEl.setStyle visibility: 'hidden'
					return
				setVisible: ->
					@toolEl.setStyle visibility: 'visible'
					return
			}
		]

	loadDomainData: (qualifiedDomainName, uipath) ->
		me = this
		domainName = qualifiedDomainName
		treeStore = me.store
		if not domainName
			return
		if me.isRootLoaded and not me.forceReloadRoot
			return
		me.isRootLoaded = true
		if treeStore is null or not (treeStore instanceof Corefw.store.DomainTreeNode)
			treeStore = Ext.create 'Corefw.store.DomainTreeNode',
				domainName: domainName
				uipath: uipath
			me.bindStore treeStore
		treeStore.clearFilter true
		treeStore.load()
		return