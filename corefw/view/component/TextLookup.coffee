Ext.define 'Corefw.view.component.TextLookup',
	extend: 'Ext.form.ComboBox'
	alias: 'widget.textLookup'
	stores: ['TextLookup']
	displayField: 'text'
	minChars: 1
	typeAhead: true
	width: 180
	hideLabel: true
	hideTrigger: true

	listConfig:
		loadingText: 'Searching...'
		emptyText: '<div class="x-boundlist-item">No matching data found.</div>'

	initComponent: ->
		@store = Ext.create 'Corefw.store.TextLookup'
		@callParent arguments
		return