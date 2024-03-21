global class API_INBOUND_Utils {

    private static Map<String,String> errorMessageByCodeMap = new Map<String,String>{
        'E001' => 'Org Id or Secret Key or Environment not provided',
        'E002' => 'Org Id or Secret Key or Environment or User Id not provided',
        'E003' => 'Org Id or Secret Key or Environment or User Id or License Id not provided',
        'E004' => 'Asset not found',
        'E005' => 'License not found',
        'E006' => 'License inactive',
        'E007' => 'Limit exceeded',
        'E010' => 'APEX'
    };

    private static String getErroreByCode(String errorCode){
        return errorMessageByCodeMap.get(errorCode);
    }

    global class ErrorWrapper {
        global String errorCode {get;set;}
        global String errorMessage {get;set;}

        public ErrorWrapper(String errorCode){
            this.errorCode = errorCode;
            this.errorMessage = getErroreByCode(errorCode);
        }

        public ErrorWrapper(String errorCode, String errorMessage){
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }
    }
}