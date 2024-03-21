public with sharing class ResetContatoriBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id,Contratto__c,Contratto__r.ResetContatoreMensile__c,Contratto__r.ResetContatoreAnnuale__c FROM Licenza__c WHERE (Contratto__r.ResetContatoreMensile__c = TODAY OR Contratto__r.ResetContatoreAnnuale__c = TODAY) AND Contratto__r.AttivoCheckbox__c = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Licenza__c> scope){
        Map<String,Contratto__c> contractsByIdMap = new Map<String,Contratto__c>();
        for(Licenza__c l : scope){
            if(contractsByIdMap.get(l.Contratto__c) == null) 
                contractsByIdMap.put(l.Contratto__c,new Contratto__c(Id = l.Contratto__c));
            if(l.Contratto__r.ResetContatoreMensile__c == System.today()){
                l.ChiamateMensili__c = 0;
                contractsByIdMap.get(l.Contratto__c).ResetContatoreMensile__c = System.today().addMonths(1);
            }
            if(l.Contratto__r.ResetContatoreAnnuale__c == System.today()){
                l.ChiamateAnnuali__c = 0;
                contractsByIdMap.get(l.Contratto__c).ResetContatoreAnnuale__c = System.today().addYears(1);
            }
        }
        ContrattoTriggerHandler.manualSkip = true;
        update scope;
        update contractsByIdMap.values();
        ContrattoTriggerHandler.manualSkip = false;
    }
    
    public void finish(Database.BatchableContext bc){}
}