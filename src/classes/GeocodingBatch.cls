/*
** Class: GeocodingBatch
** Created: 3/23/2016 by OpFocus, Inc. (www.opfocus.com)
** Description: Contains a Batch Apex job to geocode all Accounts where Need_to_Geocode__c is true.
*/
global class GeocodingBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

	// To make this meaningful between invocations, must use Database.Stateful
	global Integer numberOfAccountsUpdated = 0;
	
    
	// Start method identifies all Accounts that need to be geocoded
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'select id from Account where Need_to_Geocode__c = true';
		return Database.getQueryLocator(query);
	}
	
	
	// Execute method is called with a subset of the returns returned by the start method
	global void execute(Database.BatchableContext bc, List<SObject> lstSObjects) {
		// Get the Accounts
		Account[] lstAccounts = 
			[select Id, BillingStreet, BillingCity, 
			        BillingState, BillingPostalCode, BillingCountry
			 from   Account
			 where  Id in :lstSObjects];
		
		for (Account acct : lstAccounts) {
			// Geocode the Account and save the results
			GeocodingUtils.LonLat coordinates = GeocodingUtils.geocodeAccount(acct);
			if (coordinates != null) {
				acct.BillingLongitude = coordinates.lon;
				acct.BillingLatitude  = coordinates.lat;
			}
			acct.Need_to_Geocode__c = false;
		}
		
		// Ideally, we'd use Database.update() with AllOrNothing=false and check the individual results
		update lstAccounts;
		
		numberOfAccountsUpdated += lstAccounts.size();
	}
	
	
	// Finish method called after last invocation of execute method
	global void finish(Database.BatchableContext bc) {
		// We could send an email to let someone know how many Accounts we updated
		System.debug('Number of Accounts updated: ' + numberOfAccountsUpdated);
	}
	

}