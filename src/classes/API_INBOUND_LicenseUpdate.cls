@RestResource(urlMapping='/license/update')
global class API_INBOUND_LicenseUpdate {

    @HttpPost
    global static UpdateLicenseWrapperResponse execute(String orgId, String secretKey, String environment, List<LicenseWrapperRequest> licenses) {
        UpdateLicenseWrapperResponse res = new UpdateLicenseWrapperResponse();
        if(String.isBlank(orgId) || String.isBlank(secretKey) || String.isBlank(environment) || licenses == null || licenses.isEmpty()){
            res.setError('E003');
        }
        else{
            for(LicenseWrapperRequest lwr : licenses){
                if(String.isBlank(lwr.licenseId) || String.isBlank(lwr.userId)){
                    res.setError('E003');
                    break;
                }
            }
            if(res.success){
                List<Asset> assets = [SELECT Id FROM Asset WHERE SerialNumber = :secretKey AND IdOrgCliente__c = :orgId];
                if(assets != null && !assets.isEmpty()){
                    Map<String,String> userByLicenseMap = getUserByLicense(licenses);
                    List<Licenza__c> lis = [SELECT  Id,
                                                    IdUtenteCliente__c
                                                FROM Licenza__c 
                                                WHERE Contratto__r.Asset__c = :assets[0].Id AND Id IN :userByLicenseMap.keyset()
                    ];
                    if(lis != null && !lis.isEmpty()){
                        for(Licenza__c l : lis){
                            l.IdUtenteCliente__c = userByLicenseMap.get(l.Id);
                        }
                        List<String> licenseIdsUpdated = new List<String>();
                        for(Database.SaveResult sr : Database.update(lis,false)){
                            if(sr.isSuccess()){
                                res.addSuccess(sr.getId(),userByLicenseMap.get(sr.getId()));
                            }
                            else{
                                res.addError(sr.getId(),userByLicenseMap.get(sr.getId()),'E010',''+sr.getErrors()[0].getMessage());
                            }
                            licenseIdsUpdated.add(sr.getId());
                        }
                        for(String licenseId : userByLicenseMap.keySet()){
                            if(!licenseIdsUpdated.contains(licenseId)){
                                res.addError(licenseId,userByLicenseMap.get(licenseId),'E005');
                            }
                        }
                    }
                    else{
                        res.setError('E005');
                    }
                }
                else{
                    res.setError('E004');
                }
            }
        }
        return res;
    }

    public static Map<String,String> getUserByLicense(List<LicenseWrapperRequest> licenses){
        Map<String,String> newMap = new Map<String,String>();
        for(LicenseWrapperRequest lwr : licenses){
            newMap.put(lwr.licenseId,lwr.userId);
        }
        return newMap;
    }

    global class LicenseWrapperRequest {
        global String licenseId { get; set; }
        global String userId { get; set; }

        public LicenseWrapperRequest(String licenseId, String userId){
            this.licenseId = licenseId;
            this.userId = userId;
        }
    }

    global class UpdateLicenseWrapperResponse {
        global Boolean success {get;set;}
        global API_INBOUND_Utils.ErrorWrapper error { get;set; }
        global List<LicenseWrapperResponse> licenses { get;set; }

        public UpdateLicenseWrapperResponse(){
            this.success = true;
            this.licenses = new List<LicenseWrapperResponse>();
        }

        public void setError(String errorCode){
            this.success = false;
            this.error = new API_INBOUND_Utils.ErrorWrapper(errorCode);
        }

        public void addError(String licenseId, String userId, String errorCode){
            this.licenses.add(new LicenseWrapperResponse(
                licenseId,
                userId,
                errorCode
            ));
        }

        public void addError(String licenseId, String userId, String errorCode, String errorMessage){
            this.licenses.add(new LicenseWrapperResponse(
                licenseId,
                userId,
                errorCode,
                errorMessage
            ));
        }

        public void addSuccess(String licenseId, String userId){
            this.licenses.add(new LicenseWrapperResponse(
                licenseId,
                userId
            ));
        }
    }

    global class LicenseWrapperResponse {
        global String licenseId { get; set; }
        global String userId { get; set; }
        global Boolean success {get;set;}
        global API_INBOUND_Utils.ErrorWrapper error { get;set; }

        public LicenseWrapperResponse(String licenseId, String userId){
            this.licenseId = licenseId;
            this.userId = userId;
            this.success = true;
        }

        public LicenseWrapperResponse(String licenseId, String userId, String errorCode){
            this.licenseId = licenseId;
            this.userId = userId;
            this.setError(errorCode);
        }

        public LicenseWrapperResponse(String licenseId, String userId, String errorCode, String errorMessage){
            this.licenseId = licenseId;
            this.userId = userId;
            this.setError(errorCode, errorMessage);
        }

        public void setError(String errorCode){
            this.success = false;
            this.error = new API_INBOUND_Utils.ErrorWrapper(errorCode);
        }

        public void setError(String errorCode, String errorMessage){
            this.success = false;
            this.error = new API_INBOUND_Utils.ErrorWrapper(errorCode, errorMessage);
        }
    }
}