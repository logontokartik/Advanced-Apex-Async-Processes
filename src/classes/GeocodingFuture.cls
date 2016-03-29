/*
** Class: GeocodingFuture
** Created: 3/23/2016 by OpFocus, Inc. (www.opfocus.com)
** Description: Contains a Future method to geocode an Account
*/
public class GeocodingFuture {
	
	// Future method called by the Account trigger. Given an Account Id, calls out to the geocoding
	// service and updates the Account with lon/lat results.
	@future (callout=true)
	public static void geocodeAccountFuture(Id accountId) {
		// Get the Account
		Account acct = 
			[select Id, BillingStreet, BillingCity, 
			        BillingState, BillingPostalCode, BillingCountry
			 from   Account
			 where  Id = :accountId];
		
		// Geocode the Account and save the results.
		// (Ideally, we'd do better error handling here.)
		GeocodingUtils.LonLat coordinates = GeocodingUtils.geocodeAccount(acct);
		if (coordinates != null) {
			acct.BillingLongitude = coordinates.lon;
			acct.BillingLatitude  = coordinates.lat;
			update acct;
		}
	}
}