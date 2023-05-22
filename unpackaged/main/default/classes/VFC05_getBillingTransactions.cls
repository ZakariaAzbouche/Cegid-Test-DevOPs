/**
* @author Moganaden C - Comforth Karoo
* @date 20213-04-12
* @description Trigger handler class for Service_Level_Price__c
*/
public class VFC05_getBillingTransactions {
    public String quoteId {get;set;}
    public String currencyCode {get;set;}
    public Double totalTransaction {get;set;}
    public List<BillingTransaction__c> lstBillingTransaction {get;set;}
    
    public void init(){
       quoteId =  ApexPages.currentPage().getParameters().get('qid');
       List<BillingPlan__c> lstBillingPlan = [SELECT id,QuoteTotal__c,CurrencyIsoCode,Quote__c,(SELECT id,Step__c,Name,EstimatedDate__c,Percentage__c,MaxDate__c
                                                                  ,Description__c,Amount__c
                                                         FROM Billing_Transactions__r ORDER BY StepNumber__c ASC) 
                                              FROM BillingPlan__c 
                                              WHERE Quote__c =: quoteId 
                                              ORDER BY createdDate DESC
                                              LIMIT 1];
        
       lstBillingTransaction = lstBillingPlan[0].Billing_Transactions__r;
       totalTransaction = lstBillingPlan[0].QuoteTotal__c;
       currencyCode = lstBillingPlan[0].CurrencyIsoCode;
       system.debug('MCU lstBillingTransaction: ' + lstBillingTransaction);

    }

}