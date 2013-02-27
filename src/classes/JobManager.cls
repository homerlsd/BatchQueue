/**
 * JobManager class
 * 
 * JobBuilder.Job job = JobManager.createJob();
 * job.setJobPriority('normal'); // 'low' by default
 * job.getJobBatchState().setBatchClassName('someBatchClassName');
 * job.getJobBatchState().setBatchScope('10'); // '1' by default
 * job.getJobBatchState().addBatchParam('param1', new List<String>{'someString1','someString2'});
 * job.getJobBatchState().addBatchParam('param2', [Select Id, name from User LIMIT 10]);
 * JobManager.insertJob(job);
 * 
 */
public without sharing class JobManager {
	
	private static List<StackJob__c> stackJobs;
	private static Map<Id, JobBuilder.Job> mapJobs;
	private static final Integer MAX_USED_BATCH = 1;
	
	//-------------------------------------------------------------------------
	/*
	* default constructor of JobManager class
	*/
	public JobManager() {
		
		stackJobs = new List<StackJob__c>();
		mapJobs = new Map<Id, JobBuilder.Job>();
		
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* 
	* @return List<StackJob__c> allStackJobs
	*/
	private static List<StackJob__c> getStackJobs() {
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
			WHERE
				Lock__c = false
			AND
				Status__c = 'Queued'
			AND
				Status__c != 'Completed'
			ORDER BY
				CreatedDate ASC
			LIMIT
				1000
		];
		
		return allStackJobs;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* @param Id finishedJobId
	* @return StackJob__c finishedJob
	*/
	private static StackJob__c getFinishedJob(Id finishedJobId) {
		StackJob__c finishedJob = [
			SELECT
				Id,
				JobState__c,
				AsyncApexJob_Id__c,
				CreatedDate,
				Lock__c
			FROM
				StackJob__c
			WHERE
				(Lock__c = true AND AsyncApexJob_Id__c = :finishedJobId)
			LIMIT
				1
		];
		
		return finishedJob;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* 
	* @param List<StackJob__c> inStackJobs
	* @return Map<Id, JobBuilder.Job> allMapJobs
	*/
	public static Map<Id, JobBuilder.Job> getMapJobs(List<StackJob__c> inStackJobs) {
		Map<Id, JobBuilder.Job> allMapJobs = new Map<Id, JobBuilder.Job>();
		
		for (StackJob__c job : inStackJobs) {
			allMapJobs.put(job.Id, getJobFromState(job.JobState__c));
		}
		
		return allMapJobs;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* Insert filled records of a object of the StackJob__c to database.
	* @param JobBuilder.Job job
	*/
	public static void insertJob(JobBuilder.Job job) {
		insert new StackJob__c(JobState__c = JSON.serialize(job), Status__c = 'Queued');
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* custom deserializer to JobBuilder.Job type
	* @param String jsonString
	* @return JobBuilder.Job job
	*/
	public static JobBuilder.Job desirializeState(String jsonString) {
		
		Map<String, Object> untypedMapObjects = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
		String jobStatus = (String)untypedMapObjects.get('jobStatus');
		String jobPriority = (String)untypedMapObjects.get('jobPriority');
		
		Map<String, Object> jobBatchState = (Map<String, Object>)untypedMapObjects.get('jobBatchState');
		
		String batchScope = (String)jobBatchState.get('batchScope');
		String batchClassName = (String)jobBatchState.get('batchClassName');
		Map<String, Object> batchParams = (Map<String, Object>)jobBatchState.get('batchParams');
		
		JobBuilder jobBuilder = new JobBuilder();
		JobBuilder.Job job = jobBuilder.createJob(jobStatus, batchClassName, batchParams, batchScope, jobPriority);
		
		return job;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* Return deserialized instance of JobBuilder.Job type
	* from jobState in records StackJob__c.JobState__c
	* @param String jobState
	* @return JobBuilder.Job job
	*/
	private static JobBuilder.Job getJobFromState(String jobState) {
		JobBuilder.Job job = desirializeState(jobState);
		
		return job;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* Create instance of JobBuilder.Job and return this instance.
	* for filling below.
	* @param none
	* @return JobBuilder.Job job
	*/
	public static JobBuilder.Job createJob() {
		JobBuilder jobBuilder = new JobBuilder();
		JobBuilder.Job job = jobBuilder.createJob();
		
		return job;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* Create instance of JobBuilder.Job and filling all fields and return this.
	* @param String jobStatus
	* @param String batchClassName
	* @param Map<String, Object> batchParams
	* @param String batchScope
	* @param String jobPriority
	* @return JobBuilder.Job job
	*/
	public static JobBuilder.Job createJob(String jobStatus, String batchClassName, Map<String, Object> batchParams, String batchScope, String jobPriority) {
		JobBuilder jobBuilder = new JobBuilder();
		JobBuilder.Job job = jobBuilder.createJob(jobStatus, batchClassName, batchParams, batchScope, jobPriority);
		
		return job;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* @param DateTime inDateTime
	* @return Integer outDateTimeAsInteger
	*/
	private static Integer getDateTimeAsInteger(DateTime inDateTime) {
		Integer outDateTimeAsInteger;
		outDateTimeAsInteger = inDateTime.year() + inDateTime.dayOfYear() + inDateTime.hour() + inDateTime.minute() + inDateTime.millisecond();
		
		return outDateTimeAsInteger;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* @param String jobPriorityAsString
	* @return Integer jobPriorityAsInteger
	*/
	private static Integer getJobPriorityAsInteger(String jobPriorityAsString) {
		Integer jobPriorityAsInteger; 
		
		if (jobPriorityAsString.toLowerCase() == 'high') {
			jobPriorityAsInteger = 2;
		}
		else if (jobPriorityAsString.toLowerCase() == 'normal') {
			jobPriorityAsInteger = 1;
		}
		else {
			// 0 = low by default
			jobPriorityAsInteger = 0;
		}
		
		return jobPriorityAsInteger;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* 
	* @param Map<Id, JobBuilder.Job> inMapJobs
	* @param List<StackJob__c> inStackJobs
	* @return StackJob__c recordHighestPriority
	*/
	public static StackJob__c getHighestJob(List<StackJob__c> inStackJobs, Map<Id, JobBuilder.Job> inMapJobs) {
		
		StackJob__c recordHighestPriority = inStackJobs[0];
		JobBuilder.Job jobHighestPriority = inMapJobs.get(recordHighestPriority.Id);
		Integer maxPriority = getJobPriorityAsInteger(jobHighestPriority.getJobPriority());
		
		for (StackJob__c record : inStackJobs) {
			Integer curPriority = getJobPriorityAsInteger(inMapJobs.get(record.Id).getJobPriority());
			if (curPriority > maxPriority) {
				recordHighestPriority = record;
				maxPriority = getJobPriorityAsInteger(inMapJobs.get(record.Id).getJobPriority());
			}
			if (curPriority == 2) {
				break;
			}
		}
		
		return recordHighestPriority;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* 
	* @param List<StackJob__c> inStackJobs
	* @param StackJob__c reducedJob
	* @return List<StackJob__c> outReducedStackJobs
	*/
	private static List<StackJob__c> reduceStackJobs(List<StackJob__c> inStackJobs, StackJob__c reducedJob) {
		List<StackJob__c> outReducedStackJobs = inStackJobs;
		Integer i = 0;
		
		for (StackJob__c job : outReducedStackJobs) {
			if (reducedJob.Id == job.Id) {
				outReducedStackJobs.remove(i);
				break;
			}
			i++;
		}
		
		return outReducedStackJobs;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* 
	* @param List<StackJob__c> inStackJobs
	* @param JobBuilder.Job> inMapJobs
	* @param Integer sizeList
	* @return List<StackJob__c> outHigestListJobs
	*/
	public static List<StackJob__c> getHigestListJobs(List<StackJob__c> inStackJobs, Map<Id, JobBuilder.Job> inMapJobs, Integer sizeList) {
		
		List<StackJob__c> outHigestListJobs = new List<StackJob__c>();
		StackJob__c tmpHigestJob;
		
		for (Integer i = 1; (i <= sizeList) && (inStackJobs.size() >= 1); i++) {
			tmpHigestJob = getHighestJob(inStackJobs, inMapJobs);
			inStackJobs = reduceStackJobs(inStackJobs, tmpHigestJob);
			inMapJobs = getMapJobs(inStackJobs);
			outHigestListJobs.add(tmpHigestJob);
		}
		
		return outHigestListJobs;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* 
	* @return Integer freeBatchCount
	*/
	private static Integer getFreeBatchCount() {
		
		Integer busyBatchCount = [
			SELECT
				COUNT()
			FROM
				AsyncApexJob
			WHERE
				Jobtype = 'BatchApex'
				AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')
			LIMIT
				:MAX_USED_BATCH
		];
		
		Integer freeBatchCount = MAX_USED_BATCH - busyBatchCount;
		
		return freeBatchCount;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* 
	* @return Boolean limitExceeded
	*/
	private static Boolean checkLimits() {
		final Integer limQueries = 95;
		Boolean limitExceeded = (Limits.getQueries() >= limQueries) ? true : false;
		
		return limitExceeded;
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* 
	* @return Integer freeBatchCount
	*/
	private static void executeBatch(List<StackJob__c> jobsToExecute) {
		
		Map<Id, JobBuilder.Job> jobsMap = getMapJobs(jobsToExecute);
		
		for (StackJob__c currentJob : jobsToExecute) {
			
			
			
			JobBuilder.Job job = jobsMap.get(currentJob.Id);
			String batchClassName = job.getJobBatchState().getBatchClassName();
			String batchState = job.getJobBatchState().getBatchParamsAsJSON();
			Integer batchScope = Integer.valueOf(job.getJobBatchState().getBatchScope());
			
			system.debug('//--run-Batch---' + '--Priority= ' + job.getJobPriority() + ' --CreatedDate= ' + currentJob.CreatedDate + ' ---////');
			
			Type typeBatch =  Type.forName(batchClassName);
			Database.Batchable<sObject> batchInstance = (Database.Batchable<sObject>) JSON.deserialize(batchState, typeBatch);
			Id batchId = Database.executeBatch(batchInstance, batchScope);
			currentJob.Status__c = 'Processing';
			job.setJobStatus('Processing');
			currentJob.AsyncApexJob_Id__c = batchId;
			job.setJobStatus('Processing');
			currentJob.Lock__c = true;
			currentJob.JobState__c = JSON.serialize(job);
			update currentJob;
		}
		
		
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	/*
	* 
	* @param String jsonString
	* @return JobBuilder.Job job
	*/
	public static void startJobs() {
		
		Integer freeBatchCount = getFreeBatchCount();
		
		if (checkLimits() || (freeBatchCount == 0)) { //cheduled job
			
			
		}
		else { //run job
			//initialization of all jobs and records
			stackJobs = getStackJobs();
			mapJobs = getMapJobs(stackJobs);
			
			//get jobs list by highest priotity by freeBatchCount
			List<StackJob__c> jobsWithHighestPriority = getHigestListJobs(stackJobs, mapJobs, freeBatchCount);
			
			//run this jobs
			executeBatch(jobsWithHighestPriority);
		}
	}
	//-------------------------------------------------------------------------
	
	
	//-------------------------------------------------------------------------
	public static void finishJob(Id finishedJobId) {
		StackJob__c finishedJob = getFinishedJob(finishedJobId);
		finishedJob.Lock__c = false;
		finishedJob.Status__c = 'Completed';
		JobBuilder.Job job = getJobFromState(finishedJob.JobState__c);
		job.setJobStatus('Completed');
		finishedJob.JobState__c = JSON.serialize(job);
		update finishedJob;
		
		startJobs();
	}
	//-------------------------------------------------------------------------
	
	//-------------------------------------------------------------------------
	
	//-------------------------------------------------------------------------
}