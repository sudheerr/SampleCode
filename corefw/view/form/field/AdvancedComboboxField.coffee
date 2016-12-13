Ext.define 'Corefw.view.form.field.AdvancedComboboxField',
	extend: 'Corefw.view.form.field.ComboboxField'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'advancedcomboboxfield'
	hideAfterSelect: false
	onListSelectionChange: (list, selectedRecords)->
		me = this
		willHide = if me.multiSelect then false else me.hideAfterSelect
		hasRecords = selectedRecords.length > 0
		if !me.ignoreSelection && me.isExpanded
			if willHide
				Ext.defer me.collapse, 1, me
			if me.multiSelect or hasRecords
				me.setValue selectedRecords, false
			if hasRecords
				me.fireEvent 'select', me, selectedRecords
			me.inputEl.focus()
		return
	onItemClick: (picker, record)->
		me = @
		selection = me.picker.getSelectionModel().getSelection()
		valueField = me.valueField
		if (!me.multiSelect && selection.length)
			if record.get(valueField) is selection[0].get(valueField)
				me.displayTplData = [record.data]
				me.setRawValue(me.getDisplayValue())
				if me.hideAfterSelect
					me.collapse()
		return
	initComponent: ()->
		me = @
		newListConfig =
			xtype: 'listview'
			border: true
			addListeners:
				itemdblclick: (listview, record, item, index, e)->
					me.fireEvent "itemdblclick", me, record, item, index
					return
			getTooltip: (record)->
				return record.get "sub_dispField"
			dataRenderer: (value, metaData, record, rowIndex, colIndex, store, view)->
				html = value + "<div style='font-style:italic;'>" + record.get("sub_dispField") + "</div>"
				return html
		@listConfig = Ext.apply {}, newListConfig
		@callParent arguments
		return
		