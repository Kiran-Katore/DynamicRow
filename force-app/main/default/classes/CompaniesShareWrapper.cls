/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Kiran Katore
**/
public with sharing class CompaniesShareWrapper {
        @AuraEnabled
		public String Percentage{get;set;}
        @AuraEnabled
		public Integer Amount{get;set;}
        @AuraEnabled
		public String Name{get;set;}
}
