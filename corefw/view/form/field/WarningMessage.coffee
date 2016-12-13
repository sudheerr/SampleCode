Ext.define 'Corefw.view.form.field.WarningMessage',
	extend: 'Ext.Component'
	xtype: 'corefieldwarningmessage'
	ui: 'field-warningmessage'
	tpl: new Ext.Template "<td role='presentation' id='{inputId}-sideWarningCell' valign='bottom' width='17'>
		<div role='presentation' id='{inputId}-warningEl' class='{cssPrefix}form-warning-icon'></div>
	</td>"
	autoEl: 'td'
	listeners:
		afterrender: (me, eOpts) ->
			Ext.create 'Ext.tip.ToolTip',
				ui: 'tooltip-warning'
				target: me.el,
				renderTo: Ext.getBody()
				html: me.message
			return

	initComponent: ->
		ownerField = this.field
		me = @
		extCSSPrefix = Ext.baseCSSPrefix
		fieldWarningCls = extCSSPrefix + 'form-warning-field'

		ownerField.inputEl.addCls fieldWarningCls

		ownerField.on 'change', (field) ->
			if me.isVisible()
				me.hide()
				field.inputEl.removeCls fieldWarningCls
			return

		data =
			inputId: ownerField.id
			cssPrefix: extCSSPrefix

		this.html = this.tpl.apply data

		@callParent arguments
		return