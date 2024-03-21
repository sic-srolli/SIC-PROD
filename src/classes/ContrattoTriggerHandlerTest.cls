@isTest
private with sharing class ContrattoTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Product2 pro0 = new Product2(
            Name = 'Test Product 0',
            ProductCode = 'P_0001'
        );
        insert pro0;

        Account acc0 = new Account(
                Name = 'Test Account 0'
        );
        insert acc0;

        Asset ass0 = new Asset(
            Name = 'Test Asset 0',
            AccountId = acc0.Id,
            Product2Id = pro0.Id,
            SerialNumber = 'S_0001',
            IdOrgCliente__c = 'ORG_01',
            LimiteChiamateSandbox__c = 10
        );
        insert ass0;

    }

    @IsTest
    static void fillResetDatesTest(){

        Account acc0 = [SELECT Id FROM Account LIMIT 1];
        Asset ass0 = [SELECT Id FROM Asset LIMIT 1];

        Contratto__c cont0 = new Contratto__c(
            Asset__c = ass0.Id,
            Account__c = acc0.Id,
            DataInizio__c = System.today().addYears(-1),
            DataFine__c = System.today().addYears(1)
        );

        Test.startTest();

        insert cont0;

        cont0 = [SELECT Id,DataInizio__c,ResetContatoreMensile__c,ResetContatoreAnnuale__c FROM Contratto__c LIMIT 1];
        System.assertEquals(System.today().addMonths(1),cont0.ResetContatoreMensile__c);
        System.assertEquals(System.today().addYears(1),cont0.ResetContatoreAnnuale__c);

        cont0.DataInizio__c = System.today() + 1;
        update cont0;

        Test.stopTest();

        cont0 = [SELECT Id,DataInizio__c,ResetContatoreMensile__c,ResetContatoreAnnuale__c FROM Contratto__c LIMIT 1];
        System.assertEquals(System.today().addMonths(1).addDays(1),cont0.ResetContatoreMensile__c);
        System.assertEquals(System.today().addYears(1).addDays(1),cont0.ResetContatoreAnnuale__c);
    }
}