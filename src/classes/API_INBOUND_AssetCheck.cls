@RestResource(urlMapping='/asset/check')
global class API_INBOUND_AssetCheck {

    @HttpPost
    global static CheckSerialWrapperResponse execute(String orgId, String secretKey, String environment) {
        CheckSerialWrapperResponse res = new CheckSerialWrapperResponse();
        if(String.isBlank(orgId) || String.isBlank(secretKey) || String.isBlank(environment)){
            res.setError('E001');
        }
        else{
            List<Asset> assets = [SELECT Id,IdOrgCliente__c,LimiteChiamateMensiliTotali__c,DeltaChiamateMensili__c,ChiamateMensili__c,ChiamateMensiliRimanenti__c,LimiteChiamateSandbox__c,ChiamateEffettuateSandbox__c,ChiamateRimanentiSandbox__c FROM Asset WHERE SerialNumber = :secretKey];
            if(assets != null && !assets.isEmpty() && ( environment == 'SANDBOX' || assets[0].IdOrgCliente__c == orgId )){
                res.setAsset(assets[0], environment);
                if(environment == 'PRODUCTION'){
                    for(Licenza__c l : [SELECT  Id,
                                        IdUtenteCliente__c, 
                                        Contratto__r.Name, 
                                        Contratto__r.DataInizio__c, 
                                        Contratto__r.DataFine__c
                                    FROM Licenza__c 
                                    WHERE Contratto__r.Asset__c = :assets[0].Id AND AttivaCheckbox__c = true]){
                        res.addLicense(l);
                    }
                }
            }
            else{
                res.setError('E004');
            }
        }
        return res;
    }

    global class CheckSerialWrapperResponse {
        global Boolean success {get;set;}
        global API_INBOUND_Utils.ErrorWrapper error {get;set;}
        global AssetWrapper asset {get;set;}
        global List<LicenseWrapper> licenses {get;set;}

        public CheckSerialWrapperResponse(){
            this.success = true;
            this.licenses = new List<LicenseWrapper>();
        }

        public void setAsset(Asset a, String environment){
            Decimal limitCalls = environment == 'PRODUCTION' ? getDecimalValue(a.LimiteChiamateMensiliTotali__c) + getDecimalValue(a.DeltaChiamateMensili__c) : getDecimalValue(a.LimiteChiamateSandbox__c);
            Decimal performedCalls = environment == 'PRODUCTION' ? getDecimalValue(a.ChiamateMensili__c) : getDecimalValue(a.ChiamateEffettuateSandbox__c);
            Decimal availableCalls = environment == 'PRODUCTION' ? getDecimalValue(a.ChiamateMensiliRimanenti__c) : getDecimalValue(a.ChiamateRimanentiSandbox__c);
            this.asset = new AssetWrapper(limitCalls,performedCalls,availableCalls);
        }

        public Decimal getDecimalValue(Decimal value){
            return value != null ? value : 0;
        }

        public void setError(String errorCode){
            this.success = false;
            this.error = new API_INBOUND_Utils.ErrorWrapper(errorCode);
        }

        public void addLicense(Licenza__c license){
            this.licenses.add(new LicenseWrapper(
                                        license.Id,
                                        license.IdUtenteCliente__c,
                                        license.Contratto__r.Name,
                                        license.Contratto__r.DataInizio__c,
                                        license.Contratto__r.DataFine__c)
            );
        }
    }

    global class AssetWrapper {
        global Decimal limitCalls {get;set;}
        global Decimal performedCalls {get;set;}
        global Decimal availableCalls {get;set;}

        public AssetWrapper(Decimal limitCalls, Decimal performedCalls, Decimal availableCalls){
            this.limitCalls = limitCalls;
            this.performedCalls = performedCalls;
            this.availableCalls = availableCalls;
        }
    }

    global class LicenseWrapper {
        global String id {get;set;}
        global String userId {get;set;}
        global String contractName {get;set;}
        global Date contractStartDate {get;set;}
        global Date contractEndDate {get;set;}

        public LicenseWrapper(String id, String userId, String contractName, Date contractStartDate, Date contractEndDate){
            this.id = id;
            this.userId = userId;
            this.contractName = contractName;
            this.contractStartDate = contractStartDate;
            this.contractEndDate = contractEndDate;
        }
    }
}