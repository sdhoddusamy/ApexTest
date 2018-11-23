@isTest
private class MaintenanceRequestHelperTest {
	static Vehicle__c testVehicle;
	static Product2 testEquipment;
	static List<Case> casesToCreate;
	
	static{
		testVehicle = new Vehicle__c(Name = 'Test Vehicle');
		testEquipment = new Product2(Name = 'Test Equipment', Lifespan_Months__c = 1, Replacement_Part__c = true);
		insert testVehicle;
		insert testEquipment;
		casesToCreate  = new List<Case>();
	}
	
	static void createCases(Integer numOfCases){
		
		for(Integer i=0; i< numOfCases; i++){
		casesToCreate.add(new Case(
									Subject = 'Test Maintenance Request '+i,
									Type='Routine Maintenance',
									Vehicle__c = testVehicle.Id,
									Equipment__c = testEquipment.Id,
									Date_Reported__c = System.today()
								));
		}
		insert casesToCreate;
	}

	static void attachWorkParts(Integer numOfWorkParts){
		List<Work_Part__c> workPartsToAttach  = new List<Work_Part__c>();
		List<Product2> equipmentsToCreate  = new List<Product2>();

		for(Integer i=0; i< numOfWorkParts; i++){
			equipmentsToCreate.add(new Product2(
										Name = 'Test Equipment '+i,
										Lifespan_Months__c = i+1, 
										Replacement_Part__c = true
									));
		}
		insert equipmentsToCreate;

		for(Case aCase: casesToCreate){
			for(Integer i=0; i< numOfWorkParts; i++){
			workPartsToAttach.add(new Work_Part__c(
										Maintenance_Request__c = aCase.Id,
										Equipment__c = equipmentsToCreate[i].Id
									));
			}
		}
		insert workPartsToAttach;
	}

	@isTest static void test_single_MaintenanceRequest_without_WorkParts() {
		createCases(1);

		System.assertEquals(1, [Select count() FROM Case]);
		casesToCreate[0].status = 'Closed';

		Test.startTest();
		update casesToCreate[0];
		Test.stopTest();
		System.assertEquals(2, [Select count() FROM Case]);
		System.assertEquals(null,[Select Id, Date_Due__c  FROM Case WHERE Status <> 'Closed' LIMIT 1].Date_Due__c);
	}

	@isTest static void test_single_MaintenanceRequest_with_WorkParts() {
		createCases(1);
		attachWorkParts(3);


		System.assertEquals(1, [Select count() FROM Case]);
		casesToCreate[0].status = 'Closed';

		Test.startTest();
		update casesToCreate[0];
		Test.stopTest();
		System.assertEquals(2, [Select count() FROM Case]);
		System.assertEquals(System.today().addMonths(1),[Select Id, Date_Due__c  FROM Case WHERE Status <> 'Closed' LIMIT 1].Date_Due__c);
	}
	@isTest static void test_BulkTest() {
		createCases(300);
		attachWorkParts(2);


		System.assertEquals(300, [Select count() FROM Case]);
		for(Case aCase: casesToCreate){
			aCase.status = 'Closed';
		}

		Test.startTest();
		update casesToCreate;
		Test.stopTest();
		System.assertEquals(600, [Select count() FROM Case]);
		System.assertEquals(300,[Select count() FROM Case WHERE Status <> 'Closed']);
	}

	
	
}