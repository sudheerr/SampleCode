Ext.define 'Corefw.view.grid.LinkColumn',
	extend: 'Ext.grid.column.Column'
	xtype: 'corelinkcolumn'

	initComponent: ->
		if @disptype is 'ICON'
			@minWidth = @maxWidth = if @text.length * 9 > 24 then @text.length * 9 else 24
		@callParent arguments

	renderer: (value, metaData, record, rowIndex, colIndex, store, view) ->
		column = metaData.column
		if column
			metaData.tdCls = if column.disptype is 'ICON' then column.labelMap[value] else ' linkcolumn'

		return value


	afterRender: ->
		evt = Corefw.util.Event
		props = @cache._myProperties
		# process events on this column
		evt.addEvents props, 'column', props
		return
