/*
** Class: GeocodingQueueable
** Created: 3/23/2016 by OpFocus, Inc. (www.opfocus.com)
** Description: Contains a Queueable Apex class to geocode all Accounts in lstAccounts
*/
public class GeocodingQueueable implements Queueable, Database.AllowsCallouts {

	public Account[] lstAccounts = new Account[]{};
	
	public void execute(QueueableContext ctx) {
		// Process as many Accounts as we can. We're limited by the number of callouts we can make
		// per transaction (Limits.getLimitCallouts())
		Account[] lstProcessed = new Account[]{};
		Integer numProcessed;
		for (numProcessed=0; numProcessed < Limits.getLimitCallouts() && numProcessed<lstAccounts.size(); numProcessed++) {
			// Geocode this Account
            Account acctGeo = lstAccounts[numProcessed];
			GeocodingUtils.LonLat coordinates = GeocodingUtils.geocodeAccount(acctGeo);
			if (coordinates != null) {
				acctGeo.BillingLongitude = coordinates.lon;
				acctGeo.BillingLatitude  = coordinates.lat;
				lstProcessed.add(acctGeo);
			}
		}
		
        // Save the Accounts we just geocoded
		// (Ideally, we'd do better error handling here.)
		update lstProcessed;
		
		// Remove the ones we just processed from the list.
		for (Integer i=0; i<numProcessed; i++) {
			lstAccounts.remove(0);
		}
		
		// If there are any remaining Accounts, chain a new Async job to process them.
		// NOTE: As of Spring 16, a chained Queueable job cannot do a callout, so the next
		// run of this execute() method will fail!
		if (!lstAccounts.isEmpty()) {
			Id jobID = System.enqueueJob(this);
		}
	}
}