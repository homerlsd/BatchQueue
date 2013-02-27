public class JobBuilder {
	
	private Job job;
	
	public JobBuilder() {
		this.job = new Job();
	}
	
	public Job createJob() {
		this.job = new Job();
		return this.job;
	}
	
	public Job createJob(String jobStatus, String batchClassName, Map<String, Object> batchParams, String batchScope, String jobPriority) {
		this.job = new Job(jobStatus, batchClassName, batchParams, batchScope, jobPriority);
		return this.job;
	}
	
	public class Job {
		
		private String jobStatus;
		private String jobPriority;
		private JobBatchState jobBatchState;
		
		public Job() {
			this.jobStatus = 'Queued';
			this.jobPriority = 'low';
			this.JobBatchState = new JobBatchState();
		}
		
		public Job(String jobStatus, String batchClassName, Map<String, Object> batchParams, String batchScope, String jobPriority) {
			this.jobStatus = jobStatus;
			this.jobPriority = jobPriority;
			this.jobBatchState = new JobBatchState(batchClassName, batchParams, batchScope);
		}
		
		public String getJobPriority() {
			return this.jobPriority;
		}
		
		public void setJobPriority(String jobPriority) {
			this.jobPriority = (jobPriority.toLowerCase() == 'normal' || jobPriority.toLowerCase() == 'high') ? jobPriority : this.jobPriority;
		}
		
		public String getJobStatus() {
			return this.jobStatus;
		}
		
		public JobBatchState getJobBatchState() {
			return this.jobBatchState;
		}
		
		public void setJobStatus(String jobStatus) {
			this.jobStatus = jobStatus;
		}
		
		public void setJobBatchState(String batchClassName, Map<String, Object> batchParams, String batchScope) {
			JobBatchState jobBatchState = new JobBatchState();
			jobBatchState.setBatchClassName(batchClassName);
			jobBatchState.setBatchParams(batchParams);
			jobBatchState.setBatchScope(batchScope);
			this.jobBatchState = jobBatchState;
		}
	}
	
	public class JobBatchState {
		
		private String batchClassName;
		private Map<String, Object> batchParams;
		private String batchScope;
		
		public JobBatchState() {
			this.batchClassName = '';
			this.batchParams = new Map<String, Object>();
			this.batchScope = '1';
		}
		
		public JobBatchState(String batchClassName, Map<String, Object> batchParams, String batchScope) {
			this.batchClassName = batchClassName;
			this.batchParams = batchParams;
			this.batchScope = batchScope;
		}
		
		public String getBatchScope() {
			return this.batchScope;
		}
		
		public Map<String, Object> getBatchParams() {
			return this.batchParams;
		}
		
		public String getBatchParamsAsJSON() {
			JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject();
			for (String paramName : batchParams.keySet()) {
				gen.writeObjectField(paramName, batchParams.get(paramName));
			}
			gen.writeEndObject();
			return gen.getAsString();
		}
		
		public String getBatchClassName() {
			return this.batchClassName;
		}
		
		public void setBatchScope(String batchScope) {
			this.batchScope = batchScope;
		}
		
		public void addBatchParam(String paramName, Object inObject) {
			this.batchParams.put(paramName, inObject);
		}
		
		public void setBatchParams(Map<String, Object> batchParams) {
			this.batchParams = batchParams;
		}
		
		public void setBatchClassName(String batchClassName) {
			this.batchClassName = batchClassName;
		}
	}
}