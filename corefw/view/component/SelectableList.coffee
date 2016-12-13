Ext.define 'Corefw.view.component.SelectableList',
	extend: 'Ext.view.View'
	alias: 'widget.selectableList'
	requires: [
		'Corefw.util.Formatter'
		'Corefw.store.TextLookup'
	]
	itemSelector: 'div.iemFisDtV'
	emptyText: ''
	minHeight: 120
	maxHeight: 180
	minWidth: 230
	autoScroll: true
	checkboxes: []

	listeners:
		refresh: (me, eOpts) ->
			me.checkboxes = []
			renderSelector = Ext.query 'div.iemFisDtV', me.el.dom
			for i of renderSelector
				rc = @store.getAt(i).data
				me.checkboxes.push Ext.create('Ext.form.field.Checkbox',
					boxLabel: me.labelRender rc, me
					inputValue: rc.text
					checked: me.checked rc, me
					renderTo: renderSelector[i])
			return

	initComponent: ->
		@store = Ext.create 'Corefw.store.TextLookup'
		@tpl = new Ext.XTemplate('<tpl for=".">',
								'<div class="iemFisDtV">',
								'</div>',
								'</tpl>',
								{ compiled: true },
								listStore: @store)
		@callParent()
		return

	labelRender: (operand, me) ->
		return operand.text

	checked: (operand, me) ->
		return false