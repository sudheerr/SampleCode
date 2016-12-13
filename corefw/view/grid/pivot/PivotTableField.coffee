Ext.define 'Corefw.view.grid.pivot.PivotTableField',
	extend: 'Ext.container.Container'
	alias: 'widget.pivottablefield'
	requires: ['Corefw.view.grid.pivot.PivotTable']
	overflowX: 'auto'
	overflowY: 'auto'

	initComponent: ->
		@callParent arguments
		@reloadPivot @cache?._myProperties

	reloadPivot: (props)->
		@table = @add
			xtype: 'pivottable'
			uipathId: 'pivotGrid'
			width: '100%'
			height: '100%'
			props: props
			subTotalPosition: 'bottom'  #top or bottom
		return