/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 08-23-2022
 * @last modified by  : Kiran Katore
**/
public with sharing class Dynamic_milestoneCreator {
    public Dynamic_milestoneCreator() {

    }
    @AuraEnabled
    public static list<VLSF_Milestone__c> createMilestone(list<milestoneWrapper> milestoneList, string recordId, string poId){
        list<VLSF_Milestone__c> milestonesList = new list<VLSF_Milestone__c>();
        for (milestoneWrapper mile : milestoneList) {
            System.debug(recordId +' ==> '+mile);
            System.debug('===============');
            if(mile.Name != null && mile.Percentage != null && mile.DueDate != null && mile.Amount != null){
                VLSF_Milestone__c ml = new VLSF_Milestone__c();
                ml.name = mile.Name;
                ml.Opportunity__c = recordId;
                ml.VLSF_Milestone_Percentage__c = Decimal.valueof(mile.Percentage);
                ml.VLSF_Milestone_Date__c = mile.DueDate;
                ml.VLSF_Milestone_Amount__c = mile.Amount;
                //ml.VLSF_Purchase_Order__c = poId;
                ml.Status__c = 'New';
                milestonesList.add(ml);
            }    
        }
        try {
            Database.saveResult[] result = Database.insert(milestonesList, false);
            for(Database.saveResult rs: result ){
                if(rs.isSuccess()){
                    System.debug('Record Inserted =>'+rs.getId());
                }else{
                    for(Database.error er: rs.geterrors()){
                        System.debug('Error ==> '+er.getMessage());
                    }
                }
            }
            VLSF_Opportunity__c opp = new VLSF_Opportunity__c();
            opp.id = recordId;
            opp.PO_ROW_ID__c = poId;
            opp.MilestonesRemailAmount__c = getAmt(recordId);
            update opp;
            return getData(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable = true)
    public static list<VLSF_Milestone__c> getData(string recId){
        list<VLSF_Milestone__c> milestonesData = [SELECT Name, Percentage_ROW__c, Opportunity__c, Status__c, VLSF_Milestone_Percentage__c, VLSF_Milestone_Date__c, Opportunity__r.Amount_ROW__c, Opportunity__r.VLSF_Amount__c, VLSF_Milestone_Amount__c,VLSF_Purchase_Order__c FROM VLSF_Milestone__c WHERE Opportunity__c =: recId];    
        return milestonesData;
    }
    @AuraEnabled
    public static Decimal getAmt(string recordId){
        list<VLSF_Milestone__c> milestonesData = getData(recordId);
        decimal amt = 0;
        decimal total_amt = 0;
        for(VLSF_Milestone__c ml: milestonesData){
            //MilestonesRemailAmount__c
            amt += ml.VLSF_Milestone_Amount__c;
            total_amt = ml.Opportunity__r.VLSF_Amount__c;
        }
        return (total_amt - amt) > 0 ? total_amt - amt : 0;
    }

    public class milestone{
        @AuraEnabled
        public string Name {get;set;}
        // @AuraEnabled
        // public string Percentage {get;set;}
        // @AuraEnabled
        // public date DueDate {get;set;}
        // @AuraEnabled
        // public decimal Amount {get;set;}
    }
}
