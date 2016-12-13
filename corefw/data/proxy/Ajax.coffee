Ext.define 'Corefw.data.proxy.Ajax',
	extend: 'Ext.data.proxy.Ajax'
	alias: 'proxy.coreajax'

	buildRequest: ->
		request = @callParent arguments
		params = request.params
		data = Ext.encode params
		params = {data: data}
		request.params = Ext.Object.toQueryString params
		return request

	encodeSorters: (sorts) ->
		# sortParam = sortHeaders
		# simpleSortMode = false
		# {
		# "name": "customerId",
		# "sortBy": "ASC"
		#
		#
		sortHeader = []
		for item of sorts
			a = {}
			a.name = sorts[item].name
			a.sortBy = sorts[item].direction
			sortHeader.push a
		return sortHeader

#  coffee

#		encodeSorters: function(b) {
#		var headers = [];
#
#		for ( s in b){
#	var a = {};
#		a.name = "osuc";
#		a.sortBy = b[s].direction;
#		headers.push(a);
#		}
#
#		return headers
#		}