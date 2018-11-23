public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future (callout=true)
    public static void runWarehouseEquipmentSync() {
      try{
        
        HttpResponse response = makeHttpGETCallout(WAREHOUSE_URL);
        
        if (response.getStatusCode() == 200) {
          System.debug('Deserialised Response: '+response.getBody());
          List<Object> deserialisedResponseBody = (List<Object>) JSON.deserializeUntyped(response.getBody());
          System.debug('Deserialised Response: '+deserialisedResponseBody);
          storeResultsInEquipment(deserialisedResponseBody);
        } else {
          System.debug('Warehouse Sync Error: '+response.getStatusCode());
        }
      }
      catch (Exception e) {
        System.debug('Errors: '+e.getMessage());
        System.debug('Errors: '+e.getLineNumber());
        System.debug('Errors: '+e.getCause());
      }   
    }

    public static HttpResponse makeHttpGETCallout(String httpUrl) {
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      request.setEndpoint(httpUrl);
      request.setMethod('GET');
      HttpResponse response =  http.send(request);
      System.debug('Response: '+response);
      return response;
    }

/* Based on response format check instanceOf
    public static Map<String, Object> deserialiseJSON(String responseBody) {
      Object deserialisedBody = JSON.deserializeUntyped(responseBody);
      System.debug('ResponseBody: '+deserialisedBody);
      Map<String, Object> deserialisedBodyMap = new Map<String, Object>();

      if (deserialisedBody instanceOf Map<String, Object>) {
        deserialisedBodyMap = (Map<String, Object>) deserialisedBody;
      } else {
        List<Object> deserialisedList = (List<Object>) deserialisedBody;
        for (Object deserialisedContent : deserialisedList) {
          Map<String, Object> deserialisedContentMap = (Map<String, Object>)deserialisedContent;
          deserialisedBodyMap.putAll(deserialisedContentMap);
        }
      }

      return deserialisedBodyMap;
    }*/

    public static void storeResultsInEquipment(List<Object> results) {
      List<Product2> warehouseProducts = new List<Product2>();

      for (Object aResult: results) {
        Map<String, Object> aResultMap = (Map<String, Object>) aResult;

        Product2 warehouseProduct = new Product2();
        warehouseProduct.Name = String.valueOf(aResultMap.get('name'));
        warehouseProduct.Replacement_Part__c = true;
        warehouseProduct.Current_Inventory__c = Integer.valueOf(aResultMap.get('quantity'));
        warehouseProduct.Maintenance_Cycle__c = Integer.valueOf(aResultMap.get('maintenanceperiod'));
        warehouseProduct.Lifespan_Months__c = Integer.valueOf(aResultMap.get('lifespan'));
        warehouseProduct.Cost__c = Integer.valueOf(aResultMap.get('cost'));
        warehouseProduct.Warehouse_SKU__c = String.valueOf(aResultMap.get('sku'));

        warehouseProducts.add(warehouseProduct);
      }
      System.debug('Product: '+warehouseProducts); 

      if (!warehouseProducts.isEmpty()) {
        Schema.SObjectField externalIdField = Product2.Fields.Warehouse_SKU__c;
      
        Database.UpsertResult[] upsertResults = Database.upsert(warehouseProducts, externalIdField, false);
        System.debug('Upsert Results: ' +upsertResults);
        String errorMessages;
        for (Database.UpsertResult anUpsertResult : upsertResults) {
          if (!anUpsertResult.isSuccess()) {
            for (Database.Error upsertError : anUpsertResult.getErrors()) {
              System.debug('Upsert error: '+upsertError.getMessage());
              errorMessages += upsertError.getMessage() +'\n';
            }
          }
        }

        if (String.isNotBlank(errorMessages)) {
          throw new CustomException(errorMessages);
        }
      }  
    }
}