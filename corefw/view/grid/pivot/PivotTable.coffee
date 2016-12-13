Ext.define 'Corefw.view.grid.pivot.PivotTable',
	extend: 'Ext.grid.Panel'
	alias: 'widget.pivottable'
	requires: [
		'Corefw.view.grid.pivot.AxisColumn'
		'Corefw.view.grid.pivot.ValueColumn'
		'Corefw.view.grid.pivot.GroupColumn'
		'Corefw.view.grid.pivot.PivotTableToolBar'
		'Ext.grid.plugin.BufferedRenderer'
	]
	plugins: [
		{
			ptype: 'bufferedrenderer'
			trailingBufferZone: 100
			leadingBufferZone: 100
		}
		{
			ptype: 'pivotcelltooltip'
		}
	]
	mixins: ['Corefw.mixin.UiPathAware']
	dockedItems: [
		{xtype: 'pivottablecfgpanel', itemId: 'cfgPanel', overflowY:'auto'}
		{xtype:'pivottabletoolbar'}
	]

	cls: 'pivotTable'
	columns: []
	columnLines: true

	grandTotalRowCls: 'grand-total-row'
	subTotalRowCls: 'sub-total-row'
	headingRowCls: 'heading-row'
	keyDelimeter: '~'

	# When no row labels and there are column labels, pivotRowHeaders will
	# contain one row header called 'Grand Total'. Need a place holder row
	# label to match the data in this case
	holderRowLabels: [
		name: '',
		path: 'Grand Total'
	]

	# pivot table holds currently applied pivotConfig which won't
	# be updated until new configuration is applied
	currentPivotConfig: null

	# global divisor for all number values. This implements the currency
	# units feature which could be in million, billion or so.
	valueDevidedBy: 1

	viewConfig:
		getRowClass: (record, index, rowParams, store) ->
			return @up('grid').subTotalRowCls if record.raw._subTotalFor
			return @up('grid').grandTotalRowCls if record.raw._grandTotal

	listeners:
		afterrender: ->
			@binduipath()
			cfgPanel = this.down "#cfgPanel"
			cfgPanel.init @uipath
		reconfigure: ->
			@view.setLoading false

	reload: (configData, globalFilter) ->
		@view.setLoading true
		Ext.Ajax.request
			url: 'api/pivot/pivotData'
			method: 'POST'
			scope: this
			jsonData:
				uipath: @uipath
				pivotConfig: configData
				globalFilter: globalFilter
			success: (response) ->
				responseJson = Ext.decode response.responseText
				@currentPivotConfig = configData
				@reloadTable responseJson

	reloadTable: (props) ->
		@down('[name=rows]').update props.totalRows
		columns = @generateColumns @currentPivotConfig, props
		fields = @generateFields columns
		data = @generateData @currentPivotConfig, props
		store = Ext.create 'Ext.data.Store',
			fields: fields
			data: data
		@reconfigure store, columns
	
	# columns are comprised of three parts:
	#  - Row Labels. The configuration directly determins columns for row labels
	#  - Column Labels. Each queried result of column labels in terms of pivotColumnHeaders
	#        becomes a parent column header. It's possible there is no columns labels.
	#  - Values. The configuration directly determins columns for values. This
	#        adds children columns to pivotColumnHeaders columns.
	generateColumns: (pivotConfig, props) ->
		me = this
		rowLabelsColumns = (pivotConfig.rowLabels or me.holderRowLabels).map (name, index, rowLabels) ->
			xtype: 'pivotaxiscolumn'
			text: name.name
			dataIndex: name.path
			cls: 'lastaxis' if index is rowLabels.length-1
			mergeCell: if index is rowLabels.length-1 then false else true

		columnLabelsColumns = []

		# Generate column definitions from queried result of column labels,
		# i.e. pivotColumnHeaders, organize them in grid group column structure	
		columnLabelsResults = props.pivotColumnHeaders.map (colHeader) ->
			colHeader.value.pivotDimensionValues
		rootColumn = text: '', key: '', columns: []
		Ext.Array.each columnLabelsResults, (result) ->
			parent = rootColumn
			Ext.Array.each pivotConfig.columnLabels, (columnLabel, index) ->
				column = me.findColumnByText parent, result[index]
				parent = column

		# now iterate all leaf column definitions and add columns for 'Values'
		# (pivot config) to each one of them
		((parent) ->
			selfFn = arguments.callee
			if parent.columns and parent.columns.length
				Ext.Array.each parent.columns, (column) ->
					selfFn column
			else
				Ext.Array.each pivotConfig.values, (value) ->
					column = me.findColumnByText parent, value.fullText, "#{value.valueItemId}#{me.keyDelimeter}#{value.aggregation}"
					Ext.apply column, 
						dataIndex: column.key
						xtype: 'pivotvaluecolumn'
						aggregation: value.aggregation
						renderer: (value)->
							return value if not Ext.isNumber value
							return Ext.util.Format.number value/this.valueDevidedBy, '0,000.00'
		) rootColumn

		return rowLabelsColumns.concat rootColumn.columns


	# Find a column definition form its parent column definition by text
	# Insert a new column definition if not find.
	findColumnByText: (parent, text, key) ->
		parent.columns = parent.columns or []
		column = Ext.Array.findBy parent.columns, (item)-> item.text is text
		if not column
			key = key or text
			key = if parent.key then "#{parent.key}#{@keyDelimeter}#{key}" else key
			column = xtype: 'pivotgroupcolumn', text: text, key: key
			parent.columns.push column
		return column

	# Generate fields from dataIndex of all leaf column definitions
	generateFields: (columns) ->
		fields = []
		for column in columns
			((parent) ->
				selfFn = arguments.callee
				if parent.dataIndex
					# fields.push parent.dataIndex
					# ext4 has a bug (ext5 fixed it) in dealing with above simpler way
					# when there is "." in field. It can be reproduced by
					# Ext.create('Ext.data.Store', {fields: ['a.~b']})
					fields.push
						name: parent.dataIndex
						useNull: true
						mapping: (data) -> data[parent.dataIndex]
				else
					Ext.Array.map parent.columns, selfFn
			) column
		return fields

	# Data depends on queried result of 'Row Labels', i.e. pivotRowHeaders
	# Each item of pivotRowHeader corresponds to a grid row.
	# On each row, there could be none or multiple values from pivotCells.
	generateData: (pivotConfig, props) ->
		me = this
		data = []
		rowKeyIndices = {}
		Ext.Array.map props.pivotRowHeaders, (pivotRowHeader) ->
			rowData = {}
			rowDataKey = []
			rowLabelValues = pivotRowHeader.value.pivotDimensionValues
			if pivotRowHeader.hasSubTotal
				rowData._subTotalFor = rowLabelValues[rowLabelValues.length-1]
			if rowLabelValues[0] is 'Grand Total'
				rowData._grandTotal = true
			Ext.Array.each pivotConfig.rowLabels or me.holderRowLabels, (name, index) ->
				rowData[name.path] = rowLabelValues[index]
				rowDataKey.push rowLabelValues[index] if rowLabelValues[index]		
			rowKeyIndices[rowDataKey.join(me.keyDelimeter)] = data.length
			data.push rowData

		# Map values from pivotCells to corresponding row
		Ext.Array.each props.pivotCells, (pivotCell) ->
			rowDataKey = pivotCell.rowKey.pivotDimensionValues.join me.keyDelimeter
			rowData = data[rowKeyIndices[rowDataKey]]
			return if not rowData
			Ext.Array.each pivotCell.values.valueMap, (oneValue) ->
				valuePath = [oneValue.path, oneValue.aggregationName]
				valuePath = pivotCell.columnKey.pivotDimensionValues.concat valuePath if pivotCell.columnKey
				rowData[valuePath.join(me.keyDelimeter)] = oneValue.value
				for timeMarkKey, varianceObj of oneValue.variances
					for varianceType, varianceValue of varianceObj
						vPath = valuePath[0..-2].concat([varianceType, timeMarkKey]).concat(valuePath[-1..])
						rowData[vPath.join(me.keyDelimeter)] = varianceValue
				return
		return data

	# When global divisor is changed, refresh the view to update number display
	updateDivisor: (newValue) ->
		@valueDevidedBy = newValue
		@getView().refresh()

	toggleConfigPanel: (toOpen) ->
		cfgPanel = this.down "#cfgPanel"
		if toOpen is false or (toOpen is undefined and cfgPanel.isVisible())
			cfgPanel.hide()
		else
			cfgPanel.show()
		return cfgPanel.isVisible()