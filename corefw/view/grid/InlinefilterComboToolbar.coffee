Ext.define 'Corefw.view.grid.InlinefilterComboToolbar',
	extend: 'Ext.toolbar.Toolbar'
	alias: 'widget.inlinefilterComboToolbar'
	alternateClassName: 'Ext.InlinefilterComboToolbar'
	mixins:
		bindable: 'Ext.util.Bindable'
	refreshText: 'OK'
	initComponent: ->
		me = this
		pagingItems = [ {
			tooltip: me.refreshText
			overflowText: me.refreshText
			ui: 'filter-btn'
			xtype: 'button'
			text: me.refreshText
			handler: me.doApplyfilter
			scope: me,
			width: '100%'
		} ]
		userItems = me.items or me.buttons or []
		me.items = pagingItems.concat(userItems)
		me.callParent()
		me.addEvents  'submitfiltervalue'
		return
	doApplyfilter: ->
		me = this
		current = me.store.currentPage
		me.fireEvent 'submitfiltervalue', me, current

