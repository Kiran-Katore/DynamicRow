/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 07-20-2022
 * @last modified by  : Kiran Katore
**/
public with sharing class AuraTest {
    public static void oppCounter(list<opportunity> oppList){
        map<string, integer> oppToProcess = new map<string, integer>();
        list<account> accToUpdate = new list<account>();
        list<account> countOpp = new list<account>();
        list<string> accToQuery = new list<string>();
        if(!oppList.isEmpty()){
            for(opportunity opp: oppList){
                accToQuery.add(opp.accountId);
            }
        }
        if(!accToQuery.isEmpty()){
            countOpp = [select id, name, (select id from opportunities) from account where id=:accToQuery];
            if(!countOpp.isEmpty()){
                for(account acc: countOpp){
                    oppToProcess.put(acc.id, acc.opportunities.size());
                }
            }
        }
        if(!oppToProcess.isEmpty()){
            for(string accId: oppToProcess.keyset()){
                account acc = new account();
                acc.id = accId;
                acc.count = oppToProcess.get(accId);
                accToUpdate.add(acc);
            }
        }
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }   
}
