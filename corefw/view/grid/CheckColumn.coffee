Ext.define 'Corefw.view.grid.CheckColumn',
	extend: 'Ext.grid.column.CheckColumn'
	xtype: 'corecheckcolumn'

	disableSelection:false # disable or enable selecting action on select button on column
	enableAllSelecting:true # enable or disable the selecting all button on the header of column
	headerCheckAllCls:Ext.baseCSSPrefix + 'column-header-selection'
	unCheckedCls:Ext.baseCSSPrefix + 'grid-checkcolumn'
	checkedCls:Ext.baseCSSPrefix + 'grid-checkcolumn-checked'
	selModel:'checkAllModel' 

	renderTpl:
		'<div id="{id}-titleEl" {tipMarkup} class="' + Ext.baseCSSPrefix + 'column-header-inner checkcolumn">' +
			'<table id="{id}-textEl" class="' + Ext.baseCSSPrefix + 'column-header-text' +
				'{childElCls}" style="border-spacing:0; padding:0">' +
				'<tr>'+
					'<tpl if="enableAllSelecting">'+
						'<td style="padding:0">'+
							'<img style="z-index:10;margin-top:2px;margin-left:-2px;" id="{id}-checkAllEl" class="{headerCheckAllCls} {unCheckedCls}" src="' + Ext.BLANK_IMAGE_URL + '"/>' +
						'</td>'+
					'</tpl>' +
					'<td style="padding:0"><span class="x-column-header-text">'+
						'{text}' +
					'</span></td>'+
				'</tr>'+
			'</table>' +
			'<tpl if="!menuDisabled">'+
				'<div id="{id}-triggerEl" class="' + Ext.baseCSSPrefix + 'column-header-trigger' +
				'{childElCls}"></div>' +
			'</tpl>' +
		'</div>' +
		'{%this.renderContainer(out,values)%}'

	initRenderData:->
		me = @
		Ext.applyIf me.callParent(arguments),
			enableAllSelecting:me.enableAllSelecting
			headerCheckAllCls:me.headerCheckAllCls
			unCheckedCls:me.unCheckedCls

	renderSelectors:
		checkAllEl:'.'+Ext.baseCSSPrefix + 'column-header-selection'

	initComponent:->
		me = @
		me.selModel = 'checkAllModel' if not me.selModel
		me.enabled = me.cache._myProperties.enabled
		Ext.applyIf @renderData,
			enableAllSelecting:@enableAllSelecting
		@callParent arguments
		@addEvents(
			#	fire the event before checkAllEl clicking
			'beforecheckall',
			#	fire the event after checkAllEl clicked
			'checkall'
		)
		return

	setDisableSelection: (disable) ->
		@disableSelection = disable
		cache = @cache
		if cache
			props = @cache._myProperties
			if props
				editable = props.editable
				if editable is false
					@disableSelection = true
		return


	processEvent: (type, view, cell, recordIndex, cellIndex, e, record, row) ->
		me = @
		if me.disableSelection
			return false
		return @callParent arguments

	onTitleElClick: (e,t) ->
		me = @
		isCheckAllTarget = me.checkAllEl and e.target.classList.contains "x-column-header-selection"
		return @callParent arguments if me.disableSelection or not isCheckAllTarget
		view = me.up().grid.getView()
		if me.fireEvent('beforecheckall', me,view) isnt false
			checkAllEl = me.checkAllEl
			dataIndex = me.dataIndex
			checkedAll = not checkAllEl.el.dom.classList.contains me.checkedCls
			if checkedAll
				checkAllEl.el.addCls me.checkedCls
			else
				checkAllEl.el.removeCls me.checkedCls

			records = view.store.data.items
			for record in records
				if me.selModel is 'checkAllModel'
					checked = checkedAll
				else
					checked = !record.get dataIndex
				record.set dataIndex,checked

			return me.fireEvent 'checkall', me,view
		else
			return false
			
	renderer: (value, metaData, record, rowIndex, colIndex, store) ->
		pathString = metaData?.column?.pathString or @pathString
		if not @dataCache
			@dataCache = Corefw.util.Uipath.uipathToParentComponent(@uipath)?.cache?._myProperties.items or []
		metaData.tdCls = metaData.tdCls or ""
		# mark checkbox as disabled
		if not @enabled
			metaData.tdCls += ' x-item-disabled'
		# mark checkbox as disabled/enabled by disabledHeaders/enabledHeaders
		if rowDataCache = @dataCache[rowIndex]
			disabledHeaders = rowDataCache.disabledHeaders
			enabledHeaders = rowDataCache.enabledHeaders
			if disabledHeaders.filter((p)-> p is pathString).length > 0
				metaData.tdCls = metaData.tdCls.replace 'x-item-disabled',''
				metaData.tdCls += ' x-item-disabled'
			else if enabledHeaders.filter((p)-> p is pathString).length > 0
				metaData.tdCls = metaData.tdCls.replace 'x-item-disabled',''
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			if value
				metaData.tdCls += ' gridCheckedCls'
		
		if @cache._myProperties.eventURLs?['ONCLICK']
			metaData.style = metaData.style + ";cursor:pointer"
		@callParent arguments

