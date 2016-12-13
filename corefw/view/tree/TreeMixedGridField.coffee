Ext.define 'Corefw.view.tree.TreeMixedGridField',
	extend: 'Corefw.view.tree.TreeFieldBase'
	xtype: 'coretreemixedgrid'

	initComponent: ->
		@initalizeTreeMixedGrid()
		@callParent arguments
		@addCls 'backgroundcolorset'
		return


	initalizeTreeMixedGrid: ->
		cm = Corefw.util.Common
		cache = @cache
		props = cache._myProperties

		@treeList = {}

		# rename items to grid
		cm.objRenameProperty props, 'items', 'grid'

		if props.grid
			gridList = {}
			props.gridList = gridList
			# this is actually an array
			for grid in props.grid
				gridList[grid.name] = grid

		return


	# this class actually doesn't contain an onExpand event
	# will attach it to the tree in this field
	onTreeItemExpand: (record, index, treenodeDom) ->
		if record.ignoreExpandEvent
			delete record.ignoreExpandEvent
			return

		record.ignoreExpandEvent = true
		@onClickTreeMixedGrid record, treenodeDom, index
		return


	configureTree: ->
		@firstColumnName = 'text'
		@displayField = @firstColumnName
		return


	onClickTreeMixedGrid: (record, treenodeDom, index, ev) ->
		if record.data.root
			return

		# this is a hack to make sure that treeview was clicked instead of something else
		targetid = ev?.target?.id

		if not Ext.String.startsWith treenodeDom.id, 'treeview'
			@tree.getSelectionModel().deselectAll()
			ev.stopEvent()
			return

		if targetid and not Ext.String.startsWith targetid, 'treeview'
			@tree.getSelectionModel().deselectAll()
			ev.stopEvent()
			return

		if not treenodeDom.expanded
			@createTreeNode record, treenodeDom
		else
			@deleteTreeNode record, treenodeDom

		if ev
			ev.stopEvent()

		@tree.getSelectionModel().deselectAll()

		return


	createTreeNode: (record, treenodeDom) ->
		# data to be shown in this grid
		gridDataItems = record?.raw?.grid
		if not gridDataItems
			return
		treenodeDom.expanded = true
		record.set 'expanded', true
		treepanel = @tree

		gridConfig =
			parentContainer: this
			treepanel: treepanel
			mixedgrid: this
			treenodeDom: treenodeDom
			treeRecord: record
			gridDataItems: gridDataItems
			cache: @cache

		panel = Ext.create 'Corefw.view.grid.Treenode', gridConfig
		@treeList[panel.name] = panel
		console.log 'treenode uipath: ', panel.uipath

		treenodeDom.panel = panel

		panelHeight = panel.getHeight()
		treepanel.setHeight treepanel.getHeight() + panelHeight
		return


	deleteTreeNode: (record, treenodeDom) ->
		record.set 'expanded', false
		record.ignoreExpandEvent = false
		grid = treenodeDom.panel
		grid?.destroy?()
		delete treenodeDom.panel
		treenodeDom.newdiv.destroy()
		delete treenodeDom.newdiv
		delete @treeList[grid.name]
		treenodeDom.expanded = false
		return


	# assumes that this is an embedded grid in a tree node
	# will replace the grid, but won't affect the parent tree node
	replaceChild: (respCache, ev) ->
		props = respCache._myProperties
		name = props.name

		treenodeComp = @treeList[name]
		if treenodeComp
			record = treenodeComp.treeRecord
			treenodeDom = treenodeComp.treenodeDom
			# if record raw doesn't exist, then this doesn't get attached to anything
			recordRaw = record?.raw or {}
			recordRaw.grid =
				items: props.items
				name: name
			parentCache = @cache
			parentProps = parentCache._myProperties

			# update the cache
			parentCache[name] = respCache

			# create a new data item
			newDataItem =
				grid:
					items: props.items
					name: name
				value:
					text: name

			# update the data section of the properties
			dataItems = parentProps.data
			for item, i in dataItems
				if item?.grid?.name is name
					dataItems[i] = newDataItem
					break

			@deleteTreeNode record, treenodeDom
			@createTreeNode record, treenodeDom
		return


	createStore: ->
		cache = @cache
		props = cache._myProperties

		dataCache = []
		props.data = dataCache

		fields = [
			name: 'text'
		]
		storeName = props.uipath + '-Store'

		storeChildrenArray = []

		storeConfig =
			extend: 'Ext.data.TreeStore'
			autoDestroy: true
			fields: fields
			storeId: storeName
			root:
				id: 'root'
				text: 'Root'
				expandable: true
				children: storeChildrenArray
			proxy:
				type: 'memory'

		# each grid is stored in the "allContents" array
		index = 0
		for gridInfo in props.allContents
			text = gridInfo.title or gridInfo.name
			dataObj =
				id: index++
				text: text
				expandable: true
				grid:
					name: gridInfo.name
					items: gridInfo.items
			storeChildrenArray.push dataObj

			infoObj =
				grid:
					name: gridInfo.name
					items: gridInfo.items
				value:
					text: gridInfo.name
			dataCache.push infoObj

		# see if a store already exists
		# if so, delete it
		oldSt = Ext.getStore storeName
		if oldSt
			oldSt.destroyStore()

		# create the new store
		st = Ext.create 'Ext.data.TreeStore', storeConfig
		return st


	statics:
		createDataCache: (dataFieldItem, fieldCache) ->