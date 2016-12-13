Ext.define 'Corefw.view.ntf.Notification',
	extend: 'Ext.Component'
	xtype: 'corenotification'
	componentCls: 'cv-notification'
	listeners:
		afterrender: (me) ->
			el = me.el
			animateWithOpacity = ->
				el.animate
					duration: 500
					from:
						opacity: 0
					to:
						opacity: 1
				return
			initAutoClose = ->
				timeoutIndicator = el.down '.cv-notification-timeout-indicator'
				timeout = me.cache?._myProperties?.timeout
				if not timeout
					return
				timeoutIndicator.animate
					duration: timeout * 1000
					from:
						width: '0%'
					to:
						width: '100%'
					listeners:
						afteranimate: ->
							me.destroy()
							return
				return
			initCloseClickEvent = ->
				closeEl = el.down '.cv-notification-close'
				closeEl.on 'click', ->
					el.animate
						duration: 200
						from:
							opacity: 1
						to:
							opacity: 0
						listeners:
							afteranimate: ->
								me.destroy()
								return
					return
				return
			animateWithOpacity()
			initAutoClose()
			initCloseClickEvent()
			return
	tpl: new Ext.Template [
		"<div class='cv-notification-body'>"
		"<div class='cv-notification-icon cv-notification-icon-{messageType}'></div>"
		"<div class='cv-notification-title'>"
		"{title}"
		"</div>"
		"<div class='cv-notification-msg'>"
		"{message}"
		"</div>"
		"<span class='cv-notification-close'>×</span>"
		"</div>"
		"<div class='cv-notification-timeout-indicator'></div>"
	]