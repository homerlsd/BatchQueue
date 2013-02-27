public with sharing class MonitorBatchQueueController {
	
	public List<JobBuilder.Job> jobs {get; set;}
	public Boolean isEmpty {get; set;}
	
	public List<JobBuilder.Job> getAllJobs() {
		
		List<StackJob__c> allStackJobs = [
				SELECT
					Id,
					JobState__c,
					AsyncApexJob_Id__c,
					CreatedDate,
					Lock__c,
					Status__c,
					Name
				FROM
					StackJob__c
				ORDER BY
					CreatedDate ASC
				LIMIT
					1000
			];
			
			Map<Id, JobBuilder.Job> inMapJobs = JobManager.getMapJobs(allStackJobs);
			List<StackJob__c> outStackJobs = JobManager.getHigestListJobs(allStackJobs, inMapJobs, allStackJobs.size());
			List<JobBuilder.Job> outMapJobs = JobManager.getMapJobs(outStackJobs).values();
			
			for (Integer i = 0; i < outStackJobs.size(); i++) {
				JobBuilder.Job job = JobManager.desirializeState(outStackJobs.get(i).JobState__c);
				outMapJobs.set(i, job);
			}
			
			return outMapJobs;
	}
	
	public PageReference getRecords() {
		jobs = getAllJobs();
		isEmpty = (jobs == NULL) ? false : true;
		return NULL;
	}
}