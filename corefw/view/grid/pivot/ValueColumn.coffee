Ext.define 'Corefw.view.grid.pivot.ValueColumn',
	extend: 'Ext.grid.column.Number'
	alias: 'widget.pivotvaluecolumn'
	align: 'right'
	menuDisabled: true

	initComponent: ->
		@autoEl =
			'data-qtip': "#{@text} - #{@aggregation}"
		@text = "#{@text}<span style=\"font-size:8px\"><sub>#{@aggregation}</sub></span>"	
		@callParent arguments

	listeners:
		beforerender: (me) ->
			gridview = me.up('grid').view
			unusedWidth = gridview.el.dom.scrollWidth - gridview.body.getWidth()
			if unusedWidth > 0
				gridColumns = gridview.getGridColumns()
				isLast = gridColumns.indexOf(me) is gridColumns.length - 1
				average = Math.floor unusedWidth/gridColumns.length
				me.width += if isLast then unusedWidth - average*(gridColumns.length - 1) else average