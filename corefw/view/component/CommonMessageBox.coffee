Ext.define 'Corefw.view.component.CommonMessageBox', {
	extend: 'Ext.window.MessageBox'
	buttonCls: [
		'primaryBtn'
		'primaryBtn'
		'secondaryBtn'
		'secondaryBtn'
	]
	autoScroll: true
	constructor: ->
		@callParent arguments
		@QUESTION += ' icon-help'
		@ERROR += ' icon-alert'
		return
	initConfig: (config) ->
		@callParent arguments
		return
	makeButton: (btnIdx) ->
		me = this
		btnId = me.buttonIds[btnIdx]
		new (Ext.button.Button)(
			handler: me.btnCallback
			height: 28
			cls: me.buttonCls[btnIdx]
			itemId: btnId
			scope: me
			text: me.buttonText[btnId]
			minWidth: 60)
	alert: (cfg, msg, fn, scope) ->
		if Ext.isString(cfg)
			cfg =
				title: cfg
				msg: msg
				icon: @ERROR
				buttons: @OK
				fn: fn
				scope: scope
				minWidth: @minWidth
		@show cfg

}, ->

	###*
	# @singleton
	# Singleton instance of {@link Corefw.view.component.CommonMessageBox}.
	###

	Corefw.Msg = new (this)
	return