###
	Defines a grid to be shown underneath the tree node.
	Activated by clicking on the tree node to show the grid.
	Clicking on the tree node again will hide (actually, destroy) the grid
###
Ext.define 'Corefw.view.grid.Treenode',
	extend: 'Corefw.view.grid.GridBase'
	xtype: 'coregridintreenode'

	minHeight: 50
	header: false

	initComponent: ->
		@initializeTreeNode()
		@callParent arguments

		delete @storeAlreadyAttached
		return

	initializeTreeNode: ->
		parentContainer = @parentContainer # parent fieldContainer class
		treepanel = @treepanel # parent treepanel
		treenodeDom = @treenodeDom # DOM object of the tree node
		gridDataItems = @gridDataItems # array of data items to insert into this grid
		treeCache = @cache

		props = treeCache._myProperties
		@uipath = props.uipath

		if props.widgetType is 'MIXED_GRID'
			# every single format is different, each requiring a different function
			# need to integrate the two initialize functions eventually
			@initializeMixedGridTreeNode()
			return
		#TODO code never comes down ..... ,if need uncomment it
		# gridList is hash of all grids in this tree, indexed by name of the grid
		#		gridList = props.gridList
		#
		#		if not gridList
		#			# new JSON
		#			gridName = gridDataItems.name
		#			gridProps = gridDataItems
		#			columnInfoArray = gridDataItems.allContents
		#		else
		#			# old JSON
		#			gridName = gridDataItems.name
		#			gridProps = gridList[gridName]
		#			columnInfoArray = gridProps.items
		#
		#		storeName = parentContainer.uipath + '/' + gridName
		#
		#		span = Ext.dom.Query.selectNode 'span', treenodeDom
		#		domspan = new Ext.dom.Element.Fly span
		#
		#		# create a new DIV in the span, and indent it by the amount of the node
		#		newdiv = domspan.createChild()
		#		leftOffset = domspan.dom.offsetLeft + 5
		#
		#		treenodeDom.newdiv = newdiv
		#
		#		# create a cache object so that GridBase knows what to do with this
		#		cache = {}
		#		@cache = cache
		#
		#		cache._myProperties = gridProps
		#
		#		# set up the column information so that it resembles a normal grid,
		#		#		so that GridBase can process it
		#		for column in columnInfoArray
		#			newColCache = {}
		#			newColCache._myProperties = column
		#
		#			cache[column.name] = newColCache
		#
		#
		#		st = @createStore storeName, columnInfoArray, gridDataItems.items
		#		config =
		#			name: gridName
		#			renderTo: newdiv
		#			treepanel: treepanel
		#			selModel:
		#				selType: 'rowmodel'
		#				mode: 'SINGLE'
		#			autoDestroy: true
		#			storeAlreadyAttached: true
		#			store: st
		#			margin: '5 10 2 '+leftOffset
		#			listeners:
		##				itemdblclick: @onTreenodeItemDoubleClick
		#				itemclick: (comp, rec, item, index, e) ->
		#					e.stopEvent()
		#					return
		#
		#		if gridName
		#			config.title = gridName
		#		Ext.apply this, config
		return



	initializeMixedGridTreeNode: ->
		cm = Corefw.util.Common
		parentContainer = @parentContainer # parent fieldContainer class
		treepanel = @treepanel # parent treepanel
		treenodeDom = @treenodeDom # DOM object of the tree node
		gridDataItems = @gridDataItems # array of data items to insert into this grid
		gridList = cm.objectClone parentContainer.cache
		delete gridList._myProperties
		@gridList = gridList
		gridName = gridDataItems.name
		gridProps = gridList[gridName]
		columnInfoArray = gridProps._myProperties.columnAr
		storeName = parentContainer.uipath + '/' + gridName
		span = Ext.dom.Query.selectNode 'span', treenodeDom
		domspan = new Ext.dom.Element.Fly span
		# create a new DIV in the span, and indent it by the amount of the node
		newdiv = domspan.createChild()
		leftOffset = domspan.dom.offsetLeft + 5
		treenodeDom.newdiv = newdiv
		# create a cache object so that GridBase knows what to do with this
		@cache = gridProps
		st = @createStore storeName, columnInfoArray, gridDataItems.items
		config =
			name: gridName
			renderTo: newdiv
			uipath: gridProps?._myProperties?.uipath
			treepanel: treepanel
			selModel:
				selType: 'rowmodel'
				mode: 'SINGLE'
			autoDestroy: true
			storeAlreadyAttached: true
			store: st
			maxWidth: treepanel.getWidth() - leftOffset - 50
			margin: '5 10 2 ' + leftOffset
		#			listeners:
		#				itemdblclick: @onTreenodeItemDoubleClick

		if gridName
			config.title = gridName
		Ext.apply this, config
		return

	afterRender: ->
		@callParent arguments

		# set selection mode to SINGLE
		@getSelectionModel().setSelectionMode 'SINGLE'

		# set the cache pointer to this grid
		mixedgrid = @initialConfig.mixedgrid
		if mixedgrid
			if @gridList
				@cache = @gridList[@name]
			else
				@cache = mixedgrid.cache._myProperties.gridList[@name]
		return

#TODO the code doesn't works, comment it temperary delete it later 9/1
#	# on a double click, send the doubleclick event to the server if it exists
#	onTreenodeItemDoubleClick: (gridview, record, item, index, e) ->
#		rq = Corefw.util.Request
#		de = Corefw.util.Debug
#		store = @getStore()
#		upgrid = gridview.up 'grid'
#		if de.printOutRawResponse()
#			console.log 'item was double clicked: this, gridview, upgrid, store: ', this, gridview, upgrid, store
#
#		# events can be in two different formats, and object or an array:
#		# we have to handle both unless the treenode in TreeWithGrid is refactored for the MixedGrid event format
#		# 	events =
#		#		ONDOUBLECLICK:
#		#		_ar[1]
#		# or.......
#		#	events[1]
#		#		1: DOUBLECLICK...
#
#		gridEvents = upgrid.cache?._myProperties?.events
#		if gridEvents
#			if Ext.isArray gridEvents
#				for gridEvent in gridEvents
#					# look for doubleclick event
#					if gridEvent.type is 'ONDOUBLECLICK'
#						# this is it!
#						eventURL = gridEvent.url
#						break
#			else
#				eventURL = gridEvents.ONDOUBLECLICK?.url
#
#		console.log 'eventURL: ', eventURL
#
#		postData = upgrid.generatePostData()
#		delete postData.allContents
#
#		if e
#			e.stopEvent()
#
#		if eventURL
#			url = rq.objsToUrl3 eventURL, null
#			rq.sendRequest5 url, rq.processResponseObject, '', postData, undefined, undefined, undefined, e
#		return


# columnInfoArray: plain array containing the column information
# dataArray: data items with "value" property containing the information
	createStore: (name, columnInfoArray, dataArray) ->
		# go through cache objects, and create a lookup by PATH,
		# 	since that's how the data is indexed
		storeDataAr = []
		fields = []

		storeConfig =
			autoDestroy: true
			fields: fields
			storeId: name
			data: storeDataAr

		fieldObj = {}
		for colInfo in columnInfoArray
			colInfo = colInfo._myProperties or {}

			if colInfo.index > -1
				dataIndex = colInfo.index + ''
			else
				continue

			fieldObj[dataIndex] = colInfo
			storeFieldObj =
				name: dataIndex

			type = colInfo.type
			columnType = colInfo.columnType
			if type is 'date' or columnType is 'dateColumn'
				storeFieldObj.type = 'date'

			fields.push storeFieldObj

		if dataArray and Ext.isArray(dataArray) and dataArray.length
			for dataObj in dataArray
				valueObj = dataObj.value

				if not valueObj
					continue

				# cycle through value property and create a row and insert it into the store
				storeDataAr.push valueObj

				for path, colValue of valueObj
					type = fieldObj[dataIndex]?.type
					columnType = fieldObj[dataIndex]?.columnType
					if (type is 'date' or columnType is 'dateColumn') and colValue
						dt = new Date colValue
						valueObj[dataIndex] = dt

		Corefw.util.Data.removeStore name
		st = Ext.create 'Ext.data.Store', storeConfig
		return st