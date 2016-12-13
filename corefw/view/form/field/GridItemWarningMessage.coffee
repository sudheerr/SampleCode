Ext.define 'Corefw.view.form.field.GridItemWarningMessage',
	xtype: 'coregriditemwarningmessage'
	constructor: (config) ->
		me = @
		extCSSPrefix = Ext.baseCSSPrefix
		fieldWarningCls = extCSSPrefix + 'form-warning-field'
		ownerField = config.field
		ownerEl = ownerField.inputEl

		ownerEl.addCls fieldWarningCls
		ownerField.on 'change', (field) ->
			me.clearMessage()
			return

		tooltip = Ext.create 'Ext.tip.ToolTip',
			ui: 'tooltip-warning'
			target: ownerEl,
			renderTo: Ext.getBody()

		@showMessage = (message) ->
			ownerEl.addCls fieldWarningCls
			tooltip.enable()
			tooltip.update message
			if ownerEl
				ownerElPosition = ownerEl.getXY()
				ownerElPosition[1] = ownerElPosition[1] + ownerEl.getHeight() + 2
				tooltip.showAt ownerElPosition
			return

		@clearMessage = ->
			ownerEl.removeCls fieldWarningCls
			tooltip.disable()
			return

		return
