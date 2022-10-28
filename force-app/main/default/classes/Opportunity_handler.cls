/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 09-20-2022
 * @last modified by  : Kiran Katore
**/
public class Opportunity_handler {
    public static void updateROWCurrencies(list<VLSF_Opportunity__c> oppList){
        if(!oppList.isEmpty()){
            for(VLSF_Opportunity__c opp: oppList){
                decimal ex_amt = 0;
                try{
                    if(opp.amount_ROW__c.contains(opp.Currency__c)){
                        system.debug('Run');
                        opp.amount_ROW__c = opp.amount_ROW__c.remove(opp.Currency__c+'. ');
                        system.debug(opp.amount_ROW__c);
                    }
                    ex_amt = Decimal.valueOf(opp.amount_ROW__c);
                    opp.VLSF_Amount__c = ex_amt;
                    //opp.MilestonesRemailAmount__c = ex_amt;
                    updateAmt(opp);
                }catch(exception e){
                    opp.Amount_ROW__c.addError('Not Valid Amount');
                }
            }
        }
    }
    public static void updateAmt(VLSF_Opportunity__c opp){
        Currency_Rate__c c = Currency_Rate__c.getInstance(opp.Currency__c);
        decimal amt_inr = opp.VLSF_Amount__c / decimal.valueof(c.rate__c);
        opp.Amount_INR__c = amt_inr.setScale(2, RoundingMode.CEILING);
        opp.Amount_in_INR__c = 'Rs. '+string.valueof(amt_inr.setScale(2, RoundingMode.CEILING));
        //opp.amount_ROW__c = opp.Currency__c +'. '+ opp.amount_ROW__c;
    }

    
    
}