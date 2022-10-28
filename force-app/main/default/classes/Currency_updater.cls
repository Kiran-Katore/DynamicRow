/**
 * @description       : 
 * @author            : Kiran Katore
 * @group             : 
 * @last modified on  : 09-20-2022
 * @last modified by  : Kiran Katore
**/
public class Currency_updater implements schedulable, database.allowscallouts {
    public void execute(system.schedulableContext sc){
        map<string, Currency_Rate__c> rates = Currency_Rate__c.getAll();
        string endpoint = system.label.currencyapi_Endpoint;
        string apikey = system.label.currencyApi_Key;
        string base_currency = 'INR';
        string currencies = '';
        integer count = 1;
        for(string rate: rates.keyset()){
            currencies +=rate;
            if(!(rates.keyset().size() == count)){
                currencies +=',';
            }
            count++;
        }
        endpoint += 'apikey='+apikey+'&currencies='+currencies+'&base_currency='+base_currency;
        system.debug('endpoint =>'+endpoint);
        makeRequest(endpoint);        
    }
    @future(callout = true)
    public static void makeRequest(string endpoint){
        map <string, decimal> rates;
        map<string, Currency_Rate__c> currencies = Currency_Rate__c.getAll();
        set<string> currencies_sym = currencies.keyset();
        httpRequest req = new httpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        http http = new http();
        httpResponse res = http.send(req);
        if(res.getStatusCode() == 200){
            rates = new map<string,decimal>();
            system.JSONParser jp = JSON.createParser(res.getBody());
            while(jp.nextToken() != null){
                if(jp.getCurrentToken() == system.JSONToken.FIELD_NAME && currencies_sym.contains(jp.getText()) && jp.nextToken() == system.JSONToken.START_OBJECT){
                    wrapperCode w = (wrapperCode) jp.readValueAs(wrapperCode.class);
                    rates.put(w.code, w.value);
                }
            }
        }
        
        list<Currency_Rate__c> update_rate = new list<Currency_Rate__c>();
        for(string r: currencies.keySet()){
            Currency_Rate__c cr = new Currency_Rate__c();
            cr.id = currencies.get(r).id;
            cr.Rate__c = string.valueOf(rates.get(r));
            update_rate.add(cr);
        }
        if(!update_rate.isEmpty()){
            try{
                database.upsertResult[] result = database.upsert(update_rate);
                for(database.upsertResult rs: result){
                    if(rs.isSuccess()){
                        system.debug('Successfully currencies are updated!!!!');
                    }else{
                        system.debug('Error to update currencies');
                    }
                }
            }catch(exception e){
                system.debug('Error ==> '+e.getMessage());
            }
        }
    }
    public class wrapperCode{
        string code;
        decimal value;
    }
    
}