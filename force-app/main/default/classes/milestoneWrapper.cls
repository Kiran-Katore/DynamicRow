/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : Kiran Katore
**/
public with sharing class milestoneWrapper {
    public milestoneWrapper() {

    }
    @AuraEnabled
    public string Name {get;set;}
    @AuraEnabled
    public string Percentage {get;set;}
    @AuraEnabled
    public date DueDate {get;set;}
    @AuraEnabled
    public decimal Amount {get;set;}
}
