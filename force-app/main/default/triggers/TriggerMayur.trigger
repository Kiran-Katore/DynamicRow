/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 07-20-2022
 * @last modified by  : Kiran Katore
**/
trigger createfutherdetails on Opportunity (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        Set<id> accSpecificlds = new Set<Id>();
        
        List <OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        
        Map<Id, List<Contact>> accountSpecificContacts = new Map<Id, List<Contact>>();
        
        for(Opportunity o: Trigger.New) {
            if(o.AccountId != null) 
                accSpecificlds.add(o.AccountId);
        }
        
        for(Contact con: [select id, AccountId from Contact where AccountId in: accSpecificlds]) {
            
            if(!accountSpecificContacts.containsKey(con.AccountId)) 
                accountSpecificContacts.put(con.AccountId, new List<Contact>()); 
            accountSpecificContacts.get(con.AccountId).add(con);
        }
        
        for(Opportunity opp: Trigger.New) {
            
            if(accountSpecificContacts.containskey(opp.AccountId)&& accountSpecificContacts.get(opp.AccountId) != NULL) {
                Boolean isFirstContact = true;
                for(Contact c: accountSpecificContacts.get(opp.AccountId)) { 
                    OpportunityContactRole ocr = new OpportunityContactRole(ContactId = c.Id, OpportunityId = opp.id);
                    if(isFirstContact) {
                        ocr.IsPrimary = true;
                        isFirstContact = false;
                    } 
                    ocrList.add(ocr);
                }
            }
        }
        
        if(ocrList.size() > 0) 
            insert ocrList;
    }
}