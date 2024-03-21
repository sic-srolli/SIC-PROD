public with sharing class ContrattoTriggerHandler {

    public static Boolean manualSkip = false;

    public static void onBeforeInsert(List<Contratto__c> newList){
        fillResetDates(newList,null);
    }

    public static void onBeforeUpdate(List<Contratto__c> newList, Map<Id,Contratto__c> oldMap){
        fillResetDates(newList,oldMap);
    }

    public static void fillResetDates(List<Contratto__c> newList, Map<Id,Contratto__c> oldMap){
        for(Contratto__c c : newList){
            if(Trigger.isInsert || c.DataInizio__c != oldMap.get(c.Id).DataInizio__c){
                c.ResetContatoreMensile__c = getFollowingDate('MONTH',c.DataInizio__c);
                c.ResetContatoreAnnuale__c = getFollowingDate('YEAR',c.DataInizio__c);
            }
        }
    }

    public static Date getFollowingDate(String type, Date d){
        Date today = System.today();
        d = type == 'MONTH' ? d.addMonths(1) : d.addYears(1);
        if(d > today) 
            return d;
        else 
            return getFollowingDate(type,d);
    }
}