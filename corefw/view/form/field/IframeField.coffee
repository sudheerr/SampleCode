Ext.define 'Corefw.view.form.field.IframeField',
	extend: 'Ext.form.FieldContainer'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'coreiframefield'

	frame: false
	hideLabel: true
	iframe: null
	overflowX: 'auto'
	overflowY: 'auto'

	initComponent: ->
		myName = @cache._myProperties.name

		elemCache = @element.cache
		elemData = elemCache?._myProperties?.data
		if elemData
			iframeUrl = elemData[myName]

		myMaxHeight = @maxHeight - 5
		myHeight = @height
		myWidth = @width - 10

		comp = Ext.create 'Ext.ux.IFrame',
			height: myHeight
			maxHeight: myMaxHeight
			maxWidth: myWidth
			src: iframeUrl

		@iframe = comp
		@items = [comp]

		Corefw.customapp.Main.mainEntry 'iframeInit', this
		@callParent arguments

		return



# function called when this component is first rendered
	onRender: ->
		@callParent arguments
		return