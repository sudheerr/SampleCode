Ext.define 'Corefw.view.grid.RcGrid',
	extend: 'Corefw.view.grid.ObjectGrid'
	xtype: 'corercgrid'


	statics:
		createDataCache: (dataFieldItem, fieldCache) ->
			cm = Corefw.util.Common

			fieldDataCache = []
			fieldCache._myProperties.data = {}
			fieldCache._myProperties.data.items = fieldDataCache

			if not dataFieldItem
				# new JSON
				copyProperties = [
					'changed'
					'removed'
					'new'
					'selected'
					'cells'
				]

				props = fieldCache._myProperties
				if props.rows
					tooltipTest = props.tooltipValue
					for row in props.rows
						miscRowObj = {}
						miscRowObj._myProperties = {}
						#For applying tooltips, cell and row style
						cells = if tooltipTest then tooltipTest[_i] else undefined
						cells = cells.cells if cells

						cm.copyObjProperties miscRowObj._myProperties, row, copyProperties

						# note: properties have TWO underlines: "__"
						# __misc contains the row's properties, and also each cell's
						#		properties indexed by the path
						newObj =
							__index: row.rowKey
							__misc: miscRowObj

						for key, cell of row.cells
							newObj[key] = cell.value
							style = if cells then cells[cell.columnKey] else undefined
							displayValue = cell.displayValue
							cellPropObj =
								columnKey: cell.columnKey

							if style
								cellPropObj.tooltip = style.tooltip
								cellPropObj.rowStyle = style.rowStyle
								cellPropObj.cellStyle = style.cellStyle

							cellPropObj.displayValue = displayValue if displayValue

							miscRowObj[key] = cellPropObj

							cm.copyObjProperties cellPropObj, cell, copyProperties

						fieldDataCache.push newObj
			else
				# old JSON

				copyProperties = [
					'hasBeenChanged'
					'hasBeenRemoved'
					'isNew'
					'isSelected'
				]

				# data items are in "rows", with an array of "cells", each with its own isNew, isSelected, etc
				if dataFieldItem.rows
					for row in dataFieldItem.rows
						miscRowObj = {}
						miscRowObj._myProperties = {}
						cm.copyObjProperties miscRowObj._myProperties, row, copyProperties

						# note: properties have TWO underlines: "__"
						# __misc contains the row's properties, and also each cell's
						#		properties indexed by the path
						newObj =
							__index: row.index
							__misc: miscRowObj

						for cell in row.cells
							newObj[cell.path] = cell.value
							cellPropObj = {}
							miscRowObj[cell.path] = cellPropObj
							cm.copyObjProperties cellPropObj, cell, copyProperties

						fieldDataCache.push newObj

			return



	afterRender: ->
		@callParent arguments

		# override the grid's default functions
		gridConfig =
			setSelection: @setSelection
			corefieldtype: 'rcgrid'

		Ext.apply @grid, gridConfig
		return



# override this grid's setSelection method from gridbase
	setSelection: ->
		st = @store
		# set the selected record
		selectArray = []
		len = st.getCount()

		for i in [0... len]
			record = st.getAt i
			misc = record.get '__misc'
			if misc?._myProperties?.selected
				selectArray.push record

		if selectArray.length
			@getSelectionModel().select selectArray, false, true
		return




# override this grid's generatePostData method from gridbase
	generatePostData: ->
		cm = Corefw.util.Common
		#de = Corefw.util.Debug
		#su = Corefw.util.Startup

		postData = @callParent arguments

		# if @forcedSelectedRecord
		# 	@grid.forcedSelectedRecord = @forcedSelectedRecord

		# postData = @grid.generatePostData()
		# delete @grid.forcedSelectedRecord

		copyObj = cm.objectClone postData
		# if de.printOutRawResponse()
		# 	console.log 'postData rcgrid: ', copyObj

		copyProperties = [
			'changed'
			'removed'
			'index'
			'new'
			'selected'
		]

		rowsArray = []
		postData.rows = rowsArray

		# transfer "items" array to "rows" array to conform to RCGrid's submit format
		items = postData.items
		if items and items.length
			for item in items
				# copy row information from "item" to an element in "rows" array
				rowObj = {}
				cm.copyObjProperties rowObj, item, copyProperties
				rowsArray.push rowObj

				cm.objRenameProperty rowObj, 'index', 'rowKey'


				cellValues = item.value
				rowMisc = cellValues.__misc

				if cellValues
					topCellObj = {}
					rowObj.cells = topCellObj

					for key,cellval of cellValues
						if key isnt '__misc' and key isnt 'id'
							cellObj =
								value: cellval
								columnKey: key
								rowKey: rowObj.rowKey

							if rowMisc
								cm.copyObjProperties cellObj, rowMisc[key], copyProperties
							# override "isSelected" with row's setting
							cellObj.selected = rowObj.selected
							topCellObj[key] = cellObj

		delete postData.items
		# if de.printOutRawResponse()
		# 	console.log 'rcgrid: final postData ', postData
		return postData