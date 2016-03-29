/*
** Class: GeocodingContinuation
** Created: 3/23/2016 by OpFocus, Inc. (www.opfocus.com)
** Description: Controller for the GeocodingContinuation VF page
*/
public with sharing class GeocodingContinuation {

	public Account acct {get; set;}         // Contains address fields that we'll show on the VF page
	public String requestLabel {get; set;}	// Result of launching the Continuation class; useful in getting the result
	public String result {get; set;}        // Result of the Continuation class's run
	public String jsonResult {get; set;}    // JSON representation of the geocoding callout request
	
	public GeocodingContinuation() {
		acct = new Account();
	}
	
	// Called by a button on the GeocodingContinuation page
	public Object geocodeAddress() {

		GeocodingUtils.useFutureMethod    = false;
		GeocodingUtils.useQueueableMethod = false;
		GeocodingUtils.useBatchableMethod = false;

		// Construct a URL-encoded string containing the address
		String[] lstAddressParts = new String[]{};
		if (acct.BillingStreet != null)     lstAddressParts.add(acct.BillingStreet);
		if (acct.BillingCity != null)       lstAddressParts.add(acct.BillingCity);
		if (acct.BillingState != null)      lstAddressParts.add(acct.BillingState);
		if (acct.BillingPostalCode != null) lstAddressParts.add(acct.BillingPostalCode);
		if (acct.BillingCountry != null)    lstAddressParts.add(acct.BillingCountry);
		
		String address = String.join(lstAddressParts, ',');
		String addressEncoded = EncodingUtil.urlEncode(address, 'UTF-8');
		
		// Create a Continuation with a timeout
		Continuation con = new Continuation(40);
		
		// Tell it what method to call when the HTTP Request returns
		con.continuationMethod='processResponse';
		
		// Create the callout request
		// (Ideally, we'd have a Google API Key to prevent issues with the number of calls from the same Salesforce IP address.)
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + addressEncoded);
		
		// Add the callout request to Continuation object. This causes the request to be made.
		this.requestLabel = con.addHttpRequest(request);
		
		return con;
	}


	// Callback method for the Continuation request
	public Object processResponse() {
		// Get the result of the Continuation request we just mae
		HttpResponse response = Continuation.getResponse(this.requestLabel);
		
		// Get the callout request's results
		result = response.getBody();
		jsonResult = JSON.serializePretty(result.replaceAll('\\n', '<br/>'));
		return null;
	}

}