@RestResource(urlMapping='/license/check')
global class API_INBOUND_LicenseCheck {

    @HttpPost
    global static CheckLicenseWrapperResponse execute(String orgId, String secretKey, String environment, String userId) {
        CheckLicenseWrapperResponse res = new CheckLicenseWrapperResponse();
        if(String.isBlank(orgId) || String.isBlank(secretKey) || String.isBlank(environment) || String.isBlank(userId)){
            res.setError('E002');
        }
        else{
            List<Asset> assets = [SELECT Id,IdOrgCliente__c,LimiteChiamateMensiliTotali__c,DeltaChiamateMensili__c,ChiamateMensili__c,ChiamateMensiliRimanenti__c,LimiteChiamateSandbox__c,ChiamateEffettuateSandbox__c,ChiamateRimanentiSandbox__c FROM Asset WHERE SerialNumber = :secretKey];
            if(assets != null && !assets.isEmpty() && ( environment == 'SANDBOX' || assets[0].IdOrgCliente__c == orgId )){
                res.setAsset(assets[0], environment);
                if(res.asset.availableCalls <= 0){
                    res.setError('E007');
                    res.asset = null;
                }
                else{
                    if(environment == 'PRODUCTION'){
                        List<Licenza__c> lis = [SELECT  Id,
                                                        IdUtenteCliente__c, 
                                                        AttivaCheckbox__c,
                                                        ChiamateMensili__c,
                                                        ChiamateAnnuali__c,
                                                        ChiamateTotali__c,
                                                        Contratto__r.Asset__r.ChiamateMensiliRimanenti__c
                                                    FROM Licenza__c 
                                                    WHERE Contratto__r.Asset__c = :assets[0].Id AND IdUtenteCliente__c = :userId
                        ];
                        if(lis != null && !lis.isEmpty()){
                            if(!lis[0].AttivaCheckbox__c){
                                res.setError('E006');
                            }
                        }
                        else{
                            res.setError('E005');
                        }
                    }
                }
            }
            else{
                res.setError('E004');
            }
        }
        return res;
    }

    global class CheckLicenseWrapperResponse {
        global Boolean success {get;set;}
        global API_INBOUND_Utils.ErrorWrapper error { get;set; }
        global AssetWrapper asset {get;set;}

        public CheckLicenseWrapperResponse(){
            this.success = true;
        }

        public void setError(String errorCode){
            this.success = false;
            this.error = new API_INBOUND_Utils.ErrorWrapper(errorCode);
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

}