Ext.define 'Corefw.view.grid.pivot.AxisColumn',
	extend: 'Ext.grid.column.Column'
	alias: 'widget.pivotaxiscolumn'
	tdCls: 'left-axis'
	emptyCellCls: 'empty-cell'
	mergeCellStartCls: 'mergecell-start'
	mergeCellEndCls: 'mergecell-end'
	mergeCell: true
	draggable: false
	menuDisabled: true
	maxWidth: 1000

	initComponent: ->
		@autoEl =
			'data-qtip': @text
		@callParent arguments	

	hasValueOnTheLeft: (record, rowIndex)->
		me = this
		if me.myLeftColumns is undefined
			me.myLeftColumns = []
			for column in me.up('grid').columnManager.columns
				break if column is me
				me.myLeftColumns.push column
		for column in me.myLeftColumns
			if record.get column.dataIndex
				return true
		return false

	compareWithCell: (value, store, rowIndex, dataIndex)->
		record = store.getAt rowIndex
		if record
			targetValue = record.get dataIndex
			return true if targetValue is value
		return false

	renderer: (value, metaData, record, rowIndex, colIndex, store, view) ->
		try
			column = metaData.column
			metaData.tdCls += ' ' + column.cls if column.cls
			if value is record.raw._subTotalFor
				return "#{value} Total"
			if column.mergeCell
				return '' if not value and column.hasValueOnTheLeft record, rowIndex

				equalToAboveCell = column.compareWithCell value, store, rowIndex-1, column.dataIndex
				equalToBelowCell = column.compareWithCell value, store, rowIndex+1, column.dataIndex
				if equalToAboveCell and equalToBelowCell
					metaData.tdCls = metaData.tdCls + ' ' + column.emptyCellCls
					return ''
				if not equalToAboveCell and equalToBelowCell
					metaData.tdCls = metaData.tdCls + ' ' + column.mergeCellStartCls
				if equalToAboveCell and not equalToBelowCell
					metaData.tdCls = metaData.tdCls + ' ' + column.mergeCellEndCls
					return ''
		catch e
			console.error e
		return value

	listeners:
		beforerender: (me) ->
			gridview = me.up('grid').view
			firstCell = Ext.DomQuery.select("td#{me.getCellSelector()}:first")[0]
			me.width = firstCell.getBoundingClientRect().width if firstCell
			unusedWidth = gridview.el.dom.scrollWidth - gridview.body.getWidth()
			if unusedWidth > 0
				me.width += Math.floor unusedWidth/gridview.getGridColumns().length
				