Ext.define "Corefw.view.form.field.toggle.Thumb",

	#@private
	#@property {Number} topThumbZIndex
	#The number used internally to set the z index of the top thumb (see promoteThumb for details)

	topZIndex: 10000

#@cfg {Ext.slider.MultiSlider} slider (required)
#The Slider to render to.

#Creates new slider thumb.
#@param {Object} [config] Config object.

	constructor: (config) ->
		me = this

		#@property {Ext.slider.MultiSlider} slider
		#The slider this thumb is contained within
		Ext.apply me, config or {},
			cls: Ext.baseCSSPrefix + "toggle-slide-thumb"

		#@cfg {Boolean} constrain True to constrain the thumb so that it cannot overlap its siblings

			constrain: false

		me.callParent [config]
		return

#Renders the thumb into a slider

	render: ->
		me = this
		me.el = me.slider.el.insertFirst(me.getElConfig())
		me.onRender()
		return

	onRender: ->
		@disable()  if @disabled
		return

	getElConfig: ->
		me = this
		#slider = me.slider
		style = {}
		style["left"] = 0
		style: style
		id: @id
		cls: @cls

#@private
#Bring thumb dom element to front.

	bringToFront: ->
		@el.setStyle "zIndex", @topZIndex
		return

#@private
#Send thumb dom element to back.

	sendToBack: ->
		@el.setStyle "zIndex", ""
		@el.setStyle visibility: "hidden"
		return

	disable: ->
