###
	creates a standard tree, with extra functions for Core Framework
###

Ext.define 'Corefw.view.tree.TreeBase',
	extend: 'CitiRiskLibrary.view.CitiRiskTreePanel'
	xtype: 'coretreebase'
	mixins: ['Corefw.mixin.Grid']
	viewConfig:
		getRowClass: (record, index, rowParams, ds) ->
			cls = []
			if @ownerCt.isNodeDisabled record
				cls.push 'treenode-disabled'
			if record.raw.semiSelected and record.get 'checked'
				cls.push 'x-checkbox-semi'
			if record.raw.matching
				cls.push 'x-tree-node-mark'
			return cls.join ' '

	plugins:
		ptype: 'inlinefilter'

	initComponent: ->
		@initializeTreeBase()
		@addTreeListeners()
		@callParent arguments
		return

	initializeTreeBase: ->
		cache = @cache
		props = cache?._myProperties
		su = Corefw.util.Startup
		@configurePlugins props, false
		viewConfig =
			listeners:
				viewready: @expandAllNodesOnViewReady

		if @viewConfig
			Ext.merge @viewConfig, viewConfig
		else
			@viewConfig = viewConfig


		# hide the root
		@rootVisible = false

		if @selectType in ['single', 'SINGLE']
			@viewType = 'treeradioview'
			@setColumnOption 'treeradiocolumn'
		else if @selectType in ['multiple', 'MULTIPLE'] and props.widgetType isnt 'TREE_GRID'
			@setColumnOption 'treecheckboxcolumn'

		if not su.useClassicTheme()
			@ui = 'citirisktreeview'
			if su.getThemeVersion() is 2
				@ui = 'citirisktreeui'
				if props.titleBackgroundIsWhite and not @lines
					@ui = 'latticetreelinesui'
				if props?.widgetType is 'TREE_GRID'# original judgement is 'not @lines'
					@addCls 'nolinescls'
		@setTreeSelectMode props?.multiSelectable
		if not props or props.widgetType isnt 'TREE_GRID'
			return
		# initially set this to false, and if we find an editable column, then set to true
		columns = @columns
		@createColumnsFromCache columns, columns

		if props.numberOfLockedHeaders > 0
			@isLockedView = true

		#seltype will only be avalible if this is a tree grid
		@configSelType()
		return

	addTreeListeners: ->
		@listeners = @listeners or {}
		listeners =
			beforeselect: @beforeItemSelect
			checkchange: @itemCheckChange

		Ext.merge @listeners, listeners
		@addListeners()

	setColumnOption: (columnXType) ->
		if @hideHeaders is undefined
			@hideHeaders = true

		@addCls @autoWidthCls
		@columns = [
			xtype: columnXType
			text: 'Name'
			dataIndex: @displayField
		]
		return

	isNodeDisabled: (nodeOrModel) ->
		return nodeOrModel?.raw?.disabled

	setTreeSelectMode: (isMultiSelect) ->
		if isMultiSelect
			@selModel =
				xtype: 'rowmodel'
				mode: 'MULTI'
		return

	setNodeDisabled: (node) ->
		if @isNodeDisabled node
			className = ' treenode-disabled'
			treeview = @getView()
			htmlelement = treeview.getNode node
			if htmlelement.className.indexOf(className) < 0
				htmlelement.className += className
		return

	getNodeIndex: (node, parent = @store.tree.root, counter = -1) ->
		for pn in parent.childNodes
			if node.stop
				delete node.stop
				return counter
			counter++
			if node is pn
				node.stop = true
				return counter
			else
				counter = @getNodeIndex node, pn, counter
		return counter

	beforeItemSelect: (rowmodel, rec, index) ->
		if @isNodeDisabled rec
			return false
		return true

# called when the checkbox changes
# if node is disabled, uncheck the box and re-apply the style
	itemCheckChange: (node, newCheckState, eOpts) ->
		view = @view
		# code this for mocking readOnly
		if view.disableSelection
			node.set 'checked', not node.get 'checked'
			return false
		props = @cache?._myProperties
		if props.enableClientSideSelectAll
			allnodes = @getView().node
			@selectAllNodes node, allnodes, newCheckState

		selectType = props?.selectType.toLowerCase()
		originalNode = node
		# do nothing for single select

		if selectType is 'single'
			return

		if selectType in 'single'
			return

		# undo the check if we tried to set a disabled node to TRUE
		if @isNodeDisabled node
			# uncheck the node
			node.set 'checked', not newCheckState

			# set the class to disabled
			@setNodeDisabled node
			return

		# have to write our own cascade functionality because we want to skip
		# disabled node and their children
		me = this

		cascadeCheck = (newnode) ->
			childNodes = node.childNodes
			if childNodes and childNodes.length
				for node in childNodes
					# updated the cascade logic to ignore nodes that are disabled.
					# New Requirement for FAP and CDM
					if not node.raw.disabled
						cascadeCheck node

			if newCheckState
				if isFirstLevelChildNodesAllChecked newnode
					setNodeNotSemiSelected newnode, newCheckState
				else
					setNodeSemiSelected newnode
			else
				if isFirstLevelChildNodesAllUnChecked newnode
					setNodeNotSemiSelected newnode, newCheckState
			return
		#updated the bubleup logic to ignore nodes that are disabled.
		#New Requirement for FAP and CDM
		bubleUp = (node, checkSate) ->
			parentNode = node.parentNode

			#TODO Ideally, the child nodes of a disabled parent shouldn't be enabled.
			#This is a contradicting scenario.
			if parentNode.raw.disabled
				return

			if checkSate
				conditionFn = isFirstLevelChildNodesAllChecked
			else
				conditionFn = isFirstLevelChildNodesAllUnChecked
			if conditionFn parentNode
				setNodeNotSemiSelected parentNode, checkSate
			else
				setNodeSemiSelected parentNode

			if parentNode.parentNode
				bubleUp parentNode, checkSate
			return

		isFirstLevelChildNodesAllChecked = (parentNode) ->
			childNodes = parentNode.childNodes
			for node in childNodes
				checked = node.get 'checked'
				semiSelected = node.raw.semiSelected
				if not semiSelected and checked
					continue
				else
					return false
			return true

		isFirstLevelChildNodesAllUnChecked = (parentNode) ->
			childNodes = parentNode.childNodes
			for node in childNodes
				if node.get 'checked'
					return false
			return true

		setNodeSemiSelected = (node) ->
			node.raw.semiSelected = true
			node.set 'checked', true
			el = Ext.fly view.getNode node
			if el and not el.is '.x-checkbox-semi'
				el.addCls 'x-checkbox-semi'
			return

		setNodeNotSemiSelected = (node, checked) ->
			node.raw.semiSelected = false
			node.set 'checked', not not checked
			el = Ext.fly view.getNode node
			if el and el.is '.x-checkbox-semi'
				el.removeCls 'x-checkbox-semi'
			return
		Ext.suspendLayouts()
		cascadeCheck node
		bubleUp node, newCheckState
		Ext.resumeLayouts()
		originalNode.isEditing = true
		treeField = @up()
		events = props.events or {}
		rq = Corefw.util.Request
		url = rq.objsToUrl3 events['ONCHANGE']
		if treeField? and url?
			postData = treeField.generatePostData()
			if props.enableClientSideSelectAll
				allTopLevelNodes = postData.allTopLevelNodes
				if props.selectallnode
					allTopLevelNodes.shift()
			@sendTreePostData url, postData
		originalNode.isEditing = false
		return

	expandAllNodesOnViewReady: (view) ->
		fn = Ext.Function.createDelayed ->
			return unless view.el
			fc = view.up 'fieldcontainer'
			expandAllNodes = fc.cache?._myProperties?.expandAllNodes
			view.expandAll() if expandAllNodes
			return
		, 1
		fn()

	sendTreePostData: (url, postData) ->
		rq = Corefw.util.Request
		props = @cache._myProperties
		uipath = props.uipath
		rq.sendRequest5 url, rq.processResponseObject, uipath, postData, null, null, null, null
		return

	afterRender: ->
		@callParent arguments
		@setSelection()
		elementForm = @up 'coreelementform'
		fieldProps = @cache?._myProperties
		layoutManager = elementForm?.layoutManager
		if layoutManager and layoutManager.setMaxAndMixHeight
			layoutManager.setMaxAndMixHeight @up(), fieldProps
		# to avoid trigger onSelect event before rendered
		@up()?.enableSelectEvent = true
		return

	setSelection: ->
		me = this
		me.suspendEvents()
		selectArray = []
		st = @store

		nodeHash = st?.tree?.nodeHash
		return unless nodeHash
		for i, node of nodeHash
			props = if node.raw._myProperties then node.raw._myProperties else node.raw
			if props and props.selected
				selectArray.push node

		if selectArray.length
			me.getSelectionModel().select selectArray, false, true
		me.resumeEvents()
		return

	styleDecorate: ->
		store = @getStore()
		nodeHash = store.tree.nodeHash
		for key, node of nodeHash
			props = node.raw._myProperties
			if key is 'root' or not props
				continue
			errorMsgs = props.messages?.ERROR
			cssClass = props.cssClass
			view = @getView()

			for pathString, errMsg of errorMsgs
				oneErrMsg = errMsg.join ';'
				col = @down '[pathString=' + pathString + ']'
				record = view.getRecord node
				if not record or not col
					continue
				cell = view.getCell record, col
				cell.addCls 'x-grid-cell-error'
				Ext.create 'Ext.tip.ToolTip',
					target: cell.id
					html: oneErrMsg + '\n<br>'
					ui: 'form-invalid'

			if cssClass?
				normalNode = view.getNode node, true
				if not normalNode
					return
				normalNodeCmp = Ext.get normalNode
				normalNodeCmp.addCls cssClass
				if view.lockedView
					lockedNode = view.lockedView.getNode node, true
					lockedNodeCmp = Ext.get lockedNode
					lockedNodeCmp.addCls cssClass
			cellCssClassObj = node.raw._myProperties.cellCssClass

			for pathString, cellCssClass of cellCssClassObj
				col = @down '[pathString=' + pathString + ']'
				record = view.getRecord node
				if not record or not col
					continue
				cell = view.getCell node, col
				cell.addCls cellCssClass if cell
		return

	selectAllNodes: (node, allnodes, newCheckState) ->
		childNodes = allnodes.childNodes
		if node.data[0] is 'Select All'
			for eachnode in childNodes
				continue if @isNodeDisabled eachnode
				eachnode.set 'checked', newCheckState
		else
			node.set 'checked', newCheckState
			if not newCheckState
				childNodes[0].set 'checked', newCheckState
			for eachnode in childNodes
				if eachnode.data[0] is 'Select All'
					continue
				nodeselect = eachnode.data.checked
				if not nodeselect
					return
			childNodes[0].set 'checked', newCheckState
		return

	traverseNodes: (nodes, childrenNodeName, fn) ->
		for node in nodes
			fn? node
			childrenNodes = node[childrenNodeName]
			if childrenNodes.length > 0
				@traverseNodes childrenNodes, childrenNodeName, fn
		return