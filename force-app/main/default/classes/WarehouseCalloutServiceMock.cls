@isTest
global class WarehouseCalloutServiceMock {
  
  global class WarehouseCalloutSuccessMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatusCode(200);
      response.setBody('[{"_id":"55d66226726b611100aaf740","replacement":false,"quantity":5,"name":"Generator 0","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100000"}]');

      return response;
    } 
  }

  global class WarehouseCalloutFailureMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatusCode(400);
      response.setBody('{"type":"INACTIVE_USER","message":"User is inactive or not found."}],"errorType" : "AUTHENTICATION_FAILED"}');

      return response;
    } 
  }

  global class WarehouseCalloutBulkMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatusCode(200);

      Integer i = 0;
      String responseBody = '[';
      while (i<300) {
        responseBody += '{"_id":"55d66226726b611100aaf74'+i+'","replacement":false,"quantity":5,"name":"Generator '+i+'","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"10000'+i+'"},';
        i++;
      }

      responseBody = responseBody.removeEnd(',');
      responseBody += ']';

      response.setBody(responseBody);

      return response;
    } 
  }

  global class WarehouseCalloutDmlErrorMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatusCode(200);
      response.setBody('[{"_id":"55d66226726b611100aaf74","replacement":false,"quantity":5,"maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100000"}]');

      return response;
    } 
  }
}