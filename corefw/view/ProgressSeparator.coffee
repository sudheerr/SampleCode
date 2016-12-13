Ext.define 'Corefw.view.ProgressSeparator',
	extend: 'Ext.container.Container'
	xtype: 'coreprogressseparator'
	width: 30

	initComponent: ->
		version = Corefw.util.Startup.getThemeVersion()
		if @isSequential
			if version isnt 2
				@items = [
					xtype: 'image'
					src: 'resources/images/progressIndicatorImages/progress_15x17.png'
					padding: '6 0 0 8'
				]
		else
			if version is 2
				@items = [
					xtype: 'panel'
					width: 23
					height: 24
					border: false
					margin: false
					padding: '0 0 0 0'
				]
			else
				@items = [
					xtype: 'panel'
					width: 30
					height: 30
					border: false
					margin: false
					padding: '13 0 0 0'
					bodyStyle:
						background: 'url(resources/images/progressIndicatorImages/separatorLine.png) repeat-x'
				]
		@callParent arguments