# ExchangeRates

# Platform Cache Currency Sample
This repository contains all the code, settings, and cache partition for the Platform Cache Currency sample.  The app displays a sample set of currency exchange rates. After initially getting the rates from a web service, the app stores and retrieves rates from the org cache.

## Initial Setup Instructions
1. Download this repository as a zip file.
    * The zip file contains all the files that are needed to install and access the app in Salesforce.
2. Deploy the zip file to your org using Metadata API through Workbench, Force.com IDE, or the Force.com Migration Tool. Your org's user must have the API Enabled permission.
3. Assign the included `Currency App Setting` permission set to your user.

## Use the Currency App 
1. In the App Launcher, select `Currency App`.
    * The app has two tabs. The `Exchange Rates Sample` tab displays the Visualforce page that lists the exchange rates. The `Exchange Rates` tab lists the Exchange_Rate__c custom objects that the app populates.
2. Click the `Exchange Rates Sample` tab.
    * When the `ExchangeRates` Visualforce page displays, its Apex controller, also called `ExchangeRates`, is invoked. The controller executes the logic of initializing and caching exchange rates. The rates are initially obtained from an external web service and are stored in the org cache. Because the cache is temporary, custom object records are used to persist exchange rates in Salesforce. The app refreshes rates that are more than a day old from the external service. After initial execution, subsequent retrievals of exchange rates are obtained from the cache. The app handles cache misses by fetching the rates from Saleforce through SOQL when they're not found in the cache.
	
## Check the Cache Partition
To check the cache partition that this sample uses:
1. In Setup, enter `Platform Cache` in the Quick Find box, then select `Platform Cache`.
2. Click `CurrencyCache`.
The cache partition that this sample uses contains no space allocation for session and org cache (0 MB). The 0 MB allocations is so that you can use this partition for testing purposes, even if your org doesn't have trial cache approved yet. Cache operations are allowed in this partition but no values are stored or returned. Therefore, such a partition enables the testing of cache misses when null is returned for cache get() calls.

## Platform Cache Documentation and Trailhead Module
* <a href="https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_cache_namespace_overview.htm">Platform Cache</a> in the <a href="https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_intro.htm">Apex Developer Guide</a>
* <a href="https://trailhead.salesforce.com/module/platform_cache">Platform Cache Basics Trailhead module</a> (which also features this sample app)
