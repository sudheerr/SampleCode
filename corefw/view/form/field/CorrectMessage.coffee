Ext.define 'Corefw.view.form.field.CorrectMessage',
	extend: 'Ext.Component'
	xtype: 'corefieldvalidateMessage'
	tpl: new Ext.Template "<div role='presentation' id='{inputId}-correctEl' class='{cssPrefix}form-valid-under'>
		<ul class='{cssPrefix}list-plain'><li role='alert'>{correctMsg}<br></li></ul></div>"
	initComponent: ->
		field = @field
		me = @
		me.hide()
		extCSSPrefix = Ext.baseCSSPrefix
		fieldValidateSuccessCls = "#{extCSSPrefix}form-validate-success-field"

		field.on 'validitychange', (field, valid, eOpts) ->
			if valid
				field.addCls "#{extCSSPrefix}form-valid"
				field.inputRow.addCls "#{extCSSPrefix}form-valid-input-row"
				field.inputEl.addCls "#{extCSSPrefix}form-valid-field"
				me.show()
			else
				field.removeCls "#{extCSSPrefix}form-valid"
				field.inputRow.removeCls "#{extCSSPrefix}form-valid-input-row"
				field.inputEl.removeCls "#{extCSSPrefix}form-valid-field"
				me.hide()
			return

		data =
			inputId: field.id
			cssPrefix: extCSSPrefix
			correctMsg: @correctMsg
		this.html = this.tpl.apply data
		@callParent arguments
		return