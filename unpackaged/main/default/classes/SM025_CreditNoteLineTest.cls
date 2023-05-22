/** 
  @File Name          : SM025_CreditNoteLineTest
  @Description        : test class for SM025_CreditNoteLine 
  @Author             : JDA   
  @Group              : Comforth_Easyfront
  @Last Modified By   : 
  @Last Modified On   : 
  @Modification Log   : 
  Ver       Date            Author      		    Modification
  ---    -----------       -------           ------------------------ 
  1.0    27/02/2023         JDA                 Initial Version
  ---    -----------       -------           ------------------------ 
**/
@isTest
public class SM025_CreditNoteLineTest {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @isTest static void testCreditNoteLineTriggerWithoutZuoraAsOrigin(){

        Account acc = new Account();
        acc.Name='Test';
        acc.ERP_Number__c='98671965';
        acc.National_ID__c='12345677789999';
        acc.BillingCountry='France';
        acc.BillingPostalCode='12354';
        acc.BillingCity='Paris';
        acc.NumberOfEmployees=12;
        acc.AnnualRevenue=1234;
        insert acc;

        
        CustomerRequest__c customerRequest1 = new CustomerRequest__c();
        customerRequest1.Account__c=acc.Id;
        customerRequest1.Type__c='Credit Note';
        customerRequest1.Comment__c ='Test update';
        insert customerRequest1;
      
        CreditNote__c creditNote = new CreditNote__c();
        creditNote.Subsidiary__c ='CEGID SA';
        insert creditNote;

        Invoice__c invoice = new Invoice__c();
        insert invoice;

     


        InvoiceLine__c invoiceLineItem = new InvoiceLine__c();
        invoiceLineItem.Amount__c = 10000;
        invoiceLineItem.Invoice__c = invoice.id;
        invoiceLineItem.CustomerRequest__c = customerRequest1.id;
        invoiceLineItem.invoiceItemId__c ='A526489424';
        invoiceLineItem.Quantity__c =2;
        invoiceLineItem.StartDate__c = System.today();
        invoiceLineItem.EndDate__c= System.today().addDays(10);
        invoiceLineItem.LoadName__c ='SKU 300';
        insert invoiceLineItem;
 

        CreditNoteLine__c creditNoteLine = new CreditNoteLine__c();
        creditNoteLine.CreditNoteAmount__c = 500;
        creditNoteLine.CreditNote__c = creditNote.Id;
        creditNoteLine.InvoiceLine__c = invoiceLineItem.Id;



        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CustomerRequestsFormControllerMock('Access_Token_Endpoint'));
        Test.setMock(HttpCalloutMock.class, new CreditNoteLineControllerMock());
        System.runAs(adminUser) {
            insert creditNoteLine;
        }
        Test.stopTest();

        
    }
    @isTest static void testCreditNoteLineTriggerWithZuoraAsOrigin(){
      
       
        Account acc = new Account();
        acc.Name='Test';
        acc.ERP_Number__c='98671965';
        acc.National_ID__c='12345677789999';
        acc.BillingCountry='France';
        acc.BillingPostalCode='12354';
        acc.BillingCity='Paris';
        acc.NumberOfEmployees=12;
        acc.AnnualRevenue=1234;
        insert acc;

        
        CustomerRequest__c customerRequest1 = new CustomerRequest__c();
        customerRequest1.Account__c=acc.Id;
        customerRequest1.Type__c='Credit Note';
        customerRequest1.Comment__c ='Test update';
        insert customerRequest1;
      
        CreditNote__c creditNote2 = new CreditNote__c();
        creditNote2.Subsidiary__c ='CEGID SA';
        insert creditNote2;

        Invoice__c invoice = new Invoice__c();
        insert invoice;

        InvoiceLine__c invoiceLineItem = new InvoiceLine__c();
        invoiceLineItem.Amount__c = 10000;
        invoiceLineItem.Invoice__c = invoice.id;
        invoiceLineItem.CustomerRequest__c = customerRequest1.id;
        invoiceLineItem.invoiceItemId__c ='A526489424';
        invoiceLineItem.Quantity__c =2;
        invoiceLineItem.StartDate__c = System.today();
        invoiceLineItem.EndDate__c= System.today().addDays(10);
        invoiceLineItem.LoadName__c ='SKU 300';
        insert invoiceLineItem;
 

        CreditNoteLine__c creditNoteLine = new CreditNoteLine__c();
        creditNoteLine.CreditNoteAmount__c = 500;
        creditNoteLine.CreditNote__c = creditNote2.Id;
        creditNoteLine.Origin__c = 'ZUORA';
        creditNoteLine.InvoiceLine__c = invoiceLineItem.Id;


        BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);

        List<Customer_Requests_API_Properties__c> customerRequestsAPIProperties = new List<Customer_Requests_API_Properties__c>();
        Customer_Requests_API_Properties__c customerRequestsAPIPropertie1 = new Customer_Requests_API_Properties__c();
		customerRequestsAPIPropertie1.Name ='Access_Token_Endpoint';
        customerRequestsAPIPropertie1.Value__c ='https://uat-cegid-oauth-provider.de-c1.eu1.cloudhub.io/v2/access-token';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie1);

        Customer_Requests_API_Properties__c customerRequestsAPIPropertie2 = new Customer_Requests_API_Properties__c();
        customerRequestsAPIPropertie2.Name ='Client_Secret';
        customerRequestsAPIPropertie2.Value__c ='abc123456789';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie2);

        Customer_Requests_API_Properties__c customerRequestsAPIPropertie3 = new Customer_Requests_API_Properties__c();
        customerRequestsAPIPropertie3.Name ='Client_Id';
        customerRequestsAPIPropertie3.Value__c ='efg123456789';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie3);

        Customer_Requests_API_Properties__c customerRequestsAPIPropertie4 = new Customer_Requests_API_Properties__c();
        customerRequestsAPIPropertie4.Name ='InvoiceLines_Endpoint';
        customerRequestsAPIPropertie4.Value__c ='https://egid/api/exp-cegid-salesforce-api-acceptance/v1/invoiceLines';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie4);

        Customer_Requests_API_Properties__c customerRequestsAPIPropertie5 = new Customer_Requests_API_Properties__c();
        customerRequestsAPIPropertie5.Name ='Subscriptions_Endpoint';
        customerRequestsAPIPropertie5.Value__c ='https://egid/api/exp-cegid-salesforce-api-acceptance/v1/subscriptions';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie5);
        
        Customer_Requests_API_Properties__c customerRequestsAPIPropertie6 = new Customer_Requests_API_Properties__c();
		customerRequestsAPIPropertie6.Name ='CreditNote_Endpoint';
        customerRequestsAPIPropertie6.Value__c ='https://uat-cegid-oauth-provider.de-c1.eu1.cloudhub.io/v2/access-token2';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie6);
        
		insert customerRequestsAPIProperties ;
        
      
        Test.setMock(HttpCalloutMock.class, new CustomerRequestsFormControllerMock('Access_Token_Endpoint'));
        Test.setMock(HttpCalloutMock.class, new CustomerRequestsFormControllerMock('CreditNote_Endpoint'));

        System.runAs(adminUser) {
            insert bypass;
            insert creditNoteLine;
        }

        
    }
}