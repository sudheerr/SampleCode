Ext.define 'Corefw.view.form.field.SwitchBtnGrp',
	extend: 'Ext.container.ButtonGroup'
	xtype: 'coreSwitchBtn'
	activeItem: 0
	frame: false
	titleAlign: 'left'
# To support old theme.
	cls: ['switchBtn', Ext.form.Labelable::formItemCls]
	initComponent: ->
		su = Corefw.util.Startup
		@addEvents 'change'
		props = @cache._myProperties


		@title = if props.title then props.title else '&nbsp'
		@on 'beforerender', @beforeRender, @
		@callParent arguments
		return

	beforeRender: ->
		me = this
		su = Corefw.util.Startup
		@callParent arguments
		me.items.each ((el, c) ->
			Ext.apply el,
				toggleGroup: Ext.id(me)
				clickEvent: 'mousedown'
				enableToggle: true
				allowDepress: false
				ui: 'btngrp'
				height: if su.getThemeVersion() is 2 then 23 else 21
				margin: if su.getThemeVersion() is 2 then 0 else '1 1 0 0'

			if el.pressed
				me.activeItem = el

			me.mon el,
				toggle: me.onToggle
				scope: me

			el.scope = me
			return
		), me

		return

	afterRender: ->
		me = this
		su = Corefw.util.Startup
		maxWidth = 0
		@callParent arguments
		if su.getThemeVersion() is 2
			me.items.each ((el, c) ->
				if el.getWidth() > maxWidth then maxWidth = el.getWidth()
				return
			), me
			me.items.each ((el, c) ->
				Ext.apply el,
					width: maxWidth
				return
			), me
		return


	onToggle: (btn, state)->
		if state is true
			@activeItem = btn
			@fireEvent 'change', btn.scope
		return

	generatePostData: ->
		btn = @activeItem
		val = if btn then btn.inputValue else ''
		name = @name
		fieldObj =
			name: name
			value: val
		return fieldObj