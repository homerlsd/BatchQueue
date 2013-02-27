trigger StackJobTrigger on StackJob__c (before insert) {
	
	if (Trigger.isBefore && Trigger.isInsert) {
		//JobManager.startJobs();
	}
	
	
}