/*
** Class: GeocodingTestsMock
** Created: 3/23/2016 by OpFocus, Inc. (www.opfocus.com)
** Description: Mock class for geocoding unit tests
*/
global class GeocodingTestsMock implements HttpCalloutMock {
	
	public static String mockedResults = ' { "results" : [ { "address_components" : [ { "long_name" : "94105", "short_name" : "94105", "types" : [ "postal_code" ] }, { "long_name" : "San Francisco", "short_name" : "SF", "types" : [ "locality", "political" ] }, { "long_name" : "San Francisco County", "short_name" : "San Francisco County", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "California", "short_name" : "CA", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] } ], "formatted_address" : "San Francisco, CA 94105, USA", "geometry" : { "bounds" : { "northeast" : { "lat" : 37.80018200000001, "lng" : -122.381681 }, "southwest" : { "lat" : 37.7824491, "lng" : -122.4035291 } }, "location" : { "lat" : 37.7890183, "lng" : -122.3915063 }, "location_type" : "APPROXIMATE", "viewport" : { "northeast" : { "lat" : 37.80018200000001, "lng" : -122.381681 }, "southwest" : { "lat" : 37.7824491, "lng" : -122.4035291 } } }, "partial_match" : true, "place_id" : "ChIJDXK6UmKAhYARfzuOY6DDgeM", "types" : [ "postal_code" ] } ], "status" : "OK" }';

	global HTTPResponse respond(HTTPRequest request) {
		System.assertEquals('GET', request.getMethod());
		
		System.assert(request.getEndpoint().containsIgnoreCase('https://maps.googleapis.com'), 'Endpoint: ' + request.getEndpoint());
		
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setBody(mockedResults);
		response.setStatusCode(200);
		return response;
	}
}