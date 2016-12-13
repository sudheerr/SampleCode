Ext.define 'Corefw.view.ProgressStep',
	extend: 'Ext.Component'
	xtype: 'coreprogressstep'

	relativeImgPath: 'resources/images/progressIndicatorImages/'
	imgExtension: '.png'

	renderTpl: '<div id={id} class="{status} step">' +
		'<label>' +
		'{title}' +
		'</label>' +
		#			'<div>{status}</div>' +
		'<tpl>' +
		'{imgHtml}' +
		'</tpl>' +
		'</div>'

	initComponent: ->
		version = Corefw.util.Startup.getThemeVersion()
		viewProps = @viewProps
		status = @calStatus viewProps
		if version is 2
			@renderTpl = '<div id={id} class="{status} step">' +
					'<span>&nbsp;</span>' +
					'<label>' +
					'{title}' +
					'</label>' +
					#			'<div>{status}</div>' +
					'</div>'
		config =
			title: viewProps.title
			status: status
		# terrible logic in cache parser...
			visible: viewProps.visible
			disabled: not viewProps.enabled
			uipath: viewProps.uipath + '/progressStep'

		Ext.apply @, config

	calStatus: (viewProps) ->
		if viewProps.valiationStatus is 'FAILED'
			return 'error'
		if viewProps.active
			status = 'current'
		else if viewProps.visited
			errArray = viewProps.messages?.ERROR
			if (errArray and errArray.length)
				status = 'error'
			else
				# Unrealize function to identify the view is completed
				if viewProps.completed is false
					status = 'draft'
				else
					status = 'complete'
		else
			status = 'incomplete'

		if viewProps.enabled is false
			status = 'disable'

		return status

	initRenderData: ->
		version = Corefw.util.Startup.getThemeVersion()
		me = @
		status = me.status
		imgHtml = @getImgHtml status
		Ext.applyIf me.callParent(arguments),
			title: me.title
			status: status
			imgHtml: if version isnt 2 then imgHtml else ''

	renderSelectors:
		statusDiv: '.step'
		statusImg: '.step img'

	getImgSrc: (status) ->
		return @relativeImgPath + status + @imgExtension

	getImgHtml: (status) ->
		imgSrc = @getImgSrc status
		return '<img src="' + imgSrc + '">'

	setStatus: (status)  ->
		version = Corefw.util.Startup.getThemeVersion()
		@status = status
		@statusDiv.dom.className = status + ' step x-box-item'
		if status in ['current', 'complete', 'error', 'incomplete']
			@enable()
			if version isnt 2
				if @statusImg
					@statusImg.dom.src = @getImgSrc(status)
				else
					img = document.createElement 'img'
					img.src = @getImgSrc status
					imgEl = @statusDiv.appendChild img
					@statusImg = imgEl
		else
			@enable()
			if version isnt 2
				if @statusImg
					@statusImg.remove()
					@statusImg = null
		if status is 'disable'
			@disable()

	listeners:
		click:
			element: 'el'
			fn: (ev) ->
				step = Ext.getCmp @id
				uipath = step.viewProps.uipath
				view = Ext.ComponentQuery.query('[uipath=' + uipath + ']')[0]
				tab = view.tab
				tab.fireEvent 'click', tab

