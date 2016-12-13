Ext.define 'Corefw.view.form.field.LinkField',
	extend: 'Ext.form.field.Display'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'corelinkfield'
	protocolMap:
		TELEPHONE: 'tel:'
		MAIL: 'mailto:'
	initComponent: ->
		me = @
		props = me.cache?._myProperties or {}
		me.pt = me.protocolMap[props.pseudoProtocol]
		me.callParent arguments
		return
	afterRender: () ->
		me = @
		me.inputEl.addListener 'click', (ev, el) ->
			me.fireEvent 'linkclick', me
		return
	valueToRaw: (val) ->
		if val
			pt = @pt
			val = if pt then "<a href='#{pt}#{val}'>#{val}</a>" else "<a href='javascript:;'>#{val}</a>"
		return val
	rawToValue: (rawVal) ->
		if rawVal
			rawVal = rawVal.replace /<\s*(\S+)(\s[^>]*)?>/g, ''
		return rawVal