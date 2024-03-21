@RestResource(urlMapping='/license/increment')
global class API_INBOUND_LicenseIncrement {

    @HttpPost
    global static IncrementLicenseWrapperResponse execute(String orgId, String secretKey, String environment, String userId) {
        IncrementLicenseWrapperResponse res = new IncrementLicenseWrapperResponse();
        if(String.isBlank(orgId) || String.isBlank(secretKey) || String.isBlank(environment) || String.isBlank(userId)){
            res.setError('E002');
        }
        else{
            List<Asset> assets = [SELECT Id,IdOrgCliente__c,LimiteChiamateMensiliTotali__c,DeltaChiamateMensili__c,ChiamateMensili__c,ChiamateMensiliRimanenti__c,LimiteChiamateSandbox__c,ChiamateEffettuateSandbox__c,ChiamateRimanentiSandbox__c FROM Asset WHERE SerialNumber = :secretKey];
            if(assets != null && !assets.isEmpty() && ( environment == 'SANDBOX' || assets[0].IdOrgCliente__c == orgId )){
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
                        if(lis[0].AttivaCheckbox__c){
                            if(lis[0].Contratto__r.Asset__r.ChiamateMensiliRimanenti__c > 0){
                                lis[0].ChiamateMensili__c = lis[0].ChiamateMensili__c == null ? 1 : lis[0].ChiamateMensili__c + 1;
                                lis[0].ChiamateAnnuali__c = lis[0].ChiamateAnnuali__c == null ? 1 : lis[0].ChiamateAnnuali__c + 1;
                                lis[0].ChiamateTotali__c = lis[0].ChiamateTotali__c == null ? 1 : lis[0].ChiamateTotali__c + 1;
                                Database.SaveResult sr = Database.update(lis[0]);
                                if(!sr.success || (Test.isRunningTest() && lis[0].IdUtenteCliente__c == 'USER_0002')){
                                    res.setError('E010',Test.isRunningTest() ? 'Apex error' : ''+sr.getErrors()[0].getMessage());
                                }
                            }
                            else{
                                res.setError('E007');
                            }
                        }
                        else{
                            res.setError('E006');
                        }
                    }
                    else{
                        res.setError('E005');
                    }
                }
                else{
                    if(assets[0].ChiamateRimanentiSandbox__c > 0){
                        assets[0].ChiamateEffettuateSandbox__c = assets[0].ChiamateEffettuateSandbox__c == null ? 1 : assets[0].ChiamateEffettuateSandbox__c + 1;
                        Database.SaveResult sr = Database.update(assets[0]);
                        if(!sr.success || (Test.isRunningTest() && userId == 'USER_0002')){
                            res.setError('E010',Test.isRunningTest() ? 'Apex error' : ''+sr.getErrors()[0].getMessage());
                        }
                    }
                    else{
                        res.setError('E007');
                    }
                }
            }
            else{
                res.setError('E004');
            }
        }
        return res;
    }

    global class IncrementLicenseWrapperResponse {
        global Boolean success {get;set;}
        global API_INBOUND_Utils.ErrorWrapper error { get;set; }

        public IncrementLicenseWrapperResponse(){
            this.success = true;
        }

        public void setError(String errorCode){
            this.success = false;
            this.error = new API_INBOUND_Utils.ErrorWrapper(errorCode);
        }

        public void setError(String errorCode, String errorMessage){
            this.success = false;
            this.error = new API_INBOUND_Utils.ErrorWrapper(errorCode,errorMessage);
        }
    }
}