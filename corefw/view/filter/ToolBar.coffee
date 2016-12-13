Ext.define 'Corefw.view.filter.ToolBar',
	extend: 'Ext.toolbar.Toolbar'
	alias: 'widget.filterToolBar'
	mixins: [
		'Corefw.mixin.Sharable'
		'Corefw.mixin.UiPathAware'
	]
	editable: false
	layout: 'hbox'
	cls: 'bright'

	items: [
		xtype: 'combo'
		flex: 1
		valueField: 'criteria'
		cls: 'icon-within new-filter-bg'
		queryMode: 'local'
		store: Ext.create 'Ext.data.Store',
			fields: ['id', 'name', 'criteria', 'sourceId']
			proxy:
				type: 'rest'
				url: 'api/pivot/globalConfig/filter'
				batchActions: true
				actionMethods:
					create: 'PUT'
					destroy: 'DELETE'
				reader:
					type: 'json'
				writer:
					type: 'deepJson'
					root: 'filter'
		listConfig:
			maxWidth: 500
			listeners: 
				beforerender: ->
					@minWidth = @up('combo').getWidth()
				itemclick: (list, record, item, index, e)->
					me = this
					if Ext.fly(e.target).hasCls('icon-delete') and me.store.indexOf(record) > -1
						Corefw.Msg.confirm 'Confirm', 'Are you sure to remove the filter?', (button)->
						    if button is 'yes'
						    	me.up('filterToolBar').deleteFilter record
						return false
				select: (combo, record)->
					filterStore = @up('domainnavpanel').down('filterCriteriaView').store
					filterStore.refreshCriteriaStore record.get('criteria')

		matchFieldWidth: false
		displayField: 'name'
		tpl: Ext.create 'Ext.XTemplate',
				'<tpl for="."><tpl if="this.isNewFilter(name, sourceId)">',
				'<div class="x-boundlist-item">{name}</div>',
				'<tpl else>',
				'<div class="x-boundlist-item removable-filter">{name}<span class="icon-delete"></span></div>',
				'</tpl></tpl>',
				isNewFilter: (name, sourceId)->
					return name is 'New Filter' or sourceId isnt null
		editable: false
		currentFilterSavable: ->
			name = @rawValue
			isPreDefined = ! !eval(@findRecord('name', name).data.sourceId + '')
			return name isnt 'New Filter' and not isPreDefined
	,
		xtype: 'button'
		iconCls: 'icon-save'
		align: 'center'
		border: 0
		listeners:
			click: (button, ev)->
				position = [button.getX()+20,button.getY()+20]
				menu = new Ext.menu.Menu
					plain: true
					items: [
						text: 'Save'
						hidden: not button.previousSibling('combo').currentFilterSavable()
						handler: (th, ev)->
							button.up('filterToolBar').addFilter false, position
					,
						text: 'Save As'
						handler: (th, ev)->
							button.up('filterToolBar').addFilter true, position
					]
				menu.showAt position
	]

	initComponent: ->
		@callParent arguments
		@onSharedUpdate 'filters', @updateDisplay

	updateDisplay: (filters) ->
		combo = @down 'combo'
		@binduipath()
		combo.store.getProxy().setExtraParam 'uipath', @parentuipath
		combo.store.getProxy().getWriter().extraJsonData = uipath: @parentuipath
		store = @up('domainnavpanel').down('filterCriteriaView').store
		filters = @getShared 'filters'
		if filters
			if filters.length is 0
				filters = [
					id: -1
					name: 'New Filter'
					criteria: []
				]
			combo.store.loadData filters
			record = combo.getStore().getAt 0
			combo.select record.get('name')
			store.refreshCriteriaStore record.get('criteria')
			combo.setLoading false
		else
			console.log 'Unable to create FilterToolBar from filters:' + filters

	addFilter: (saveAs, position) ->
		combo = @down 'combo'
		name = combo.rawValue
		store = @up('domainnavpanel').down('filterCriteriaView').getStore()
		criteria = store.getCriteria()
		if criteria.length
			#update
			if not saveAs
				rec = combo.getStore().findRecord 'name', name
				combo.setLoading 'Saving...'
				combo.store.create
					id: rec.get 'id'
					name: rec.get 'name'
					criteria: criteria
					sourceId: rec.get 'sourceId'
				,
					callback: (record, operation, success) ->
						combo.setLoading false
			else
				#save as
				if not @menuI
					@menuI = Ext.create 'Corefw.view.component.MenuWin',
						width: 200
						title: 'Name of the filter'
						plain: true
						cls: 'topShadow'
						items: [ {
							xtype: 'textfield'
							listeners: specialkey: (me, e) ->
								if e.getKey() is e.ENTER
									btn = me.up('menu').down '[name=submit]'
									btn.fireHandler()
								return
						} ]
						bbar: [
							{
								xtype: 'button'
								text: 'Ok'
								width: 55
								cls: 'primaryBtn'
								name: 'submit'
								handler: (btn, e) ->
									m = btn.up('menu')
									filterName = m.down('textfield').getValue()
									rec = combo.getStore().findExact 'name', filterName, 0, false, false, true
									m.hide()
									if rec > -1
										Corefw.Msg.alert 'Rename Filter', 'Filter name already existed.'
										return
									if not filterName.replace(/\s/g, '')
										Corefw.Msg.alert 'Rename Filter', 'Filter name can not be blank!', ->
											m.show()
											return
										return
									if filterName isnt null
										filterName = Corefw.util.Common.stripHtml filterName
										if filterName.length > 49
											Corefw.Msg.alert 'Alert', 'Name too long! Exceeds 50 Characters.'
										else
											combo.setLoading 'Saving...'
											newRec = combo.store.create
												id: -1
												name: filterName
												criteria: criteria
												sourceId: null
											,
												callback: (records, operation)->
													if operation.wasSuccessful()
														record = records[0]
														record.set 'id', parseInt Ext.decode(operation.response.responseText).id
														combo.store.add record
														combo.select record.get('name')
													combo.setLoading false
									return
							}
							'-'
							{
								xtype: 'button'
								text: 'Cancel'
								cls: 'secondaryBtn'
								width: 55
								handler: (btn, e) ->
									btn.up('menu').hide()
									return
							}
						]
				else
					@menuI.down('textfield').setValue ''
				@menuI.showAt position
		else
			Corefw.Msg.alert 'Save', 'Please add criteria before saving.'
			return
		return

	deleteFilter: (record) ->
		combo = @down 'combo'
		combo.setLoading 'Deleting...'
		combo.store.remove record
		combo.store.destroy
			callback: (records, operation)->
				if operation.wasSuccessful()
					combo.setLoading false
					if records[0].get('name') is combo.rawValue
						combo.select combo.store.getAt(0).get('name')
		return