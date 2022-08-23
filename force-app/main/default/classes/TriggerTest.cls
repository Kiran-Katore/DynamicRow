/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 07-20-2022
 * @last modified by  : Kiran Katore
**/
@isTest
public with sharing class OpportunityTriggerTest {
    @TestSetup
    static void makeData(){
        account acc = new account();
        acc.name = 'Test Account';
        acc.phone = '99999999';
        insert acc;
        contact con = new contact();
        con.lastName = 'Test Contact';
        con.accountId = acc.id;
        insert con;
        opportunity opp = new opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = 'Prospecting';
        opp.closeDate = System.TODAY();
        opp.accountId = acc.id;
        insert opp;
    }
    @isTest
    public static void TriggerTest(){
        list<OpportunityContactRole> oppRole = [select id, contactId, OpportunityId from OpportunityContactRole];
        list<contact> conList = [select id from contact];
        list<opportunity> oppList = [select id from opportunity];
        system.assertEquals(oppRole[0].contactId, conList[0].id);
        system.assertEquals(oppRole[0].OpportunityId, oppList[0].id);
    }
}
