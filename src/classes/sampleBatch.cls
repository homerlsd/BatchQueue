global class sampleBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	global String query;
	global List<Account> param2;
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		system.debug('-----sampleBatch-start-----');
		system.debug('-----sampleBatch-start--query---'+query);
		system.debug('-----sampleBatch-start--param2---'+param2);
		for(Integer i = 0; i < 10000;i++) {
			Double i2 = Math.random();
			Double i3 = i2 + 1;
			Blob res = Encodingutil.base64Decode('ASDFGHJKLQWERTYUIOPZXCVBNM');
			String res2 = Encodingutil.base64Encode(res);
		}
		
		return Database.getQueryLocator(query);
		
	}
	
	global void execute(Database.BatchableContext context, List<SObject> records) {
		for(Integer i = 0; i < 10000;i++) {
			Double i2 = Math.random();
			Double i3 = i2 + 1;
			Blob res = Encodingutil.base64Decode('ASDFGHJKLQWERTYUIOPZXCVBNM');
			String res2 = Encodingutil.base64Encode(res);
		}
		system.debug('-----sampleBatch-execute-----');
	}
	
	global void finish(Database.BatchableContext context) {
		for(Integer i = 0; i < 10000;i++) {
			Double i2 = Math.random();
			Double i3 = i2 + 1;
			Blob res = Encodingutil.base64Decode('ASDFGHJKLQWERTYUIOPZXCVBNM');
			String res2 = Encodingutil.base64Encode(res);
		}
		JobManager.finishJob(context.getJobId());
		system.debug('-----sampleBatch-finish-----');
	}
}