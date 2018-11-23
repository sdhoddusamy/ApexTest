public class MaintenanceRequestHelper {
    
    public static void updateWorkOrders() {

    }
    
    public static void updateWorkOrders(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        Map<Id, Case> casesThatRequireFollowUpCases = new Map<Id, Case>();
        List<Case> newFollowUpCases = new List<Case>();

        for(Case aCase: newCaseMap.values()){
        	if((aCase.Type == 'Repair' || aCase.Type == 'Routine Maintenance') && aCase.Status == 'Closed' && aCase.Status != oldCaseMap.get(aCase.Id).Status){
        		casesThatRequireFollowUpCases.put(aCase.Id, aCase);
        	}
        }

        Map<Id, Date> dueDateForCases = calculateDueDateForCases(casesThatRequireFollowUpCases.keySet());
        for(Case aCase: casesThatRequireFollowUpCases.values()){
        	newFollowUpCases.add(new Case(
        										Subject = 'Routine Maintenance',
        										Type='Routine Maintenance',
        										Vehicle__c = aCase.Vehicle__c,
        										Equipment__c = aCase.Equipment__c,
        										Date_Reported__c = System.today(),
        										Date_Due__c = (dueDateForCases.containsKey(aCase.Id)? dueDateForCases.get(aCase.Id): null)
        									));
        }

        insert newFollowUpCases;

    }

    private static Map<Id, Date> calculateDueDateForCases(Set<Id> caseIds){
    	Map<Id, Date> dueDateByCaseId = new Map<Id, Date>();
    	AggregateResult[] workPartsGroupedByCase = [Select MIN(Equipment__r.Lifespan_Months__c), Maintenance_Request__c FROM Work_Part__c WHERE Maintenance_Request__c IN: caseIds GROUP BY Maintenance_Request__c];
    	if(!workPartsGroupedByCase.isEmpty()){
    		for(AggregateResult ar: workPartsGroupedByCase){
    			dueDateByCaseId.put((Id)ar.get('Maintenance_Request__c'), System.today().addMonths(Integer.valueOf((Decimal)ar.get('expr0'))));
    		}
    	}
    	return dueDateByCaseId;
    }       
    
}