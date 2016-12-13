Ext.define 'Corefw.view.form.field.HtmlEditor',
	extend: 'Ext.form.field.HtmlEditor'
	xtype: 'corehtmleditor'
# @override
	initFrameDoc: ->
		me = this
		if Ext.isIE
			me.callParent arguments
			return
		Ext.TaskManager.stop me.monitorTask
		doc = me.getDoc()
		me.win = me.getWin()
		# for jira 7924: might make scroll bar messed up
		me.iframeEl.el.dom.src = "javascript:''"
		doc.open()
		doc.write me.getDocMarkup()
		doc.close()
		task = # must defer to wait for browser to be ready
			run: ->
				doc = me.getDoc()
				if doc.body or doc.readyState is 'complete'
					Ext.TaskManager.stop task
					me.setDesignMode true
					Ext.defer me.initEditor, 10, me
			interval: 10
			duration: 10000
			scope: me
		Ext.TaskManager.start task
		return

	setValue: (val) ->
		val or= ''
		try
			value = decodeURI val
		catch
			value = val
		return @callParent [value]

	getValue: ->
		return encodeURI @callParent arguments