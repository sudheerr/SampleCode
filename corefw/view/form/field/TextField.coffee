Ext.define 'Corefw.view.form.field.TextField',
	extend: 'Ext.form.field.Text'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'coretextfield'

	setValue: (value) ->
		if Ext.isObject(value) and value.displayValue
			theValue = value.value
			@valueType = Ext.typeOf theValue
			arguments[0] = theValue
		@callParent arguments

	getValue: ->
		value = @callParent arguments
		if valueType = @valueType
			switch valueType
				when 'number'
					value = +value
				when 'boolean'
					value = if value is 'false' then false else true
		return value