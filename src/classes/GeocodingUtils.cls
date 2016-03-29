/*
** Class: GeocodingUtils
** Created: 3/23/2016 by OpFocus, Inc. (www.opfocus.com)
** Description: Utility methods for geocoding an Account
*/
public class GeocodingUtils {

	// For demo purposes, these variables allow you to enable just one of the
	// async Apex techniques in the Account trigger
	public static Boolean useFutureMethod    = true;
	public static Boolean useQueueableMethod = false;
	public static Boolean useBatchableMethod = false;


	// Given 2 Accounts, returns true if the Billing Addresses are different
	public static Boolean addressChanged(Account acctNew, Account acctOld) {
		String addrNew = acctNew.BillingStreet + acctNew.BillingCity + acctNew.BillingState + acctNew.BillingPostalCode + acctNew.BillingCountry;
		String addrOld = acctOld.BillingStreet + acctOld.BillingCity + acctOld.BillingState + acctOld.BillingPostalCode + acctOld.BillingCountry;
		return (addrNew != addrOld);
	}
	
	// Contains geocoding coordinates
	public class LonLat {
		public Double lon;
		public Double lat;
	}


	// Basic helper method to return the lon/lat data for a given Account.
	// Given an Account, return a LonLat object with its coordinates.
	// Assumes we have a Remote Site Setting for https://maps.googleapis.com
	public static LonLat geocodeAccount(Account acct) {
		
		if (acct.BillingCity == null || acct.BillingState == null) {
			return null;
		}
		
		// Construct a URL-encoded string containing the address
		String[] lstAddressParts = new String[]{};
		if (acct.BillingStreet != null)     lstAddressParts.add(acct.BillingStreet);
		if (acct.BillingCity != null)       lstAddressParts.add(acct.BillingCity);
		if (acct.BillingState != null)      lstAddressParts.add(acct.BillingState);
		if (acct.BillingPostalCode != null) lstAddressParts.add(acct.BillingPostalCode);
		if (acct.BillingCountry != null)    lstAddressParts.add(acct.BillingCountry);
		
		String address = String.join(lstAddressParts, ',');
		String addressEncoded = EncodingUtil.urlEncode(address, 'UTF-8');
		
		// Call out to the Geocoding API
		// (Ideally, we'd have a Google API Key to prevent issues with the number of calls from the same Salesforce IP address.)
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + addressEncoded);
		request.setMethod('GET');
		request.setTimeout(10000);
		
		HttpResponse response = http.send(request);
		
		// Process the response
		LonLat coordinates;
        
        // If there's an error parsing the results, ignore it and move on
        try {
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')) {
                    parser.nextValue();
            
                    // Get the lat
                    parser.nextValue();
                    String lat = parser.getText();
            
                    // Get the lon
                    parser.nextValue();
                    String lon = parser.getText();
            
                    coordinates = new LonLat();
                    coordinates.lat = Double.valueOf(lat);
                    coordinates.lon = Double.valueOf(lon);
                    break;
                }
            }
        }
        catch (Exception ex) {
            // Nothing to do
        }
    
		// Return the lon/lat object
		return coordinates;
	}
}