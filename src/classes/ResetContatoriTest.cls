@isTest
private with sharing class ResetContatoriTest {
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

        ContrattoTriggerHandler.manualSkip = true;
        Contratto__c con0 = new Contratto__c(
            Asset__c = ass0.Id,
            Account__c = acc0.Id,
            DataInizio__c = System.today().addYears(-1),
            DataFine__c = System.today().addYears(1),
            ResetContatoreMensile__c = System.today(),
            ResetContatoreAnnuale__c = System.today()
        );
        insert con0;

        List<Licenza__c> lics = new List<Licenza__c>();
        lics.add(new Licenza__c(
            Contratto__c = con0.Id,
            IdUtenteCliente__c = 'USER_0001',
            ChiamateMensili__c = 10,
            ChiamateAnnuali__c = 50
        ));
        lics.add(new Licenza__c(
            Contratto__c = con0.Id,
            IdUtenteCliente__c = 'USER_0002',
            ChiamateMensili__c = 0,
            ChiamateAnnuali__c = 0
        ));
        insert lics;
        ContrattoTriggerHandler.manualSkip = false;
    }

    @IsTest
    static void resetContatoriTest(){

        Test.startTest();

        ResetContatoriSched rcs = new ResetContatoriSched();
        rcs.execute(null);

        Test.stopTest();

        List<Licenza__c> licenses = [SELECT Id,ChiamateMensili__c,ChiamateAnnuali__c FROM Licenza__c ORDER BY IdUtenteCliente__c];
        System.assertEquals(0,licenses[0].ChiamateMensili__c);
        System.assertEquals(0,licenses[0].ChiamateAnnuali__c);
        System.assertEquals(0,licenses[1].ChiamateMensili__c);
        System.assertEquals(0,licenses[1].ChiamateAnnuali__c);

        Contratto__c c = [SELECT Id,ResetContatoreMensile__c,ResetContatoreAnnuale__c FROM Contratto__c LIMIT 1];
        System.assertEquals(System.today().addMonths(1),c.ResetContatoreMensile__c);
        System.assertEquals(System.today().addYears(1),c.ResetContatoreAnnuale__c);
    }
}