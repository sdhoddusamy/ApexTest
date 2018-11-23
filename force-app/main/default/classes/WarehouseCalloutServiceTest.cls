@isTest
private class WarehouseCalloutServiceTest {
  public static String CRON_EXP = '0 15 10 ? * *'; 

  @isTest
  static void test_WarehouseCalloutSuccess() {
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock.WarehouseCalloutSuccessMock());

    Test.startTest();
    WarehouseCalloutService.runWarehouseEquipmentSync();
    Test.stopTest();

    List<Product2> updatedProducts = [Select Name, Replacement_Part__c, Current_Inventory__c, Maintenance_Cycle__c, 
                                      Lifespan_Months__c, Cost__c, Warehouse_SKU__c 
                                      FROM Product2
                                      ];
    System.assertEquals(1, updatedProducts.size());
    System.assertEquals(true, updatedProducts[0].Replacement_Part__c);
    System.assertEquals(5, updatedProducts[0].Current_Inventory__c);
    System.assertEquals(365, updatedProducts[0].Maintenance_Cycle__c);
    System.assertEquals(120, updatedProducts[0].Lifespan_Months__c);
    System.assertEquals(5000, updatedProducts[0].Cost__c);
    System.assertEquals('100000', updatedProducts[0].Warehouse_SKU__c);
  }

  @isTest
  static void test_WarehouseCalloutFailure() {
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock.WarehouseCalloutFailureMock());

    Test.startTest();
    String jobId = System.schedule('TestScheduleWareHouseSync',CRON_EXP, new WarehouseSyncSchedule());
    Test.stopTest();

    List<Product2> createdProducts = [Select Id FROM Product2];
    System.assertEquals(0, createdProducts.size());
  }

  @isTest
  static void test_WarehouseCalloutBulk() {
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock.WarehouseCalloutBulkMock());

    Test.startTest();
    WarehouseCalloutService.runWarehouseEquipmentSync();
    Test.stopTest();

    List<Product2> createdProducts = [Select Name, Replacement_Part__c, Current_Inventory__c, Maintenance_Cycle__c, 
                                      Lifespan_Months__c, Cost__c, Warehouse_SKU__c 
                                      FROM Product2
                                      ];
    System.assertEquals(300, createdProducts.size());
  }

  @isTest
  static void test_WarehouseCalloutUpsertError() {
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock.WarehouseCalloutDmlErrorMock());

    Test.startTest();
    WarehouseCalloutService.runWarehouseEquipmentSync();
    Test.stopTest();

    List<Product2> updatedProducts = [Select Name, Replacement_Part__c, Current_Inventory__c, Maintenance_Cycle__c, 
                                      Lifespan_Months__c, Cost__c, Warehouse_SKU__c 
                                      FROM Product2
                                      ];
    System.assertEquals(0, updatedProducts.size());
  }
}