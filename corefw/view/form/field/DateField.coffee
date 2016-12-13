Ext.define 'Corefw.view.form.field.DateField',
	extend: 'Ext.form.field.Date'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'coredatefield'
	showToday: false
	labelSeparator: ''
	format: 'd M Y'
	generatePostData: ->
		val = @getValue()?.getTime()
		fieldObj =
			name: @name
			value: if (val isnt undefined and val isnt null) then val else ''
		return fieldObj

	setValue: (value) ->
		if Ext.isNumber value
			value = new Date value
		# This format can be any valid format string which extjs Ext.Date supports.
		# The value which is formatted cannot be passed to Date directly(IE has issues.)
		nowTimeString = Ext.Date.format new Date(), 'H:i:s'
		newDateString = Ext.Date.format value, 'd M Y'
		arguments[0] = Ext.Date.parse newDateString + ' ' + nowTimeString, 'd M Y H:i:s'
		@callParent arguments

	initComponent: ->
		if(@cache)
			fieldProps = @cache._myProperties
		else if(@column.cache)
			fieldProps = @column.cache._myProperties
		@applyConfig fieldProps
		@callParent arguments

	applyConfig: (fieldProps = {}) ->
		minDate = fieldProps.minDate
		maxDate = fieldProps.maxDate
		config =
			minValue: if minDate isnt '' and minDate isnt undefined then new Date(minDate) else null
			maxValue: if maxDate isnt '' and maxDate isnt undefined then new Date(maxDate) else null
		config.format = fieldProps.format if not Ext.isEmpty fieldProps.format
		Ext.merge this, config