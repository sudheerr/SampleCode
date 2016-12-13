# rewrite ux citiriskprogressindicatorstep since hard to override methods.
Ext.define 'Corefw.view.ProgressIndicatorStep',
	extend: 'Ext.panel.Panel'
	mixins:
		Observable: 'Ext.util.Observable'
	enabled: false
	config:
		stepNumber: 1
		stepClickHandler: 'stepClicked'
		status: 'incomplete'
		isValidated: false
		stepTitle: ''
		stateIcon: ''
	xtype: 'progressindicatorstep'

	initComponent: ->
		me = @
		me.border = false
		me.margin = false
		me.height = if Corefw.util.Startup.getThemeVersion() is 2 then 24 else 30
		me.itemId = if me.stepId is undefined then me.stepTitle + "-" + me.stepNumber + "-id" else me.stepId

		switch me.status
			when 'current'
				me.cls = 'current'
			when 'complete'
				me.cls = 'complete'
			when 'error'
				me.cls = 'error'
			when 'saved'
				me.cls = 'saved'
			when 'draft'
				me.cls = 'draft'
			else
				me.cls = 'incomplete'

		me.listeners = me.listeners or {}
		addlListeners =
			afterrender: (step) ->
				Ext.QuickTips.init()
				Ext.create 'Ext.tip.ToolTip',
					target: step.getEl()
					html: step.stepTitle

				step.mon step.getEl(), 'click', (step) ->
					if me.disabled
						return
					else
						me.stepClickHandler()
					return
				, step
				step.getEl().on 'mouseenter', () ->
					step.getEl().setStyle 'cursor', 'pointer'
				, step
				step.getEl().on 'mouseover', () ->
					step.getEl().setStyle 'cursor', 'pointer'
				, step
				step.getEl().on 'mouseleave', () ->
					step.getEl().setStyle 'cursor', 'normal'
				, step
				return
		Ext.apply @listeners, addlListeners
		@callParent arguments
		return

	add: ->
		@callParent arguments
		return

	doComponentLayout: ->
		@callParent arguments
		return
