/*
 * Helper class used by ExchangeRates. Contains methods for:
 * - Making an API callout to an external service.
 * - Parsing the JSON result of the callout. 
 * - Inserting Exchange_Rate__c custom objects records into Salesforce.
 */
public class RateLib {
    static public String newUrl = 'http://api.fixer.io/latest';
    static public String cacheName = 'local.CurrencyCache.';
    static public String baseCurrencies = 'USD';
    
    // URL String for API Connection
    static public String getNewUrlString(String currencies) {
        return newUrl + '?symbols=' + currencies + '&base=' + baseCurrencies;
    }
    
    /*
     * Make an API call and get exchange rates for the specified currencies.
    */
    static public String getRateFromAPI(String currencies) {
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(RateLib.getNewUrlString(currencies));
        req.setMethod('GET');
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res.getBody();
    }
    
    /* 
     * Parse multiple values from JSON string.
    */
    static public Map<String, String> getParseValues(String vals, String currencies) {
        // Create parser based on JSON input.
        JSONParser parser = JSON.createParser(vals);
        
        Map<String, String> mapRates = new Map<String,String>();

        // Split the comma-separated string of currencies
        Iterator<String> itr = currencies.split(',').iterator();
        // Put the currency as the key for each map element.
        while(itr.hasNext()) {
            mapRates.put(itr.next(),null);
        }
        
        // Parse values and add them in the map for the corresponding key.
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(mapRates.containsKey(fieldName)) {
                    mapRates.put(fieldName,parser.getText());
                } 
            }
        }
        
        return mapRates;
    }
    
    /* 
     * Parse single value from JSON string.
    */
    static public String getParseValue(String val, String currencies) {
        // Create parser based on JSON input.
        JSONParser parser = JSON.createParser(val);
        
        Map<String, String> mapRates = new Map<String, String>();

        // Split the comma-separated string of currencies
        Iterator<String> itr = currencies.split(',').iterator();
        while(itr.hasNext()) {
            mapRates.put(itr.next(),null);
        }
        
        String rate;
        // Parse values and add them in the map for the corresponding key.
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(mapRates.containsKey(fieldName)) {
                    rate = parser.getText();
                    mapRates.put(fieldName,rate);
                } 
            }
        }
        return rate;
    }
    
    /*
     * Saves the value into an sObject record.
    */
    static public void saveRate(String rate, String currencies) {
        insert new Exchange_Rate__c (Base_Currency__c = baseCurrencies, 
                                     To_Currency__c =currencies, 
                                     Rate__c = Double.valueOf(rate));
    }
    
    /*
     * Saves a map of values into sObject records.
    */
    static public void saveRates(Map<String, String> rates) {
        Set<String> keys = rates.keySet();
        Iterator<String> itr = keys.iterator();
        while (itr.hasNext()){
            String key = itr.next();
            String rate = rates.get(key);
            insert new Exchange_Rate__c (Base_Currency__c = baseCurrencies, 
                                         To_Currency__c =key, 
                                         Rate__c = Double.valueOf(rate), 
                                         forList__c = true);
        }
    }
}