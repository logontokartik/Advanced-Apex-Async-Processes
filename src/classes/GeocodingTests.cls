/*
** Class: GeocodingTests
** Created: 3/23/2016 by OpFocus, Inc. (www.opfocus.com)
** Description: Unit tests for the various Geocoding Async Apex methods
*/
@isTest
private class GeocodingTests {

	// Test the basic Geocoding Service, without any of the async code running
	static testMethod void testWebService() {
		
		GeocodingUtils.useFutureMethod    = false;
		GeocodingUtils.useQueueableMethod = false;
		GeocodingUtils.useBatchableMethod = false;
	
		Test.setMock(HttpCalloutMock.class, new GeocodingTestsMock());
		
		Account acct = new Account();
		acct.Name = 'Salesforce';
		acct.BillingStreet = 'The Landmark at One Market';
		acct.BillingCity = 'San Francisco';
		acct.BillingState = 'CA';
		acct.BillingPostalCode = '94105';
		acct.BillingCountry = 'United States';
		insert acct;
		
		Test.startTest();
		
		GeocodingUtils.LonLat coordinates = GeocodingUtils.geocodeAccount(acct);
		System.assertNotEquals(null, coordinates);
		System.assertNotEquals(null, coordinates.lat);
		System.assertNotEquals(null, coordinates.lon);

		Test.stopTest();
	}


	// Test the @future method
	static testMethod void testFutureMethod() {
		
		GeocodingUtils.useFutureMethod    = true;
		GeocodingUtils.useQueueableMethod = false;
		GeocodingUtils.useBatchableMethod = false;
	
		Test.setMock(HttpCalloutMock.class, new GeocodingTestsMock());
		
		Test.startTest();

		Account acct = new Account();
		acct.Name = 'Salesforce';
		acct.BillingStreet = 'The Landmark at One Market';
		acct.BillingCity = 'San Francisco';
		acct.BillingState = 'CA';
		acct.BillingPostalCode = '94105';
		acct.BillingCountry = 'United States';
		insert acct;

		// Wait for the future method to run
		Test.stopTest();
		
		acct = 
			[select Id, BillingLongitude, BillingLatitude
			 from   Account
			 where  Id = :acct.Id];

		System.assertNotEquals(null, acct.BillingLatitude);
		System.assertNotEquals(null, acct.BillingLongitude);

	}


	// Test the Queueable class
	static testMethod void testQueueableClass() {
		
		GeocodingUtils.useFutureMethod    = false;
		GeocodingUtils.useQueueableMethod = true;
		GeocodingUtils.useBatchableMethod = false;
	
		Test.setMock(HttpCalloutMock.class, new GeocodingTestsMock());
		
		Test.startTest();

		Account acct = new Account();
		acct.Name = 'Salesforce';
		acct.BillingStreet = 'The Landmark at One Market';
		acct.BillingCity = 'San Francisco';
		acct.BillingState = 'CA';
		acct.BillingPostalCode = '94105';
		acct.BillingCountry = 'United States';
		insert acct;

		acct = 
			[select Id, BillingLongitude, BillingLatitude
			 from   Account
			 where  Id = :acct.Id];

		System.assertEquals(null, acct.BillingLatitude);
		System.assertEquals(null, acct.BillingLongitude);

		// Let the Queueable class run
		Test.stopTest();
		
		acct = 
			[select Id, BillingLongitude, BillingLatitude
			 from   Account
			 where  Id = :acct.Id];

		System.assertNotEquals(null, acct.BillingLatitude);
		System.assertNotEquals(null, acct.BillingLongitude);

	}

	// Test the Batchable class
	static testMethod void testBatchableClass() {
		
		GeocodingUtils.useFutureMethod    = false;
		GeocodingUtils.useQueueableMethod = false;
		GeocodingUtils.useBatchableMethod = true;
	
		Test.setMock(HttpCalloutMock.class, new GeocodingTestsMock());
		
		Test.startTest();

		Account acct = new Account();
		acct.Name = 'Salesforce';
		acct.BillingStreet = 'The Landmark at One Market';
		acct.BillingCity = 'San Francisco';
		acct.BillingState = 'CA';
		acct.BillingPostalCode = '94105';
		acct.BillingCountry = 'United States';
		insert acct;

		acct = 
			[select Id, BillingLongitude, BillingLatitude
			 from   Account
			 where  Id = :acct.Id];

		System.assertEquals(null, acct.BillingLatitude);
		System.assertEquals(null, acct.BillingLongitude);

		GeocodingBatch cls = new GeocodingBatch();
		Database.executeBatch(cls);

		// Let one iteration of the Batchable class run
		Test.stopTest();
		
		acct = 
			[select Id, BillingLongitude, BillingLatitude
			 from   Account
			 where  Id = :acct.Id];

		System.assertNotEquals(null, acct.BillingLatitude);
		System.assertNotEquals(null, acct.BillingLongitude);

	}


	// Test the Schedulable class
	static testMethod void testSchedulableClass() {
		
		GeocodingUtils.useFutureMethod    = false;
		GeocodingUtils.useQueueableMethod = false;
		GeocodingUtils.useBatchableMethod = true;
	
		Test.setMock(HttpCalloutMock.class, new GeocodingTestsMock());
		
		Test.startTest();

		Account acct = new Account();
		acct.Name = 'Salesforce';
		acct.BillingStreet = 'The Landmark at One Market';
		acct.BillingCity = 'San Francisco';
		acct.BillingState = 'CA';
		acct.BillingPostalCode = '94105';
		acct.BillingCountry = 'United States';
		insert acct;

		acct = 
			[select Id, BillingLongitude, BillingLatitude
			 from   Account
			 where  Id = :acct.Id];

		System.assertEquals(null, acct.BillingLatitude);
		System.assertEquals(null, acct.BillingLongitude);

		GeocodingSchedulable cls = new GeocodingSchedulable();
		System.Schedule('Hourly',  '0 0 * * * ? *', cls);

		System.assertEquals(0, [select count() from AsyncApexJob where JobType = 'BatchApex']);

		// Let the Scheduled job launch the batch
		Test.stopTest();
		
		System.assertEquals(1, [select count() from AsyncApexJob where JobType = 'BatchApex']);
	}


	// Test the GeocodingContinuation controller class
	static testMethod void testContinuationClass() {
		
		Test.setMock(HttpCalloutMock.class, new GeocodingTestsMock());
		
		Test.startTest();

		GeocodingContinuation ctl = new GeocodingContinuation();
		ctl.acct.Name = 'Salesforce';
		ctl.acct.BillingStreet = 'The Landmark at One Market';
		ctl.acct.BillingCity = 'San Francisco';
		ctl.acct.BillingState = 'CA';
		ctl.acct.BillingPostalCode = '94105';
		ctl.acct.BillingCountry = 'United States';
		
		Test.stopTest();

		Continuation cont = (Continuation)ctl.geocodeAddress();

		// Pretend we got the callout results
		HttpResponse response = new HttpResponse();
		response.setBody(GeocodingTestsMock.mockedResults);

		// Tell the Continuation class that those are the results we got
		Test.setContinuationResponse(ctl.requestLabel, response);

		// Invoke callback method
		Object result = Test.invokeContinuationMethod(ctl, cont);

		// The callback method should return nothing
		System.assertEquals(null, result);
		
		// Make sure we got the response we were expecting
		System.assertEquals(GeocodingTestsMock.mockedResults, ctl.result);		
		System.assertNotEquals(null, ctl.jsonResult);
	}

}