Ext.define "Corefw.view.form.field.IconField",
	extend: "Ext.form.FieldContainer"
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'coreiconfield'
	coretype: 'field'
	layout: 'hbox'

	initComponent: ->
		props = @cache._myProperties

		textfieldConfig =
			xtype: 'textfield'
			flex: 1

		buttonConfig =
			xtype: 'button'
			width: 30
			iconCls: props.iconStyle
			margin: '0 0 0 6'
			style:
				'background-color': '#fff'
				border: 0


		@items = [textfieldConfig, buttonConfig]

		if props.value
			textfieldConfig.value = props.value

		@callParent arguments
		return

	updateByCache: (cache) ->
		props = cache._myProperties
		field = @down 'textfield'
		field.setValue props.value
		button = @down 'button'
		iconCls = props.iconStyle
		button.iconCls isnt iconCls and button.setIconCls iconCls
		return

	getPostValue: ->
		textfield = @.down('textfield')
		return textfield.getValue()

	generatePostData: ->
		fieldObj =
			name: @name
			value: @getPostValue()
		return fieldObj
