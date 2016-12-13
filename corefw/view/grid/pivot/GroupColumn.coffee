Ext.define 'Corefw.view.grid.pivot.GroupColumn',
	extend: 'Ext.grid.column.Column'
	alias: 'widget.pivotgroupcolumn'
	menuDisabled: true
	bugfixfromext5: true

	initComponent: ->
		@autoEl =
			'data-qtip': @text
		@callParent arguments