Ext.define "Corefw.view.form.field.CheckboxGroupField",
	extend: "Ext.form.CheckboxGroup"
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'corecheckboxgroup'
	coretype: 'field'

	generatePostData: ->
		cache = @cache
		props = cache._myProperties
		name = props.name
		val = @getValue()[name]
		if Ext.isEmpty val
			fieldObj =
				name: name
				value: []
			return fieldObj
		if !Ext.isArray val
			val = [val]
		fieldObj =
			name: name
			value: if (val isnt undefined and val isnt null) then val else []
		return fieldObj
