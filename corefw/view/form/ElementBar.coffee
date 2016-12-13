Ext.define 'Corefw.view.form.ElementBar',
	extend: 'Corefw.view.form.ElementForm'
	xtype: 'coreelementbar'


# initialize will call this additional function if it exists,
# 		before completing initialization
	additionalConfig: ->
		# hide title, but the header is always visible
		addlConfig =
			title: '&nbsp;'
			header: true
			closable: false
			collapsible: false
			collapsed: true
			hideCollapseTool: true
			isBarElement: true
		Ext.apply this, addlConfig
		return

	updateUIData: (cache) ->
		su = Corefw.util.Startup
		@cache = cache
		data = cache._myProperties.data
		if not data
			# data doesn't exist, nothing to show
			return

		header = @down 'header'
		if not header
			# this should never happen, we set header to true before initializing
			return

		# add field data to the header
		# use xsize to set flex amounts, all other coordinates ignored

		header.removeAll?()
		@initializeConstants()
		for key, fieldObj of cache
			if key isnt '_myProperties'
				props = fieldObj._myProperties
				if props.type is 'LINK'
					fieldDef = @genFieldDef fieldObj
					if fieldDef
						fieldDef.labelAlign = 'left'
						fieldDef.value = data[key]
						fieldDef.flex = props.coordinate.xsize
						header.add fieldDef
				else
					if su.getThemeVersion() is 2
						displayStr = "<span class=\"x-form-item-label\" style=\"text-transform: uppercase;margin-top: 2px;line-height:14px;color:#fff;font-size:14px;\" title= \"#{props.toolTip}\">#{props.title} <span style=\"font-weight:normal;\">#{data[key]}</span></span>"
					else
						displayStr = "<span class=\"x-form-item-label\" title= \"#{props.toolTip}\">#{props.title} <span style=\"font-weight:normal;\">#{data[key]}</span></span>"
					header.add
						xtype: 'container'
						html: displayStr
						flex: props.coordinate.xsize
		@deleteConstants()
		return


	afterRender: ->
		@callParent arguments
		@updateUIData @cache

		return


# generate and return nothing
	generatePostData: ->
		postData =
			name: @cache._myProperties.name

		return postData