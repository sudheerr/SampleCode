Ext.define 'Corefw.data.reader.Json',
	extend: 'Ext.data.reader.Json'
	xtype: 'corejsonreader'
	getResponseData: (response) ->
		try
			data = Ext.decode response.responseText
			if jsonResolver = @jsonResolver
				data = jsonResolver.call this, data
			return @readRecords data
		catch err
			ret = new Ext.data.ResultSet
				total: 0
				count: 0
				records: []
				success: false
				message: err.message
			@fireEvent 'exception', this, response, ret
			Ext.Logger.warn 'Unable to parse the JSON returned by the server'