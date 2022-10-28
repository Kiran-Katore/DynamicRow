/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 09-02-2022
 * @last modified by  : Kiran Katore
**/
public without sharing class Dynamic_milestoneCreator {
    public static integer milestonesCreated = 0;
    public static decimal milstoneAmtRollup = 0;
    public Dynamic_milestoneCreator() {

    }
    @AuraEnabled
    public static list<MilestoneRow__c> createMilestone(list<milestoneWrapper> milestoneList, string recordId, string poId){
        list<MilestoneRow__c> milestonesList = new list<MilestoneRow__c>();
        for (milestoneWrapper mile : milestoneList) {
            System.debug(recordId +' ==> '+recordId);
            System.debug('===============');
            if(mile.Name != null && mile.Percentage != null && mile.DueDate != null && mile.Amount != null){
                MilestoneRow__c ml = new MilestoneRow__c();
                ml.name = mile.Name;
                ml.Opportunity__c = recordId;
                ml.VLSF_Milestone_Percentage__c = Decimal.valueof(mile.Percentage);
                ml.VLSF_Milestone_Date__c = mile.DueDate;
                ml.VLSF_Milestone_Amount__c = mile.Amount;
                //ml.VLSF_Purchase_Order__c = poId;
                //ml.Status__c = 'New';
                System.debug(ml);
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
            //opp.PO_ROW_ID__c = poId;
            opp.MilestonesRemailAmount__c = getAmt(recordId);
            opp.Milestone_Created__c = milestonesCreated;
            opp.Rollup_Milestone_Amt__c = milstoneAmtRollup;
            System.debug(opp);
            update opp;
            return getData(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable = true)
    public static list<MilestoneRow__c> getData(string recId){
        //list<VLSF_Milestone__c> milestonesData = [SELECT Name, Percentage_ROW__c, Opportunity__c, Status__c, VLSF_Milestone_Percentage__c, VLSF_Milestone_Date__c, Opportunity__r.Amount_ROW__c, Opportunity__r.VLSF_Amount__c, VLSF_Milestone_Amount__c,VLSF_Purchase_Order__c FROM VLSF_Milestone__c WHERE Opportunity__c =: recId];    
        //return milestonesData;
        for (milestoneRow__c ml : [SELECT Name, Percentage_ROW__c, Opportunity__c, Status__c, VLSF_Milestone_Percentage__c, VLSF_Milestone_Date__c, Opportunity__r.Amount_ROW__c, Opportunity__r.VLSF_Amount__c, VLSF_Milestone_Amount__c,VLSF_Purchase_Order__c FROM MilestoneRow__c WHERE Opportunity__c =: recId]){
            System.debug(ml);
        }
        return [SELECT Name, Milestone_Amount_ROW__c, Percentage_ROW__c, Opportunity__c, Status__c, VLSF_Milestone_Percentage__c, VLSF_Milestone_Date__c, Opportunity__r.Amount_ROW__c, Opportunity__r.VLSF_Amount__c, VLSF_Milestone_Amount__c,VLSF_Purchase_Order__c FROM MilestoneRow__c WHERE Opportunity__c =: recId]; 
    }
    @AuraEnabled
    public static Decimal getAmt(string recordId){
        list<MilestoneRow__c> milestonesData = getData(recordId);
        milestonesCreated = milestonesData.size();
        decimal amt = 0;
        decimal total_amt = 0;
        for(MilestoneRow__c ml: milestonesData){
            //MilestonesRemailAmount__c
            amt += ml.VLSF_Milestone_Amount__c;
            total_amt = ml.Opportunity__r.VLSF_Amount__c;
            System.debug('amt==>'+amt);
            System.debug('total_amt ==> '+total_amt);
        }
        milstoneAmtRollup = amt;
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