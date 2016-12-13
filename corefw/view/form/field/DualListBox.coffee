Ext.define 'Corefw.view.form.field.DualListBox',
	extend: 'Ext.ux.form.ItemSelector'
	cls: 'cv-dual-listbox'
	xtype: 'coreduallistbox'
	listeners: 
		boxready: ->
			btnContainer = @down "> container:not(multiselectfield)"
			height = btnContainer.getHeight()
			hideTopBottomBtns = ->
				topBottomBtns = btnContainer.query "button[iconCls$=-top], button[iconCls$=-bottom]"
				for btn in topBottomBtns
					btn.hide()
				return
			hideUpDownBtns = ->
				upDownBtns = btnContainer.query "button[iconCls$=-up], button[iconCls$=-down]"
				for btn in upDownBtns
					btn.hide()
				return
			if height >= 110 and height < 160
				hideTopBottomBtns()
			else if height >= 60 and height < 110
				hideTopBottomBtns()
				hideUpDownBtns()
			else if height < 60
				@fromField.setMargin '0 3px 0 0'
				btnContainer.hide()
			return
	initComponent: ->
		props = @cache._myProperties
		validValues = props.validValues
		data = []
		Ext.each validValues, (validValue) ->
			data.push
				value: validValue.value
				text: validValue.displayValue
			return
		dataStore = Ext.create 'Ext.data.Store',
			id: "store.dynamic.#{props.uipath}"
			fields: ['value', 'text']
			autoDestroy: true
			data: data
		config = 
			fromTitle: false
			toTitle: false
			labelStyle: 'padding-bottom: 6px'
			displayField: 'text'
			valueField: 'value'
			store: dataStore
		Ext.apply @, config
		@callParent arguments
		return