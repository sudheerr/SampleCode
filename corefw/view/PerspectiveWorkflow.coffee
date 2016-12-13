Ext.define 'Corefw.view.PerspectiveWorkflow',
	extend: 'Corefw.view.Perspective'
	xtype: 'coreperspectiveworkflow'
	mixins: ['Corefw.mixin.Perspective']


	initComponent: ->
		@workflowStyle = @cache._myProperties?.layout?.style
		props = @cache._myProperties
		# move from toptabpanel.coffee to here
		props.workflowType = true
		@callParent arguments
		return

	afterRender: ->
		@callParent arguments
		@tabBar.hide()
		return


# adds the toolbar at the very top for all workflow perspectives
	addToolbar: (toolbarCache) ->
		@addToolbarNew toolbarCache, true
		return

	createOrUpdateProgressIndicator: ->
		if @progressIndicator
			@progressIndicator.updateIndicator @cache
			return

		progressIndicator = @progressIndicator = Ext.widget 'coreprogressindicator',
			cache: @cache
			isSequential: if @cache._myProperties.layout.style is 'WORKFLOW_SEQUENTIAL' then true else false

		@addDocked progressIndicator

	addNavs: (props) ->
		rdr = Corefw.util.Render
		rdr.renderNavs props, this, true
		return

	generatePostData: ->
		uip = Corefw.util.Uipath
		#de = Corefw.util.Debug
		postData = @callParent arguments
		toptabpanel = @up 'toptabpanel'
		if toptabpanel
			toolbarUIPath = @cache._myProperties.toolbar?.uipath
			if toolbarUIPath
				toolbarComp = uip.uipathToComponent toolbarUIPath
				if toolbarComp
					toolbarPostData = toolbarComp.generatePostData()
					postData.toolbar = toolbarPostData
		# if de.printOutRawResponse()					
		# 	console.log 'workflow perspective postData: ', postData
		return postData