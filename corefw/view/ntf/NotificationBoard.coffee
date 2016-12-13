Ext.define 'Corefw.view.ntf.NotificationBoard', ->
	# notifications by 9 position
	# ntfGroups =
	# 	'top_left': ''
	# 	'top_center': ''
	# 	'top_right': ''
	# 	'center_left': ''
	# 	'center_center': ''
	# 	'center_right': ''
	# 	'bottom_left': ''
	# 	'bottom_center': ''
	# 	'bottom_right': ''
	ntfGroups = {}
	return {
	singleton: true
	notify: (ntfsCache) ->
		props = ntfsCache._myProperties
		messageType = props.messageType.toLowerCase()
		notification =
			xtype: 'corenotification'
			cls: "cv-notification-#{messageType}"
			cache: ntfsCache
			data:
				title: props.title
				messageType: messageType
				message: props.message
		nPos = props.position
		if not nPos
			return
		nPos = nPos.toLowerCase()

		ntfGroup = ntfGroups[nPos]
		if not ntfGroup
			ntfGroup = Ext.widget 'corenotificationgroup',
				renderTo: Ext.getBody()
				position: nPos
			ntfGroups[nPos] = ntfGroup
		if nPos.split('_')[0] is 'bottom'
			ntfGroup.add notification
		else
			ntfGroup.insert 0, notification
		return
	}