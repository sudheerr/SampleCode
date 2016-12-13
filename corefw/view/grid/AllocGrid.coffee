Ext.define 'Corefw.view.grid.AllocGrid',
	extend: 'Ext.form.FieldContainer'
	xtype: 'coreallocgrid'
	rowItemWidth: 100
	AvailAmtWidth: 130
	topHeaderItemWidth: 130

# set path property string for either new or old JSON
	pathProp: null

	layout:
		type: 'vbox'
		align: 'stretch'

	defaults:
		xtype: 'container'
		layout:
			type: 'hbox'
			align: 'stretch'

		defaults:
			xtype: 'container'

	items: [
		items: [
			itemId: 'topcorner'
		,
			flex: 1
			itemId: 'topheader'
		]
	,
		flex: 1
		items: [
			itemId: 'leftheader'
		,
			flex: 1
			itemId: 'cellarea'
			layout: 'auto'
			overflowX: 'auto'
			overflowY: 'auto'
		]
	]

	statics:
	# this is not used at all for new JSON
		createDataCache: (dataFieldItem, fieldCache) ->
			# we're not even trying to parse this
			# will have to do it later in init
			fieldCache._myProperties.data = dataFieldItem
			return


	initComponent: ->
		@disableStoreEvents = true
		@callParent arguments
		return


	afterRender: ->
		@pathProp = 'pathString'

		@callParent arguments

		# set pointers to the different containers
		@topcorner = Ext.ComponentQuery.query('#topcorner')[0]
		@leftheader = Ext.ComponentQuery.query('#leftheader')[0]
		@topheader = Ext.ComponentQuery.query('#topheader')[0]
		@cellarea = Ext.ComponentQuery.query('#cellarea')[0]

		@configureTopCornerGrid()
		@configureTopHeaderGrid()
		return


	configureTopCornerGrid: ->
		# columns for top corner grid
		props = @cache._myProperties

		rowItems = props.rowGrid.allContents
		columnItems = props.columnGrid.allContents

		gridColumns = []
		storeFieldAr = []
		storeDataAr = []

		# fill grid columns and store field definitions
		index = 0
		for row in rowItems
			colName = 'c' + index
			colObj =
				text: colName
				dataIndex: colName
				flex: 1
			gridColumns.push colObj

			fieldObj =
				name: colName
			storeFieldAr.push fieldObj
			index++

		# last column
		colObj =
			text: 'colLast'
			dataIndex: 'colLast'
			align: 'right'
			width: @AvailAmtWidth
		gridColumns.push colObj
		fieldObj =
			name: 'colLast'
		storeFieldAr.push fieldObj

		@topHeaderPathArray = []

		# fill store data
		index = 0
		for col in columnItems
			dataObj = {}
			dataObj.colLast = col.title
			storeDataAr.push dataObj

			@topHeaderPathArray.push col[@pathProp]
			index++

		# insert a row that says "Uncovered Amount"
		dataObj = {}
		dataObj.colLast = 'Uncovered Amount'
		storeDataAr.push dataObj

		storeConfig =
			fields: storeFieldAr
			data: storeDataAr
		st = Ext.create 'Ext.data.Store', storeConfig

		gridConfig =
			header: false
			viewConfig:
				stripeRows: false
			enableColumnMove: false
			enableColumnHide: false
			sortableColumns: false
			hideHeaders: true
			columns: gridColumns
			store: st
		gridConfig.width = rowItems.length * @rowItemWidth + @AvailAmtWidth

		grid = Ext.create 'Ext.grid.Panel', gridConfig
		@topcornerGrid = grid
		@topcorner.add grid

		# wait for grid to get rendered, then adjust size
		me = this
		myFunc = Ext.Function.createDelayed ->
			me.leftWidth = grid.width
			me.topcorner.setWidth me.leftWidth
			me.leftheader.setWidth me.leftWidth

			me.configureLeftHeaderGrid()
		, 1
		myFunc()
		return

	cellRenderer: (value, cell, row, rowIndex, colIndex) ->
		cell.style = 'height: 27px;'
		return value


	configureLeftHeaderGrid: ->
		cm = Corefw.util.Common

		props = @cache._myProperties

		rowDataItems = props.rowGrid.items
		rowItems = props.rowGrid.allContents

		storeFieldAr = []
		storeDataAr = []
		gridColumns = []

		# define grid columns and store fields
		index = 0
		for row in rowItems
			colObj =
				dataIndex: row[@pathProp]
				text: row.title
				padding: '0 5 0 0'

			# set the height of the first column
			if not index
				colObj.renderer = @cellRenderer
			gridColumns.push colObj

			fieldObj =
				name: row[@pathProp]
			storeFieldAr.push fieldObj
			index++

		# change the last column to a float column
		lastColIndex = gridColumns.length - 1
		colObj = gridColumns[lastColIndex]
		xtraConfig =
			xtype: 'numbercolumn'
			format: '0,000.00'
			align: 'right'
		Ext.apply colObj, xtraConfig

		@leftheaderTotalColumn = colObj.dataIndex

		# add an extra "Available Amount" column
		colObj =
			dataIndex: 'AvailAmt'
			text: 'Available Amount'
			padding: '0 5 0 0'
			width: @AvailAmtWidth
		Ext.apply colObj, xtraConfig
		gridColumns.push colObj

		# assume last column is a float
		field = storeFieldAr[lastColIndex]
		field.type = 'float'
		lastFieldName = field.name

		fieldObj =
			name: 'AvailAmt'
			type: 'float'
		storeFieldAr.push fieldObj


		# add store data
		for rowData in rowDataItems
			dataObj = cm.objectClone rowData.value
			dataObj.AvailAmt = dataObj[lastFieldName]
			storeDataAr.push dataObj

		storeConfig =
			fields: storeFieldAr
			data: storeDataAr
		st = Ext.create 'Ext.data.Store', storeConfig


		gridConfig =
			header: false
			enableColumnResize: false
			enableColumnMove: false
			enableColumnHide: false
			sortableColumns: false
			columnLines: true
			columns: gridColumns
			store: st

		grid = Ext.create 'Ext.grid.Panel', gridConfig
		@leftheaderGrid = grid

		# wait for previous grid to get rendered, then adjust size
		me = this
		myFunc = Ext.Function.createDelayed ->
			me.leftheader.add grid
			me.leftheader.setWidth me.leftWidth
		, 1
		myFunc()
		return


	configureTopHeaderGrid: ->
		# columns for top corner grid
		props = @cache._myProperties

		columnDataItems = props.columnGrid.items
		columnItems = props.columnGrid.allContents

		topHeaderPathArray = @topHeaderPathArray
		pathLen = topHeaderPathArray.length

		storeFieldAr = []
		storeDataAr = []
		gridColumns = []

		# initialize the data rows
		for row in topHeaderPathArray
			dataObj = {}
			storeDataAr.push dataObj

		dataObj = {}
		storeDataAr.push dataObj

		# find the total column
		for col in columnItems
			if col.valueType is "class java.lang.Double"
				@topheaderTotalColumn = col[@pathProp]
				break

		index = 0
		for col in columnDataItems
			colName = 'c' + index
			colObj =
				text: colName
				dataIndex: colName
				align: 'center'
				flex: 1
			gridColumns.push colObj

			fieldObj =
				name: colName
			storeFieldAr.push fieldObj

			pathIndex = 0
			for colPath in topHeaderPathArray
				# fill the data in this column, for each row
				dataObj = storeDataAr[pathIndex]
				dataObj[colName] = col.value[colPath]

				pathIndex++

			# if this is the last column:
			#	convert it to a number and format it
			#	copy it to a special row
			dataObj = storeDataAr[pathLen]
			dataObj[colName] = col.value[colPath]

			index++

		# in this store, the first row contains all values of column[0], and so on
		# the data is rotated 90 degrees to the left, in other words

		storeConfig =
			fields: storeFieldAr
			data: storeDataAr
		st = Ext.create 'Ext.data.Store', storeConfig

		gridConfig =
			header: false
			enableColumnResize: false
			enableColumnMove: false
			enableColumnHide: false
			sortableColumns: false
			columnLines: true
			hideHeaders: true
			columns: gridColumns
			store: st
		gridConfig.width = columnDataItems.length * @topHeaderItemWidth

		grid = Ext.create 'Ext.grid.Panel', gridConfig
		@topheaderGrid = grid

		@topheader.add grid

		me = this
		myFunc = Ext.Function.createDelayed ->
			# wait for the grid to render, then render the next grid down
			me.configureCellGrid()
		, 1
		myFunc()

		return


	configureCellGrid: ->
		me = this
		props = @cache._myProperties

		rowDataItems = props.rowGrid.items
		columnDataItems = props.columnGrid.items

		columnDataLen = columnDataItems.length

		storeFieldAr = []
		storeDataAr = []
		gridColumns = []

		# the number of columns in the cell grid is the number of records in columnDataItems
		index = 0
		for col in columnDataItems
			colName = 'c' + index
			colObj =
				xtype: 'corecheckcolumn'
				dataIndex: 'b' + index
				width: 28
			gridColumns.push colObj
			fieldObj =
				name: 'b' + index
			storeFieldAr.push fieldObj

			editorConfig =
				xtype: 'numberfield'
				hideTrigger: true
				keyNavEnabled: false
				mouseWheelEnabled: false

			colObj =
				xtype: 'numbercolumn'
				dataIndex: 'p' + index
				align: 'left'
				format: '0.00%'
				width: 60
				text: ''
				editor: editorConfig
			gridColumns.push colObj
			fieldObj =
				name: 'p' + index
			storeFieldAr.push fieldObj

			colObj =
				xtype: 'numbercolumn'
				dataIndex: colName
				align: 'right'
				format: '0,000.00'
				flex: 1
				header: ''
				editor: editorConfig
			gridColumns.push colObj
			fieldObj =
				name: colName
			storeFieldAr.push fieldObj

			# set the height of the first cell only
			if not index
				colObj.renderer = @cellRenderer
			index++

		# number of rows equals rowDataItems
		for row in rowDataItems
			dataObj = {}
			for i in [0... columnDataLen]
				colName = 'b' + i
				# set all checkboxes to TRUE
				dataObj[colName] = true
			storeDataAr.push dataObj


		storeConfig =
			fields: storeFieldAr
			data: storeDataAr
			listeners:
				update: (st, record, operation, modifiedFields) ->
					me.onCellStoreUpdate st, record, operation, modifiedFields
					return

		st = Ext.create 'Ext.data.Store', storeConfig

		gridConfig =
			header: false
			plugins: [
				Ext.create 'Ext.grid.plugin.CellEditing',
					clicksToEdit: 1
			]
			enableColumnResize: false
			enableColumnMove: false
			enableColumnHide: false
			sortableColumns: false
			columns: gridColumns
			store: st
		gridConfig.width = columnDataItems.length * @topHeaderItemWidth

		grid = Ext.create 'Ext.grid.Panel', gridConfig
		@cellGrid = grid

		@cellarea.add grid

		@fillCellGridStore()
		@updateTopHeaderTotalAll()
		return


	fillCellGridStore: ->
		props = @cache._myProperties

		rowDataItems = props.rowGrid.items
		colDataItems = props.columnGrid.items
		cellItems = props.centerGrid.allContents
		cellDataItems = props.centerGrid.items

		# loop through cellItems and choose the first column of type "class java.lang.Double"
		for cell in cellItems
			if cell.valueType is 'class java.lang.Double' or cell.valueType is 'java.lang.Double'
				cellPath = cell[@pathProp]
				break

		if not cellPath
			# if we couldn't find a path with a DOUBLE type, don't bother filling the grid
			return

		@cellValuePath = cellPath

		st = @cellGrid.store
		rowLen = rowDataItems.length
		colLen = colDataItems.length

		# set all cells to 0
		# we have to do this because all cells are not guaranteed to be filled with values

		for rowNum in [0... rowLen]
			for colNum in [0... colLen]
				@insertIntoCellGridStore st, rowNum, colNum, 0

		# now fill with actual values
		# sadly, the cells are not ordered in any rational way,
		#		so the order of the cells does not imply the row, col of the data
		# instead, the row and col is in the cell property itself
		for cell in cellDataItems
			@insertIntoCellGridStore st, cell.rowIndex, cell.columnIndex, cell.value[cellPath], cell

		for i in [0... rowLen]
			@setAvailAmt i

		st.sync()
		@leftheaderGrid.store.sync()
		return


# inserts the passed value into the store
	insertIntoCellGridStore: (store, rowindex, colindex, value, origCell) ->
		row = store.getAt rowindex
		colName = 'c' + colindex
		row.set colName, value

		if origCell
			origObj = row.get 'origData'
			if not origObj
				origObj = {}
				row.set 'origData', origObj
			origObj[colName] = origCell
		return

# called any time the contents of the cell store changes
	onCellStoreUpdate: (st, record, operationNotUsed, modifiedFields) ->
		if @disableStoreEvents
			return

		if not modifiedFields or not modifiedFields.length
			return

		modifiedField = modifiedFields[0]
		fieldType = modifiedField[0]

		# only process these types of fields
		if fieldType in ['p', 'c', 'b']
			colindex = modifiedField[1..]
			rowindex = st.indexOf record
			usePercentage = false
			if fieldType is 'p'
				usePercentage = true
			@recalculateTotals rowindex, colindex, usePercentage
		return



# sets the available amount for a specific row
	setAvailAmt: (rowindex, usePercentage) ->
		props = @cache._myProperties

		colDataItems = props.columnGrid.items

		colItemLength = colDataItems.length
		leftHeaderStore = @leftheaderGrid.store
		leftrow = leftHeaderStore.getAt rowindex
		leftamt = leftrow.get @leftheaderTotalColumn
		cellStore = @cellGrid.store
		cellrow = cellStore.getAt rowindex

		if usePercentage
			# update all percentage values first
			for i in [0... colItemLength]
				colName = 'c' + i
				percColName = 'p' + i
				percAmt = cellrow.get percColName
				numAmt = leftamt * percAmt / 100
				cellrow.set colName, numAmt

		cellTotal = 0
		# for each cell column in the row, add it to total
		# also, calculate the percentage of total
		for i in [0... colItemLength]
			colName = 'c' + i
			cellAmt = cellrow.get colName

			checkboxColumnName = 'b' + i
			checkboxState = cellrow.get checkboxColumnName
			if checkboxState
				cellTotal += cellAmt

			percColName = 'p' + i
			perc = cellAmt / leftamt * 100
			cellrow.set percColName, perc

		avail = leftamt - cellTotal
		leftrow.set 'AvailAmt', avail
		leftHeaderStore.sync()

		return


# initially update all the totals in the top header
	updateTopHeaderTotalAll: ->
		props = @cache._myProperties

		colDataItems = props.columnGrid.items
		colDataItemsLen = colDataItems.length

		for i in [0... colDataItemsLen]
			@updateTopHeaderTotal i

		# this should be the last of the updates, so go ahead and enable the store events
		delete @disableStoreEvents
		return


	updateTopHeaderTotal: (colindex) ->
		# in the top header, the last row in the store is the unallocated amount
		# next to last row is the original total amount to be allocated
		topheaderStore = @topheaderGrid.store
		cellStore = @cellGrid.store

		headerRowCount = topheaderStore.getCount()
		cellRowCount = cellStore.getCount()

		colName = 'c' + colindex
		totalAmt = topheaderStore.getAt(headerRowCount - 2).get colName
		unapprovedRow = topheaderStore.getAt(headerRowCount - 1)

		# find total of the cells in this column
		cellTotal = 0
		for i in [0... cellRowCount]
			cellrow = cellStore.getAt i
			checkboxColumnName = 'b' + colindex
			checkboxState = cellrow.get checkboxColumnName
			if checkboxState
				cellTotal += cellrow.get colName

		unapprovedAmt = totalAmt - cellTotal
		unapprovedRow.set colName, unapprovedAmt
		topheaderStore.sync()
		return


	recalculateTotals: (rowindex, colindex, usePercentage) ->
		@setAvailAmt rowindex, usePercentage
		@updateTopHeaderTotal colindex
		return



	generatePostData: ->
		cm = Corefw.util.Common

		cache = @cache
		props = cache._myProperties

		if not @cellGrid
			return

		# location of the original data
		rowDataItems = props.rowGrid.items
		columnDataItems = props.columnGrid.items

		postData =
			name: props.name
			rowGrid: {}
			columnGrid: {}
			centerGrid: {}

		selected = @cellGrid.selModel?.selected or []

		rowItems = cm.objectClone rowDataItems
		postData.rowGrid.items = rowItems

		columnItems = cm.objectClone columnDataItems
		postData.columnGrid.items = columnItems

		# if this doesn't exist, there's no point in filling out cell grid
		if @cellValuePath
			cellValuePath = @cellValuePath
			cellStore = @cellGrid.store

			cellItems = []

			rowLen = rowItems.length
			colLen = columnItems.length

			#index = 0
			for rowNum in [0... rowLen]
				row = cellStore.getAt rowNum
				rowSelected = selected.contains row
				origData = row.get 'origData'
				for colNum in [0... colLen]
					colName = 'c' + colNum
					newval = row.get colName

					origCell = origData?[colName]
					if origCell
						cell = cm.objectClone origCell
						cell.new = false
						cell.selected = rowSelected

						# get the current value of this position
						oldval = cell.value[cellValuePath]

						if newval isnt oldval
							cell.value[cellValuePath] = newval
							cell.changed = true
						else
							cell.changed = false
					else
						cell =
							"new": true
							selected: rowSelected
							changed: true
							columnIndex: colNum
							rowIndex: rowNum
							value: {}
						cell.value[cellValuePath] = newval

					cellItems.push cell
			#index++

			postData.centerGrid.items = cellItems
			cellStore.sync()

		return postData