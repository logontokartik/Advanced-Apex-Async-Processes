/*
** Class: GeocodingSchedulable
** Created: 3/23/2016 by OpFocus, Inc. (www.opfocus.com)
** Description: Contains a Schedulable class that launches a Batch Apex job.
** To run this hourly, use:
**
**     GeocodingSchedulable cls = new GeocodingSchedulable();
**     System.Schedule('Geocode Hourly',  '0 0 * * * ? *', cls);
**
*/
global class GeocodingSchedulable implements Schedulable {
	
	global void execute(SchedulableContext ctx) {
		
		// Determine how many records should be handed to each invocation of the 
		// Batch Apex execute method. 
		// Should be the smaller of the max allowed batch size and
		// the max allowed number of callouts per transaction.
		Integer maxBatchSize = 2000;
		Integer maxNumberOfCallouts = Limits.getLimitCallouts();
		Integer batchSize = Math.min(maxNumberOfCallouts, maxBatchSize);
		
		// Launch the batch job, setting the scope size to the value we just calculated.
		GeocodingBatch cls = new GeocodingBatch();
		Id jobId = Database.executeBatch(cls, batchSize);
	}
	
}