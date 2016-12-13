Ext.define 'Corefw.view.grid.RadioSelectionModel',
	extend: 'Ext.selection.CheckboxModel'
	alias: 'selection.radiomodel'

	mode: 'SINGLE'

	renderer: (value, metaData, record, rowIndex, colIndex, store, view) ->
		@callParent arguments
		baseCSSPrefix = Ext.baseCSSPrefix
		if not record.raw._myProperties.selectable
			return '<div class="' + baseCSSPrefix + 'grid-row-checker selectmodel-item-disabled ' + baseCSSPrefix + 'grid-radioselect" role="presentation">&#160;</div>'
		else
			return '<div class="' + baseCSSPrefix + 'grid-row-checker ' + baseCSSPrefix + 'grid-radioselect" role="presentation">&#160;</div>'
