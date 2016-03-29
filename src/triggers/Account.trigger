/*
** Trigger: Account
** SObject: Account
** Created: 3/23/2016 by OpFocus, Inc. (www.opfocus.com)
** Description: Contains code to demo various ways of launching asynchronous jobs
*/
trigger Account on Account (before insert, before update, after insert, after update) {

	// For demonstrating @future method
	if (GeocodingUtils.useFutureMethod) {
	
		if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
			// For each new Account or each existing Account whose Address has changed, geocode it
			for (Account acct : Trigger.new) {
				if (Trigger.isInsert || 
				    (Trigger.isUpdate && GeocodingUtils.addressChanged(acct, Trigger.oldMap.get(acct.Id)))) {
				    	
				    // Geocode the Account's address
					GeocodingFuture.geocodeAccountFuture(acct.Id);
				} 
			} 
		}
	}
	
	// For demonstrating Queueable class
	if (GeocodingUtils.useQueueableMethod) {
	
		if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
			// For each new Account or each existing Account whose Address has changed, get ready to geocode it
			Account[] lstAccounts = new Account[]{};
			for (Account acct : Trigger.new) {
				if (Trigger.isInsert || 
				    (Trigger.isUpdate && GeocodingUtils.addressChanged(acct, Trigger.oldMap.get(acct.Id)))) {
				    Account acctGeo = new Account(Id=acct.Id);
				    acctGeo.BillingStreet = acct.BillingStreet;
				    acctGeo.BillingCity = acct.BillingCity;
				    acctGeo.BillingState = acct.BillingState;
				    acctGeo.BillingPostalCode = acct.BillingPostalCode;
				    acctGeo.BillingCountry = acct.BillingCountry;
				    lstAccounts.add(acctGeo);
				} 
			} 

			if (!lstAccounts.isEmpty()) {
			    // Enqueue the job to geocode the Accounts' addresses
				GeocodingQueueable cls = new GeocodingQueueable();
				cls.lstAccounts = lstAccounts;
				Id jobID = System.enqueueJob(cls);
			}
		}
	}
	
	
	// For demonstrating Batchable Apex
	if (GeocodingUtils.useBatchableMethod) {
	
		if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
			// For each new Account or each existing Account whose Address has changed, 
			// flag it to be geocoded later by a Batch Apex job
			for (Account acct : Trigger.new) {
				if (Trigger.isInsert || 
				    (Trigger.isUpdate && GeocodingUtils.addressChanged(acct, Trigger.oldMap.get(acct.Id)))) {
				    	
				    acct.Need_to_Geocode__c = true;
				} 
			} 
		}
	}
}