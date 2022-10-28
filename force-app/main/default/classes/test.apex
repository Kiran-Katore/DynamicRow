list<MilestoneRow__c> mile = [SELECT Name, Percentage_ROW__c, Opportunity__c, Status__c, VLSF_Milestone_Percentage__c, VLSF_Milestone_Date__c, Opportunity__r.Amount_ROW__c, Opportunity__r.VLSF_Amount__c, VLSF_Milestone_Amount__c,VLSF_Purchase_Order__c FROM MilestoneRow__c];
for(MilestoneRow__c m: mile){
    System.debug(m);
}