Ext.define 'Corefw.view.crview.ViewPivot',
	extend: 'Ext.container.Container'
	xtype: 'coreviewpivot'
	componentCls: 'cv-viewpivot'
	mixins: ['Corefw.mixin.Sharable']

	layout: 'border'
	eventURLs: []
	timeMarks: null

	listeners:
		afterrender: ->
			Ext.Ajax.request
				url: 'api/pivot/globalConfig'
				method: 'POST'
				scope: this
				params:
					uipath: @uipath
				success: (response) ->
					responseJson = Ext.decode response.responseText
					@updateShared responseJson
			@down('domainnavpanel').down('filterCriteriaView').store.on
				refresh: (store) ->
					@updateShared 'globalFilter', store.getCriteria()
				remove: (store) ->
					@updateShared 'globalFilter', store.getCriteria()
				scope: this

	initComponent: ->
		Corefw.util.Common.copyObjProperties this, @cache._myProperties, [
				'domainName'
				'uipath'
			]
		@callParent arguments
		@updateShared
			'domainName': @domainName
			'reqTimeMarks': @reqTimeMarks.bind this

	updateUIData: (viewCache) ->
		@domainName = viewCache._myProperties.domainName
		@updateShared 'domainName', @domainName

	reqTimeMarks: (cb, scope=this, args...) ->
		if @timeMarks
			cb.apply scope, [@timeMarks].concat(args)
		else
			Ext.Ajax.request
				url: 'api/pivot/timeMark'
				method: 'POST'
				scope: this
				params:
					uipath: @uipath
					domainName: @domainName
				success: (response) ->
					@timeMarks = Ext.decode response.responseText
					cb.apply scope, [@timeMarks].concat(args)

	items: [
		xtype: 'domainnavpanel'
		region: 'west'
		collapsible: true
		split: true
		width: '14%'
	,
		xtype: 'panel'
		region: 'center'
		layout: 'vbox'
		flex: 1
		height: '100%'
		items: [
			{
				xtype: "pivottablefield"
				layout: 'hbox'
				width: '100%'
				flex: 1
			}
		]
	]