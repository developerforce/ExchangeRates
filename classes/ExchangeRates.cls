public class ExchangeRates {
    private String currencies = 'EUR,GBP,CAD,PLN,INR,AUD,SGD,CHF,MYR,JPY,CNY';
    public String getCurrencies() { return currencies;}
    public Exchange_Rate__c[] rates {get; set;}
    

    //                                                                          
    // Checks if the data is old and gets new data from an external web service 
    // through a callout. Calls getCachedRates() to manage the cache.           
    //                                                                          
    public void init() {
        // Let's query the latest data from Salesforce
        Exchange_Rate__c[] latestRecords = ([SELECT CreatedDate FROM Exchange_Rate__c 
                        WHERE Base_Currency__c =:RateLib.baseCurrencies 
                              AND forList__c = true 
                        ORDER BY CreatedDate DESC
                        LIMIT 1]);
        
        // If what we have in Salesforce is old, get fresh data from the API
        if ( latestRecords == null  
            || latestRecords.size() == 0 
            || latestRecords[0].CreatedDate.date() < Datetime.now().date()) {
            // Make API request and parse value out
            String tempString = RateLib.getRateFromAPI(currencies);
            // Parse JSON return values
            Map<String, String> apiStrings = RateLib.getParseValues(
                tempString, currencies);
            
            // Let's store the data in Salesforce
            RateLib.saveRates(apiStrings);

            // Remove the cache key so it gets refreshed in getCachedRates()
            Cache.Org.remove('Rates');
        }
        // Call method to manage the cache
        rates = getCachedRates();
    }
    

    //                                                                          
    // Main method for managing the org cache.                                  
    // - Returns exchange rates (Rates key) from the org cache.                 
    // - Checks for a cache miss.                                               
    // - If there is a cache miss, returns exchange rates from Salesforce       
    //    through a SOQL query, and updates the cached value.                   
    //                                                                          
    public Exchange_Rate__c[] getCachedRates() {
        // Get the cached value for key named Rates
        Exchange_Rate__c[] rates = (Exchange_Rate__c[])Cache.Org.get(
            RateLib.cacheName+'Rates');
        
        // Is it a cache miss? 
        if(rates == null) {
            // There was a cache miss so get the data via SOQL
            rates = [SELECT Id, Base_Currency__c, To_Currency__c, Rate__c 
                        FROM Exchange_Rate__c 
                        WHERE Base_Currency__c =:RateLib.baseCurrencies 
                              AND forList__c = true
                              AND CreatedDate = TODAY WITH SECURITY_ENFORCED];
            // Reload the cache
            Cache.Org.put(RateLib.cacheName+'Rates', rates);
        }
        return rates;
    }
}
