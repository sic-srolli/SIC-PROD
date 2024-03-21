trigger ContrattoTrigger on Contratto__c (before insert, before update) {

    if(ContrattoTriggerHandler.manualSkip) return;

    /* Before Insert */
    if (Trigger.isInsert && Trigger.isBefore) {
        ContrattoTriggerHandler.onBeforeInsert(Trigger.new);
    }

    /* Before Update */
    if (Trigger.isUpdate && Trigger.isBefore) {
        ContrattoTriggerHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
    }
}