Ext.define 'Corefw.view.form.field.DateStringField',
	extend: 'Ext.form.field.Date'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'coredatestringfield'
	showToday: false
	labelSeparator: ''
	format: 'Y-m-d H:i:s'

	generatePostData: ->
		val = @getValue() or ''
		val = Ext.Date.format val, 'Y-m-d H:i:s' if val
		fieldObj =
			name: @name
			value: val
		return fieldObj

	setValue: ->
		value = arguments[0]
		if 'string' is typeof value
			arguments[0] = (Ext.Date.parse value, 'Y-m-d H:i:s') or (Ext.Date.parse value, @format)
		@callParent arguments

	initComponent: ->
		if(@cache)
			fieldProps = @cache._myProperties
		else if(@column.cache)
			fieldProps = @column.cache._myProperties
		@applyConfig fieldProps
		@callParent arguments

	applyConfig: (fieldProps) ->
		minDate = fieldProps.minDate
		maxDate = fieldProps.maxDate
		config =
			minValue: if minDate isnt '' and minDate isnt undefined then new Date(minDate) else null
			maxValue: if maxDate isnt '' and maxDate isnt undefined then new Date(maxDate) else null
		config.format = fieldProps.format if not Ext.isEmpty fieldProps.format
		Ext.merge this, config