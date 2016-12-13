Ext.define 'Corefw.data.writer.Json',
	extend: 'Ext.data.writer.Json'
	alias: 'writer.deepJson'

	writeRecords: (request, data)->
		request = @callParent arguments
		if @extraJsonData
			Ext.apply request.jsonData, @extraJsonData
		return request

	# This function overrides the default implementation of json writer. Any hasMany relationships will be submitted
	# as nested objects. When preparing the data, only children which have been newly created, modified or marked for
	# deletion will be added. To do this, a depth first bottom -> up recursive technique was used.
	# 
	getRecordData: (record)->
		# Setup variables
		me = this
		data = record.data

		# Iterate over all the hasMany associations
		i = 0
		while i < record.associations.length
			association = record.associations.get i
			data[association.name] = null
			childStore = record[association.storeName]
			#Iterate over all the children in the current association
			childStore.each (childRecord) ->
				if not data[association.name]
					data[association.name] = []
				#Recursively get the record data for children (depth first)
				childData = @getRecordData.call this, childRecord

				###
				# If the child was marked dirty or phantom it must be added. If there was data returned that was neither
				# dirty or phantom, this means that the depth first recursion has detected that it has a child which is
				# either dirty or phantom. For this child to be put into the prepared data, it's parents must be in place whether
				# they were modified or not.
				###

				if childRecord.dirty or childRecord.phantom or childData isnt null
					data[association.name].push childData
					record.setDirty()
				return
			, me

			###
			# Iterate over all the removed records and add them to the preparedData. Set a flag on them to show that
			# they are to be deleted
			###

			# Ext.each childStore.removed, (removedChildRecord) ->
			# 	#Set a flag here to identify removed records
			# 	removedChildRecord.set 'forDeletion', true
			# 	removedChildData = @getRecordData.call this, removedChildRecord
			# 	data[association.name].push removedChildData
			# 	record.setDirty()
			# 	return
			# , me
			i++
		#Only return data if it was dirty, new or marked for deletion.
		#if record.dirty or record.phantom or record.get('forDeletion')
		#	return data;
		return data