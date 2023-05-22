/**
 * @author Soufiane LOGDALI - Comforth Karoo
 * @date 17/10/20200
 * @description Trigger SM for CreditNoteLine__c
*/

public with sharing class SM025_CreditNoteLine {

    public static void postCreditNoteLine(Set<Id> creditNoteLineIds) {
        Map<String,Map<Id,CreditNoteLineController.InvoicePostWrapper>> mapCreditNoteLine = new Map<String,Map<Id,CreditNoteLineController.InvoicePostWrapper>>{};
        Map<String,Map<Id,List<Id>>> mapCreditNoteLineIds = new Map<String,Map<Id,List<Id>>>{};
        List<CreditNoteLine__c> listCreditNoteLine = [SELECT CreditNoteAmount__c, 
                                        CreditNote__c, CreditNote__r.CustomerRequest__r.Comment__c, CreditNote__r.tech_SendCreditNoteToCustomer__c,
                                        CreditNote__r.CustomerRequest__r.CreditNoteReason3__c, CreditNote__r.CustomerRequest__r.Subsidiary__c, 
                                        InvoiceLine__r.Invoice__r.Name, InvoiceLine__r.invoiceItemId__c, InvoiceLine__r.Quantity__c, 
                                        InvoiceLine__r.LoadName__c, InvoiceLine__r.StartDate__c, InvoiceLine__r.EndDate__c 
                                        FROM CreditNoteLine__c WHERE Id IN :creditNoteLineIds];
        system.debug('postCreditNoteLine listCreditNoteLine : '+ listCreditNoteLine);
        system.debug('postCreditNoteLine listCreditNoteLine testing [0] Invoice__r.Name : '+ listCreditNoteLine[0].InvoiceLine__r.Invoice__r.Name);
        
        List<ons_EntityMatchingTable__mdt> entityMatchingTable = [SELECT Label, EntityCode__c FROM ons_EntityMatchingTable__mdt ];
        Map<String, String> entityMap = new Map<String, String>();    
        for(ons_EntityMatchingTable__mdt entity: entityMatchingTable){
            entityMap.put(entity.Label, entity.EntityCode__c);
        }
        System.debug('entityMap : '+ entityMap);

        for(CreditNoteLine__c creditNoteLine: listCreditNoteLine){
            System.debug('Subsidiary__c : '+ entityMap.get(creditNoteLine.CreditNote__r.CustomerRequest__r.Subsidiary__c));
            CreditNoteLineController.InvoiceItemsPostWrapper item = new CreditNoteLineController.InvoiceItemsPostWrapper();
            item.amount = creditNoteLine.CreditNoteAmount__c;
            item.comment = '';
            item.invoiceItemId = creditNoteLine.InvoiceLine__r.invoiceItemId__c;
            item.quantity = creditNoteLine.InvoiceLine__r.Quantity__c;
            item.serviceStartDate = String.valueOf(creditNoteLine.InvoiceLine__r.StartDate__c);
            item.serviceEndDate = String.valueOf(creditNoteLine.InvoiceLine__r.EndDate__c);
            item.skuName = creditNoteLine.InvoiceLine__r.LoadName__c;
            item.unitOfMeasure = '';

            if(mapCreditNoteLine.get(creditNoteLine.InvoiceLine__r.Invoice__r.Name) == null){
                List<CreditNoteLineController.InvoiceItemsPostWrapper> items = new List<CreditNoteLineController.InvoiceItemsPostWrapper>();
                items.add(item);

                CreditNoteLineController.InvoicePostWrapper invoicePost = new CreditNoteLineController.InvoicePostWrapper();
                invoicePost.autoApplyToInvoiceUponPosting = false;
                invoicePost.autoPost = true;
                invoicePost.visibleClient = creditNoteLine.CreditNote__r.tech_SendCreditNoteToCustomer__c ? 'Oui' : 'Non';
                invoicePost.comment = creditNoteLine.CreditNote__r.CustomerRequest__r.Comment__c;
                invoicePost.effectiveDate = (String.valueOf(date.today())).SubStringBefore(' ');
                invoicePost.taxAutoCalculation = true;
                invoicePost.excludeFromAutoApplyRules = false;
                ///invoicePost.motif = '003| AA - Avoir pour Refacturation';
                invoicePost.motif = creditNoteLine.CreditNote__r.CustomerRequest__r.CreditNoteReason3__c;
                ///invoicePost.entity = '002';
                invoicePost.entity = entityMap.get(creditNoteLine.CreditNote__r.CustomerRequest__r.Subsidiary__c);
                invoicePost.items = items;
                invoicePost.reasonCode = 'Write-off';

                mapCreditNoteLine.put(creditNoteLine.InvoiceLine__r.Invoice__r.Name, new Map<Id, CreditNoteLineController.InvoicePostWrapper>{creditNoteLine.CreditNote__c => invoicePost});
                mapCreditNoteLineIds.put(creditNoteLine.InvoiceLine__r.Invoice__r.Name, new Map<Id, List<Id>>{creditNoteLine.CreditNote__c => new List<Id> { creditNoteLine.Id }});
            } else{
                ((mapCreditNoteLine.get(creditNoteLine.InvoiceLine__r.Invoice__r.Name)).get(creditNoteLine.CreditNote__c)).items.add(item);
                ((mapCreditNoteLineIds.get(creditNoteLine.InvoiceLine__r.Invoice__r.Name)).get(creditNoteLine.CreditNote__c)).add(creditNoteLine.Id);
            }
        }

        system.debug('postCreditNoteLine mapCreditNoteLine : '+ mapCreditNoteLine);
        system.debug('postCreditNoteLine mapCreditNoteLineIds : '+ mapCreditNoteLineIds);
        

        for (String invoiceName: mapCreditNoteLine.keyset()){
            system.debug('postCreditNoteLine map loop invoiceName : '+ invoiceName);
            for (Id CreditNoteId: (mapCreditNoteLine.get(invoiceName)).keyset()){
                system.debug('postCreditNoteLine map loop CreditNoteId : '+ CreditNoteId);
                system.debug('postCreditNoteLine map loop Value : '+ (mapCreditNoteLine.get(invoiceName)).get(CreditNoteId));

                //CreditNoteLineController.postCreditNoteLine(String.valueOf((mapCreditNoteLine.get(invoiceName)).get(CreditNoteId)), invoiceName);           
                
                String invoicePost = JSON.serialize((mapCreditNoteLine.get(invoiceName)).get(CreditNoteId));  
                system.debug('Before post invoicePost : '+ invoicePost);
                system.debug('Before post invoicePost.length() : '+ invoicePost.length());

                system.debug('List Ids to send : '+ (mapCreditNoteLineIds.get(invoiceName)).get(CreditNoteId));

                CreditNoteLineController.postCreditNoteLine(invoicePost, invoiceName, (mapCreditNoteLineIds.get(invoiceName)).get(CreditNoteId));   
                
                
                for (Integer i = 0; i < invoicePost.length(); i=i+300) {
                    Integer iEffectiveEnd = (i+300 > (invoicePost.length()) ? invoicePost.length()-1 : i+300);
                    System.debug(invoicePost.substring(i,iEffectiveEnd));
                }
     
            }
        }
    }
}