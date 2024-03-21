@isTest
private with sharing class API_INBOUND_Tests {
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

        Contratto__c con0 = new Contratto__c(
            Asset__c = ass0.Id,
            Account__c = acc0.Id,
            DataInizio__c = System.today() - 10,
            DataFine__c = System.today() + 10,
            LimiteChiamateMensiliUtente__c = 50
        );
        insert con0;

        List<Licenza__c> lics = new List<Licenza__c>();
        lics.add(new Licenza__c(
            Contratto__c = con0.Id,
            IdUtenteCliente__c = 'USER_0001'
        ));
        lics.add(new Licenza__c(
            Contratto__c = con0.Id,
            IdUtenteCliente__c = 'USER_0002'
        ));
        lics.add(new Licenza__c(
            Contratto__c = con0.Id,
            IdUtenteCliente__c = 'USER_0003',
            Disattiva__c = true
        ));
        insert lics;

    }

    // ----------------- START ASSET CHECK TESTS ----------------- //
    @IsTest
    static void AssetCheckOk(){

        Test.startTest();
        API_INBOUND_AssetCheck.CheckSerialWrapperResponse res = API_INBOUND_AssetCheck.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION'
        );
        Test.stopTest();

        System.assertEquals(true,res.success);
        System.assertEquals(null,res.error);
        System.assertEquals(2,res.licenses.size());
        System.assertEquals(100,res.asset.limitCalls);
        System.assertEquals(0,res.asset.performedCalls);
        System.assertEquals(100,res.asset.availableCalls);
    }

    @IsTest
    static void AssetCheckSandboxOk(){

        Test.startTest();
        API_INBOUND_AssetCheck.CheckSerialWrapperResponse res = API_INBOUND_AssetCheck.execute(
            'ORG_01',
            'S_0001',
            'SANDBOX'
        );
        Test.stopTest();

        System.assertEquals(true,res.success);
        System.assertEquals(null,res.error);
        System.assertEquals(0,res.licenses.size());
        System.assertEquals(10,res.asset.limitCalls);
        System.assertEquals(0,res.asset.performedCalls);
        System.assertEquals(10,res.asset.availableCalls);
    }
    
    @IsTest
    static void AssetCheckKoNoInput(){

        Test.startTest();
        API_INBOUND_AssetCheck.CheckSerialWrapperResponse res = API_INBOUND_AssetCheck.execute(
            '',
            'S_0001',
            'PRODUCTION'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E001',res.error.errorCode);
        System.assertEquals(0,res.licenses.size());
    }

    @IsTest
    static void AssetCheckKoNoAsset(){

        Test.startTest();
        API_INBOUND_AssetCheck.CheckSerialWrapperResponse res = API_INBOUND_AssetCheck.execute(
            'ORG_01',
            'S_0002',
            'PRODUCTION'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E004',res.error.errorCode);
        System.assertEquals(0,res.licenses.size());
    }
    // ----------------- END ASSET CHECK TESTS ----------------- //

    // ----------------- START LICENSE CHECK TESTS ----------------- //
    @IsTest
    static void LicenseCheckOk(){

        Test.startTest();
        API_INBOUND_LicenseCheck.CheckLicenseWrapperResponse res = API_INBOUND_LicenseCheck.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            'USER_0001'
        );
        Test.stopTest();

        System.assertEquals(true,res.success);
        System.assertEquals(null,res.error);
        System.assertEquals(100,res.asset.limitCalls);
        System.assertEquals(0,res.asset.performedCalls);
        System.assertEquals(100,res.asset.availableCalls);
    }

    @IsTest
    static void LicenseCheckSandboxOk(){

        Test.startTest();
        API_INBOUND_LicenseCheck.CheckLicenseWrapperResponse res = API_INBOUND_LicenseCheck.execute(
            'ORG_01',
            'S_0001',
            'SANDBOX',
            'USER_0001'
        );
        Test.stopTest();

        System.assertEquals(true,res.success);
        System.assertEquals(null,res.error);
        System.assertEquals(10,res.asset.limitCalls);
        System.assertEquals(0,res.asset.performedCalls);
        System.assertEquals(10,res.asset.availableCalls);
    }

    @IsTest
    static void LicenseCheckKoNoInput(){

        Test.startTest();
        API_INBOUND_LicenseCheck.CheckLicenseWrapperResponse res = API_INBOUND_LicenseCheck.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            ''
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E002',res.error.errorCode);
    }

    @IsTest
    static void LicenseCheckKoNoAsset(){

        Test.startTest();
        API_INBOUND_LicenseCheck.CheckLicenseWrapperResponse res = API_INBOUND_LicenseCheck.execute(
            'ORG_01',
            'S_0002',
            'PRODUCTION',
            'USER_0001'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E004',res.error.errorCode);
    }

    @IsTest
    static void LicenseCheckKoNoLicense(){

        Test.startTest();
        API_INBOUND_LicenseCheck.CheckLicenseWrapperResponse res = API_INBOUND_LicenseCheck.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            'USER_0004'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E005',res.error.errorCode);
    }

    @IsTest
    static void LicenseCheckKoLicenseInactive(){

        Test.startTest();
        API_INBOUND_LicenseCheck.CheckLicenseWrapperResponse res = API_INBOUND_LicenseCheck.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            'USER_0003'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E006',res.error.errorCode);
    }

    @IsTest
    static void LicenseCheckKoLimitExceeded(){
        List<Licenza__c> lics = [SELECT Id FROM Licenza__c ORDER BY Name];
        lics[0].ChiamateMensili__c = 100;
        update lics[0];

        Test.startTest();
        API_INBOUND_LicenseCheck.CheckLicenseWrapperResponse res = API_INBOUND_LicenseCheck.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            'USER_0001'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E007',res.error.errorCode);
        System.assertEquals(null,res.asset);
    }

    @IsTest
    static void LicenseCheckSandboxKoLimitExceeded(){
        Asset a = [SELECT Id FROM Asset];
        a.ChiamateEffettuateSandbox__c = 10;
        update a;

        Test.startTest();
        API_INBOUND_LicenseCheck.CheckLicenseWrapperResponse res = API_INBOUND_LicenseCheck.execute(
            'ORG_01',
            'S_0001',
            'SANDBOX',
            'USER_0001'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E007',res.error.errorCode);
        System.assertEquals(null,res.asset);
    }
    // ----------------- END LICENSE CHECK TESTS ----------------- //

    // ----------------- START LICENSE INCREMENT TESTS ----------------- //
    @IsTest
    static void LicenseIncrementOk(){

        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            'USER_0001'
        );
        Test.stopTest();

        System.assertEquals(true,res.success);
        System.assertEquals(null,res.error);
        Licenza__c l = [SELECT Id,ChiamateMensili__c FROM Licenza__c  ORDER BY Name][0];
        System.assertEquals(1,l.ChiamateMensili__c);
    }

    @IsTest
    static void LicenseIncrementSandboxOk(){

        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0001',
            'SANDBOX',
            'USER_0001'
        );
        Test.stopTest();

        System.assertEquals(true,res.success);
        System.assertEquals(null,res.error);
        Asset a = [SELECT Id,ChiamateEffettuateSandbox__c FROM Asset];
        System.assertEquals(1,a.ChiamateEffettuateSandbox__c);
    }

    @IsTest
    static void LicenseIncrementKoNoInput(){
       
        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            ''
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E002',res.error.errorCode);
    }

    @IsTest
    static void LicenseIncrementKoNoAsset(){

        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0002',
            'PRODUCTION',
            'USER_0001'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E004',res.error.errorCode);
    }

    @IsTest
    static void LicenseIncrementKoNoLicense(){

        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            'USER_0004'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E005',res.error.errorCode);
    }

    @IsTest
    static void LicenseIncrementKoLicenseInactive(){

        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            'USER_0003'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E006',res.error.errorCode);
    }

    @IsTest
    static void LicenseIncrementKoLimitExceeded(){
        List<Licenza__c> lics = [SELECT Id FROM Licenza__c ORDER BY Name];
        lics[1].ChiamateMensili__c = 100;
        update lics[1];

        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            'USER_0002'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E007',res.error.errorCode);
    }

    @IsTest
    static void LicenseIncrementSandboxKoLimitExceeded(){
        Asset a = [SELECT Id FROM Asset];
        a.ChiamateEffettuateSandbox__c = 10;
        update a;

        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0001',
            'SANDBOX',
            'USER_0002'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E007',res.error.errorCode);
    }

    @IsTest
    static void LicenseIncrementKoApex(){

        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            'USER_0002'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E010',res.error.errorCode);
    }

    @IsTest
    static void LicenseIncrementSandboxKoApex(){

        Test.startTest();
        API_INBOUND_LicenseIncrement.IncrementLicenseWrapperResponse res = API_INBOUND_LicenseIncrement.execute(
            'ORG_01',
            'S_0001',
            'SANDBOX',
            'USER_0002'
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E010',res.error.errorCode);
    }
    // ----------------- END LICENSE INCREMENT TESTS ----------------- //

    // ----------------- START LICENSES UPDATE TESTS ----------------- //
    @IsTest
    static void LicenseUpdateOk(){
        List<Licenza__c> lics = [SELECT Id FROM Licenza__c ORDER BY Name];

        Test.startTest();
        API_INBOUND_LicenseUpdate.UpdateLicenseWrapperResponse res = API_INBOUND_LicenseUpdate.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            new List<API_INBOUND_LicenseUpdate.LicenseWrapperRequest>{
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[0].Id, 'USER_0001_Edit'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[1].Id, 'USER_0002'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[2].Id, 'USER_0003')
            }
        );
        Test.stopTest();

        System.assertEquals(true,res.success);
        System.assertEquals(null,res.error);
        System.assertEquals(3,res.licenses.size());
        Licenza__c l = [SELECT Id,IdUtenteCliente__c FROM Licenza__c ORDER BY Name][0];
        System.assertEquals('USER_0001_Edit',l.IdUtenteCliente__c);
    }

    @IsTest
    static void LicenseUpdateKoInputList(){

        Test.startTest();
        API_INBOUND_LicenseUpdate.UpdateLicenseWrapperResponse res = API_INBOUND_LicenseUpdate.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            new List<API_INBOUND_LicenseUpdate.LicenseWrapperRequest>()
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E003',res.error.errorCode);
        System.assertEquals(0,res.licenses.size());
    }

    @IsTest
    static void LicenseUpdateKoInputLicense(){

        Test.startTest();
        API_INBOUND_LicenseUpdate.UpdateLicenseWrapperResponse res = API_INBOUND_LicenseUpdate.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            new List<API_INBOUND_LicenseUpdate.LicenseWrapperRequest>{
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest('', 'USER_0001')
            }
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E003',res.error.errorCode);
        System.assertEquals(0,res.licenses.size());
    }

    @IsTest
    static void LicenseUpdateKoAsset(){
        List<Licenza__c> lics = [SELECT Id FROM Licenza__c ORDER BY Name];

        Test.startTest();
        API_INBOUND_LicenseUpdate.UpdateLicenseWrapperResponse res = API_INBOUND_LicenseUpdate.execute(
            'ORG_01',
            'S_0002',
            'PRODUCTION',
            new List<API_INBOUND_LicenseUpdate.LicenseWrapperRequest>{
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[0].Id, 'USER_0001'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[1].Id, 'USER_0002'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[2].Id, 'USER_0003')
            }
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E004',res.error.errorCode);
        System.assertEquals(0,res.licenses.size());
    }

    @IsTest
    static void LicenseUpdateKoNoAllLicenses(){

        Test.startTest();
        API_INBOUND_LicenseUpdate.UpdateLicenseWrapperResponse res = API_INBOUND_LicenseUpdate.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            new List<API_INBOUND_LicenseUpdate.LicenseWrapperRequest>{
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest('NO_ID1', 'USER_0001'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest('NO_ID2', 'USER_0002'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest('NO_ID3', 'USER_0003')
            }
        );
        Test.stopTest();

        System.assertEquals(false,res.success);
        System.assertEquals('E005',res.error.errorCode);
        System.assertEquals(0,res.licenses.size());
    }

    @IsTest
    static void LicenseUpdateKoNo1License(){
        List<Licenza__c> lics = [SELECT Id FROM Licenza__c ORDER BY Name];

        Test.startTest();
        API_INBOUND_LicenseUpdate.UpdateLicenseWrapperResponse res = API_INBOUND_LicenseUpdate.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            new List<API_INBOUND_LicenseUpdate.LicenseWrapperRequest>{
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[0].Id, 'USER_0001'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[1].Id, 'USER_0002'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest('NO_ID3', 'USER_0003')
            }
        );
        Test.stopTest();

        System.assertEquals(true,res.success);
        System.assertEquals(null,res.error);
        System.assertEquals(3,res.licenses.size());
        System.assertEquals('E005',res.licenses[2].error.errorCode);
    }

    @IsTest
    static void LicenseUpdateKoApex(){
        List<Licenza__c> lics = [SELECT Id FROM Licenza__c ORDER BY Name];

        Test.startTest();
        API_INBOUND_LicenseUpdate.UpdateLicenseWrapperResponse res = API_INBOUND_LicenseUpdate.execute(
            'ORG_01',
            'S_0001',
            'PRODUCTION',
            new List<API_INBOUND_LicenseUpdate.LicenseWrapperRequest>{
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[0].Id, 'USER_0001'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[1].Id, 'USER_0002'),
                new API_INBOUND_LicenseUpdate.LicenseWrapperRequest(lics[2].Id, 'USER__0000USER__0000USER__0000USER__0000USER__00001')
            }
        );
        Test.stopTest();

        System.assertEquals(true,res.success);
        System.assertEquals(null,res.error);
        System.assertEquals(3,res.licenses.size());
        System.assertEquals('E010',res.licenses[2].error.errorCode);
    }
    // ----------------- START LICENSES UPDATE TESTS ----------------- //
    
}