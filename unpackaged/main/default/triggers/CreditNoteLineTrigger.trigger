/**
 * @author Soufiane LOGDALI - Comforth Karoo
 * @date 17/10/20200
 * @description Trigger for CreditNoteLine__c
*/

trigger CreditNoteLineTrigger on CreditNoteLine__c (after delete, after insert, after update, before delete, before insert, before update) {
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    system.debug('getAuth' + getAuth.Activatetrigger__c);
    
    if(getAuth.Activatetrigger__c == true){
        new TH_CreditNoteLine().run();
    }
}