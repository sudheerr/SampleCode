Ext.define 'Corefw.view.form.Fieldset',
	extend: 'Ext.form.FieldSet'
	mixins: ['Corefw.mixin.FieldContainer']
	xtype: 'corefieldset'
	style:
		margin: '0 0 0 0'
		padding: '0px 0px 0px 0px'
	listeners:
		afterlayout: ->
			if @resizeWhenVisible
				@layoutManager?.resize?()
				delete @resizeWhenVisible
			return
	initComponent: ->
		me = @
		layout = Corefw.view.layout.Layout
		me.layoutManager = layout.create me

		props = me.cache?._myProperties or {}
		this.title = props.title if props.title
		me.uipath = props.uipath

		me.callParent arguments

		me.disableFormEvents = true

		me.layoutMain()
		me.renderTooltips()
		# TODO to be deleted after confirm
		# below line looks deprecated, layoutmain has already taken care of form data display
		Corefw.util.Data.displayFormData this, me.cache

		me.disableFormEvents = false
		return
	onResize: ->
		this.layoutManager.resize @
		return
	loadRecord: (record) ->
		Ext.suspendLayouts()
		data = record.getData()
		me = @
		Ext.Object.each data, (fName, fVal) ->
			fObj = me.child("[name=#{fName}]")
			if fObj and fObj.setValue
				fObj.setValue fVal
		Ext.resumeLayouts true
		return