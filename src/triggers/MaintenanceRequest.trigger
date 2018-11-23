trigger MaintenanceRequest on Case (before update, after update) {
    if(Trigger.isUpdate){
	    if(Trigger.isAfter){
	    	MaintenanceRequestHelper.updateWorkOrders(Trigger.newMap, Trigger.oldMap);
	    }
	}
}