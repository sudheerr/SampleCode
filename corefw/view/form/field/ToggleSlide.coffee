Ext.define "Corefw.view.form.field.ToggleSlide",
	extend: "Ext.form.field.Base"
	mixins: ['Corefw.mixin.CoreField']
	alias: "widget.coretoggleslidefield"
	fieldSubTpl: [
		"<div id=\"{id}\" class=\"{fieldCls}\"></div>"
		{
			compiled: true
			disableFormats: true
		}
	]
	value: null

# Initialize the component.
# @private
	initComponent: ->
		me = this
		cfg = id: me.id + "-toggle-slide"
		t = null
		cfg = Ext.copyTo(cfg, me.initialConfig, [
			"onText"
			"offText"
			"resizeHandle"
			"resizeContainer"
			"background"
			"onLabelCls"
			"offLabelCls"
			"handleCls"
			"state"
			"booleanMode"
		])
		cfg.state = me.initialConfig.value  if me.initialConfig.value
		if me.initialConfig.booleanMode is false
			t = (if me.initialConfig.state then me.initialConfig.onText or "ON" else me.initialConfig.offText or "OFF")
		else
			t = me.initialConfig.value or me.initialConfig.state or false
		me.initialConfig.value = t
		me.value = t
		me.toggle = new Corefw.view.form.field.toggle.ToggleSlide(cfg)
		me.callParent arguments
		return

	onRender: (ct, position) ->
		me = this
		me.callParent arguments
		me.toggle.render me.inputEl
		me.setRawValue me.toggle.getValue()
		return


#Initialize any events for this class.
#@private
	initEvents: ->
		me = this
		me.callParent()
		me.toggle.on "change", me.onToggleChange, me
		return

#Utility method to set the value of the field when the toggle changes.
#@param {Object} toggle The toggleSlide object.
#@param {Object} v The new value.
#@private
	onToggleChange: (toggle, state) ->
		@setValue state

	setValue: (value) ->
		me = this
		toggle = me.toggle
		return  if value is me.value or value is `undefined`
		me.callParent arguments
		toggle.toggle()  unless toggle.getValue() is value
		me

#Utility method to set the value of the field when the toggle changes.
#@param {Object} toggle The toggleSlide object.
#@param {Object} v The new value.
#@private
	onChange: (toggle, state) ->


		#return this.setValue(state);

		#Enable the toggle when the field is enabled.
		#@private
	onEnable: ->
		Corefw.view.form.field.ToggleSlide.superclass.onEnable.call this
		@toggle.enable()
		return

#Disable the toggle when the field is disabled.
#@private
	onDisable: ->
		Corefw.view.form.field.ToggleSlide.superclass.onDisable.call this
		@toggle.disable()
		return

#Ensure the toggle is destroyed when the field is destroyed.
#@private
	beforeDestroy: ->
		Ext.destroy @toggle
		@callParent()
		return
