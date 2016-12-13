Ext.define 'Corefw.view.ntf.NotificationGroup',
	extend: 'Ext.container.Container'
	xtype: 'corenotificationgroup'
	cls: 'cv-notification-group'
	position: 'right_bottom'
	width: 400
	initComponent: ->
		pos = @position.split '_'
		postAtX = pos[1]
		postAtY = pos[0]
		if postAtX is 'center'
			postAtX = 'x-center'
		if postAtY is 'center'
			postAtY = 'y-center'
		@addCls postAtX
		@addCls postAtY
		@callParent arguments
		return