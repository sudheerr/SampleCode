Ext.define 'Corefw.view.DomainNavPanel',
	extend: 'Ext.panel.Panel'
	alias: 'widget.domainnavpanel'
	header: false
	width: '100%'
	layout:
		type: 'vbox'
		align: 'stretch'
	items: [
		xtype: 'filterToolBar'
		width: '100%'
		margin: '0 0 0 1'
	,
		xtype: 'filterCriteriaView'
		margin: '0 0 0 1'
	,
		flex: 1
		xtype: 'domainTree'
		margin: '0 0 0 0'
	]
	listeners:
		afterrender: ->
			@down('domainTree').bindFilterStore @down('filterCriteriaView').getStore()
			
	constructor: ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			this.ui = 'mainconfigui'
		@callParent arguments