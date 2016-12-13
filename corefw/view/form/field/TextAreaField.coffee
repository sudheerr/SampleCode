Ext.define 'Corefw.view.form.field.TextAreaField',
	extend: 'Ext.form.field.TextArea'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'coretextarea'

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

	afterRender: ->
		if @cache?._myProperties?.editable is false
			@.setReadOnly true
		if borderLess = @cache?._myProperties?.borderless
			@inputEl.setStyle 'border', 'none'
			@inputEl.setStyle 'background-image', 'none'