Ext.define 'Corefw.store.session.SessionStore',
	extend: 'Ext.data.Store'
	requires: ['Corefw.model.session.SessionModel']
	model: 'Corefw.model.session.SessionModel'
	storeId: "mycombostoresessionid"
	autoLoad: true
	proxy:
		type: "sessionstorage"
		id: "localproxy"
