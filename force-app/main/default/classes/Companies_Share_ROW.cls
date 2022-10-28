/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Kiran Katore
**/
public with sharing class Companies_Share_ROW {
    //SELECT Name , Opportunities__c , Comapny__c , Percentage_Share__c , Share_Amount__c FROM Companies_Share_ROW__c
    @AuraEnabled
    public static boolean createCompanies(list<CompaniesShareWrapper> cmps, string recordId){
        //CompaniesShareWrapper cmpShare = new CompaniesShareWrapper();
        list<Companies_Share_ROW__c> cmpList = new list<Companies_Share_ROW__c>();
        for(CompaniesShareWrapper cm: cmps){
            Companies_Share_ROW__c cmpShare = new Companies_Share_ROW__c();
            cmpShare.Opportunities__c = recordId;
            cmpShare.Comapny__c = cm.Name;
            cmpShare.Percentage_Share__c = Decimal.valueof(cm.Percentage);
            cmpShare.Share_Amount__c = cm.Amount;
            cmpList.add(cmpShare);
        }
        if(!cmpList.isEmpty()){
            try{
                Database.insert(cmpList);
                list<Companies_Share_ROW__c> lst = [select id from Companies_Share_ROW__c where Opportunities__c =: recordId];
                VLSF_Opportunity__c opp = new VLSF_Opportunity__c(id = recordId);
                opp.Companies_Share_Rollup__c = lst.size();
                update opp;
                return true;
            }catch(Exception e) {
                System.debug(e.getMessage());
                return false;
            }
        }
        return false;
    }

}
