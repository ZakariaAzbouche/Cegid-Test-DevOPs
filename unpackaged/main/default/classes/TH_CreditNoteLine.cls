/**
 * @author Soufiane LOGDALI - Comforth Karoo
 * @date 17/10/20200
 * @description Trigger handler class for CreditNoteLine__c
*/

public with sharing class TH_CreditNoteLine extends TriggerHandler {

    public override void afterInsert() {
        system.debug('TH_CreditNoteLine afterInsert');
        Set<Id> creditNoteLineIds= new Set<Id>();
        for(CreditNoteLine__c cnl:(List<CreditNoteLine__c>)Trigger.New){
			system.debug('New Credit Note Line : '+ cnl);
            
            if(cnl.Origin__c == 'ZUORA'){
                creditNoteLineIds.add(cnl.Id);
        	}
        }
        system.debug('TH_CreditNoteLine creditNoteLineIds : '+ creditNoteLineIds);
        
        if(creditNoteLineIds.size()>0){
            SM025_CreditNoteLine.postCreditNoteLine(creditNoteLineIds);
        }
    }
}