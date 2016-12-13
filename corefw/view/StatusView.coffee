Ext.define "Corefw.view.StatusView",
	extend: "Ext.view.View"
	xtype: 'statusview'
	itemSelector: "div.statusView"
	statusMsgs: []
	initComponent: ->
		@tpl = new Ext.XTemplate("<tpl for=\".\">",
			"<div class='statusView {[this.getLevel(values)]}'>",
			"<img align='right' class='StausClose'/>",
			"{[this.getMessage(values)]}",
			"</div>",
			"</tpl>",
			compiled: true
			getMessage: (values) ->
				"<span >" + values.text + "</span>"

			getLevel: (values) ->
				values.level
		)
		@store = Ext.create("Ext.data.Store",
			fields: ['text', 'level']
			data: @statusMsgs
			storeId: Ext.id()
		)

		addlListener =
			itemclick: (th, record, item, index, e, eOpts) ->
				if e?.target?.tagName is "IMG"
					store = th.getStore()
					store.removeAt index
					if not store.getCount()
						# hide or destroy, not quite sure about this. current hide for safe
						@hide()
					th.fireEvent 'statusremoved', th, store
					element = th.up 'coreelementform'
					if element
						element.alreadyResize = false
					if element?.layout?.type is 'absolute'
						element.layoutManager.resize()

				return
			removed: (comp)->
				comp.fireEvent 'statusviewremoved', comp
			viewready: (comp, eOpts) ->
				@autoSizeMsgContent comp.store
				return

		@listeners = @listeners or {}
		Ext.apply @listeners, addlListener

		@callParent arguments
		return

	autoSizeMsgContent: () ->
		items = @store.data.items
		msgBarMaxWidth = @getWidth() - 40
		msgBarDom = @el.dom
		msgDoms = Ext.DomQuery.select 'span', msgBarDom
		testText = []
		for msg,i in items
			text = msg.raw.text
			msgDom = msgDoms[i]
			if msgDom.offsetWidth <= msgBarMaxWidth
				continue
			else
				for s,j in text
					testText.push s
					msg.set 'text', testText.join ''
					dom = Ext.DomQuery.select('span', msgBarDom)[i]
					if dom.offsetWidth > msgBarMaxWidth
						break

				msg.set 'text', text.substr(0, j - 2) + '...'
				Ext.create 'Ext.tip.ToolTip',
					target: Ext.DomQuery.select('span', msgBarDom)[i]
					html: msg.raw.text
		return
