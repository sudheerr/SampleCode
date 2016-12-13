Ext.define 'Corefw.view.grid.pivot.ConfigCheckColumn',
	extend: 'Ext.grid.column.CheckColumn'
	alias: 'widget.pivotcfgcheckcolumn'

	processEvent: (type, view, cell, recordIndex, cellIndex, e, record) ->
		if record is @up('grid').getStore().last()
			return false
		return @callParent arguments

	renderer: (value, meta) ->
		if meta.record is @up('grid').getStore().last()
			meta.tdCls += ' ' + this.disabledCls
		@callParent arguments