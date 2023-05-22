/*
Class for all system methods to get data
*/
global without sharing class CAP_Global_SF_SysTools {
    
    @AuraEnabled
    public static string getUrl(){
        return System.URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    @AuraEnabled
    public static Object getRecordTypeId(String name){
        try {
            return [SELECT Id FROM RecordType WHERE DeveloperName = :name OR Name = :name].Id;
        } catch (Exception e) {
            System.debug(e.getMessage()+' '+e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<Id> getRecordTypeIdByProfile(String sObjectType){
        try {
            List<Id> recordTypes = new List<Id>();
            for(RecordTypeInfo info: Schema.getGlobalDescribe().get(sObjectType).getDescribe().SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable()) {
                    recordTypes.add(info.getRecordTypeId());
                }
            }
            System.debug(recordTypes);
            return recordTypes;
        } catch (Exception e) {
            System.debug(e.getMessage()+' '+e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static String getObjectApiName(Id recordId) {
        return recordId.getSobjectType().getDescribe().getName();
    }

    @AuraEnabled
    public static List<Map<String, Object>> returnSchema(){
        try {
            List<Map<String, Object>> lstSettings = new List<Map<String, Object>>();
            for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() )
            {
                Schema.DescribeSObjectResult objResult = o.getDescribe();
                if(!objResult.getName().containsignorecase('history') && !objResult.getName().containsignorecase('tag') &&
                    !objResult.getName().containsignorecase('share') && !objResult.getName().containsignorecase('feed') && 
                    !objResult.getName().containsignorecase('group') && !objResult.getName().containsignorecase('public') &&
                    !objResult.isCustomSetting() && objResult.isCreateable()) {
                        lstSettings.add(new Map<String, Object>{
                            'id' => objResult.getName(),
                            'label' => objResult.getLabel(),
                            'value' => objResult.getName(),
                            'type'=> objResult.getName(),
                            'icon' => (objResult.isCustom()) ? 'utility:sobject' : 'utility:standard_objects',
                            'selected' => false
                        });   
                }
            }
            System.debug(lstSettings);
            return lstSettings;
        } catch (Exception e) {
            System.debug(e.getMessage()+' '+e.getLineNumber());
            return null;
        }
    }

    public static Map<String, List<Map<String, String>>> getDependentPicklistValues(Schema.sObjectField dependToken) {

        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<Map<String, String>>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/-,_éèçà&';
        Map<String, List<Map<String, String>>> dependentPicklistValues = new Map<String, List<Map<String, String>>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<Map<String, String>>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(new Map<String, String>{'label' => entry.getLabel(), 'value' => entry.getValue()});
                }
            }
        }
        return dependentPicklistValues;
    }

    @AuraEnabled
    public static List<Map<String,Object>> getSObjectFields(String sobjectName, Boolean withRef){
        try {
            List<Map<String, Object>> lstFields = new List<Map<String, Object>>();
            for (Schema.SObjectField field : System.Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().values()) {
                String fieldType = String.valueOf(field.getDescribe().getType());
                List<Map<String, String>> values = new List<Map<String, String>>();
                if(fieldType.containsignorecase('picklist')) {
                    for(Schema.PicklistEntry picklistChoice: field.getDescribe().getPicklistValues()) {
                        values.add(new Map<String, String>{
                            'value' => picklistChoice.getValue(),
                            'label' => picklistChoice.getLabel()
                        });
                    }
                }
                Boolean dependant = false;
                Map<String, List<Map<String, String>>> controlledValues;
                if(field.getDescribe().getController() != null) {
                    dependant = true;
                    controlledValues = getDependentPicklistValues(field);
                }

                String inputType = fieldInputType(fieldType);
                
                Map<String, String> referenceApiName = new Map<String, String>();
                if(withRef) {
                    if(field.getDescribe().getReferenceTo() != null && field.getDescribe().getReferenceTo().size() > 0) {
                        for(Schema.SObjectType  obj: field.getDescribe().getReferenceTo()) {
                            referenceApiName.put('value',obj.getDescribe().getName());
                            referenceApiName.put('label',obj.getDescribe().getLabel());
                        }
                    }
                }

                List<Map<String, String>> lstValues = new List<Map<String, String>>();
                if(field.getDescribe().getPicklistValues() != null && field.getDescribe().getPicklistValues().size() > 0) {
                    for(Schema.PicklistEntry ple: field.getDescribe().getPicklistValues()) {
                        lstValues.add(new Map<String, String>{'label' => ple.getLabel(), 'value' => ple.getValue()});
                    }
                }

                lstFields.add(new Map<String, Object>{
                    'id' => field.getDescribe().getName(),
                    'label' => field.getDescribe().getLabel(),
                    'value' => field.getDescribe().getName(),
                    'objectType' => sobjectName,
                    'type' => inputType,
                    'numberOnly' => (fieldType.containsignorecase('integer') || 
                                    fieldType.containsignorecase('double') || 
                                    fieldType.containsignorecase('long') || 
                                    fieldType.containsignorecase('currency') || 
                                    fieldType.containsignorecase('phone')) ? true : false,
                    'controlled' => dependant,
                    'controllingField' => (dependant) ? field.getDescribe().getController().getDescribe().getName() : null,
                    'controllingValues' => controlledValues,
                    'options' => values,
                    'edit' => false,
                    'editable' => false,
                    'icon' => 'utility:insert_tag_field',
                    'selected' => false,
                    'references' => (withRef) ? referenceApiName : null,
                    'picklistValues' => lstValues
                });
            }
            return lstFields;
        } catch (Exception e) {
            System.debug(e.getMessage()+'at line '+e.getLineNumber());
            return null;
        }
    }

    private static string fieldInputType(String SF_TYPE) {
        switch on SF_TYPE.toLowerCase() {
            when 'percent', 'long', 'integer', 'double', 'currency' {
                return 'number';
            }
            when 'combobox', 'multipicklist', 'picklist' {
                return 'picklist';
            }
            when 'dateTime' {
                return 'dateTime';
            }
            when 'date' {
                return 'date';
            }
            when 'textarea' {
                return 'textArea';
            }
            when 'phone' {
                return 'phone';
            }
            when 'boolean' {
                return 'checkbox';
            }
            when 'email' {
                return 'email';
            }
            when 'reference' {
                return 'reference';
            }
            when else {
                return 'text';
            }
        }
    }

    @AuraEnabled
    public static String retrieveFieldsFromLayout(String layoutName, Boolean hasSections) {
        try {

            System.debug(layoutName);

            if(hasSections) {

                List<Map<String, Object>> lstSections = new List<Map<String, Object>>();
                
                List<Metadata.Metadata> layouts = 
                Metadata.Operations.retrieve(Metadata.MetadataType.Layout, 
                new List<String> {layoutName});
                
                Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
                for(Metadata.LayoutSection section : layoutMd.layoutSections) {
                    Integer colIndex = 0;
                    List<Map<String, Object>> lstColumns = new List<Map<String, Object>>();
                    for (Metadata.LayoutColumn column : section.layoutColumns) {
                        Boolean areAllFieldsNull = true;
                        List<Map<String, Object>> lstFields = new List<Map<String, Object>>();
                        colIndex++;
                        if (column.layoutItems != null) {
                            for (Metadata.LayoutItem item : column.layoutItems) {
                                if(item.field != null) {
                                    areAllFieldsNull = false;
                                }
                                if(item.behavior != null && String.valueOf(item.behavior) != 'Readonly') {
                                    lstFields.add(new Map<String, Object>{'label' => Schema.getGlobalDescribe().get(layoutName.SubStringBefore('-')).getDescribe().fields.getMap().get(item.field).getDescribe().getLabel(),
                                                                          'name' => item.field,
                                                                          'required' => (String.valueOf(item.behavior) == 'Required') ? true : false,
                                                                          'value' => '',
                                                                          'addressType' => (String.valueOf(Schema.getGlobalDescribe().get(layoutName.SubStringBefore('-')).getDescribe().fields.getMap().get(item.field).getDescribe().getType()) == 'ADDRESS') ? true : false });
                                }
                            }
                        }
                        if(!areAllFieldsNull) {
                            lstColumns.add(new Map<String, Object>{'index' => colIndex,
                                                                   'fields' => lstFields});
                        }
                    }
                    if(lstColumns.size() > 0) {
                        lstSections.add(new Map<String, Object>{'sectionName' => section.label.replace(' ', '_'),
                                                            'sectionLabel' => section.label,
                                                            'columns' => lstColumns});
                    }
                }
                return JSON.serialize(lstSections);

            } else {

                List<Map<String, Object>> lstFields = new List<Map<String, Object>>();

                List<Metadata.Metadata> layouts = 
                Metadata.Operations.retrieve(Metadata.MetadataType.Layout, 
                                            new List<String> {layoutName});
                System.debug(JSON.serialize(layouts));
                Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
                for(Metadata.LayoutSection section : layoutMd.layoutSections) {
                    for (Metadata.LayoutColumn column : section.layoutColumns) {
                        if (column.layoutItems != null) {
                            for (Metadata.LayoutItem item : column.layoutItems) {
                                if(item.behavior != null && String.valueOf(item.behavior) != 'Readonly') {
                                    System.debug(item.field);
                                    lstFields.add(new Map<String, Object>{'label' => Schema.getGlobalDescribe().get(layoutName.SubStringBefore('-')).getDescribe().fields.getMap().get(item.field).getDescribe().getLabel(),
                                                                        'name' => item.field,
                                                                        'required' => (String.valueOf(item.behavior) == 'Required') ? true : false,
                                                                        'value' => '',
                                                                        'addressType' => (String.valueOf(Schema.getGlobalDescribe().get(layoutName.SubStringBefore('-')).getDescribe().fields.getMap().get(item.field).getDescribe().getType()) == 'ADDRESS') ? true : false });
                                }
                            }
                        }
                    }
                }
                return JSON.serialize(lstFields);

            }

        } catch(Exception e) {
            System.debug(e.getMessage()+' at '+e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static Map<String, String> getLayoutByProfileAndRecordType(String recordTypeId) {
        String layoutId;
        String baseURL = Url.getOrgDomainUrl().toExternalForm();
        String profileId = UserInfo.getProfileId();
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + SYS_SessionId_Controller.fetchUserSessionId());
        
        req.setHeader('Content-Type', 'application/json');
        
        req.setEndpoint('callout:CAP_SF_ToolingAPI_NCred?q=SELECT+Layout.Name,Layout.TableEnumOrId,ProfileId,Profile.Name,RecordTypeId+FROM+ProfileLayout+WHERE+recordTypeId=\'' + recordTypeId + '\'AND+profileId=\'' + profileId + '\'');
        req.setMethod('GET'); 
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug(res.getBody());
        
        Map<String,Object> responseProfileLayout = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        List<Object> objList = (List<Object>)responseProfileLayout.get('records');

        Map<String,Object> objMap = (Map<String,Object>)objList[0];
        Map<String,Object> layout = (Map<String,Object>)objMap.get('Layout');
        Map<String,Object> responseAttributes = (Map<String, Object>)layout.get('attributes');
        String layoutURL = (String)responseAttributes.get('url');
        String layoutName = (String)layout.get('Name');
        Map<String, String> results = new Map<String, String>{'layoutId' => layoutURL.substringAfterLast('/'),
                                                              'layoutName' => (String)layout.get('TableEnumOrId')+'-'+layoutName};
        return results;

    }

    @AuraEnabled
    public static String getFieldsFromLayoutWithRtypeAndProfile(String recordTypeId, Boolean hasSections){
        try {
            Id rTypeId = (recordTypeId instanceOf Id) ? recordTypeId : [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeId OR Name = :recordTypeId LIMIT 1].Id;
            String layoutName = getLayoutByProfileAndRecordType(rTypeId).get('layoutName');
            return retrieveFieldsFromLayout(layoutName, hasSections);
        } catch (Exception e) {
            System.debug(e.getMessage()+' '+e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static String getAllSObjectRecordType(String sObjectType){
        try {
            return JSON.serialize([SELECT Id, DeveloperName, Name, IsActive FROM RecordType WHERE SobjectType = :sObjectType]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId, String ownerId){
        try {
            FileUploaderClass fupc = new FileUploaderClass();
            return fupc.uploadFile(base64, filename, recordId, ownerId);
        } catch(Exception ex) {
            System.debug(ex.getMessage()+' '+ex.getLineNumber());
            return null;
        }
    }

    public without sharing class FileUploaderClass {
        /*
        * @method uploadFile() 
        * @desc Creates a content version from a given file's base64 and name
        * 
        * @param {String} base64 - base64 string that represents the file
        * @param {String} filename - full file name with extension, i.e. 'products.csv'
        * @param {String} recordId - Id of the record you want to attach this file to
        * 
        * @return {ContentVersion} - returns the created ContentDocumentLink Id if the
        *   upload was successful, otherwise returns null
        */
        public String uploadFile(String base64, String filename, String recordId, String ownerId) {
            ContentVersion cv = createContentVersion(base64, filename, ownerId);
            ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
            if (cv == null || cdl == null) { return null; }
            return cdl.Id;
        }
        /*
        * @method createContentVersion() [private]
        * @desc Creates a content version from a given file's base64 and name
        * 
        * @param {String} base64 - base64 string that represents the file
        * @param {String} filename - full file name with extension, i.e. 'products.csv'
        * 
        * @return {ContentVersion} - returns the newly created ContentVersion, or null
        *   if there was an error inserting the record
        */
        private ContentVersion createContentVersion(String base64, String filename, String ownerId) {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64);
            cv.Title = filename;
            cv.PathOnClient = filename;
            try {
                insert cv;
                return cv;
            } catch(DMLException e) {
                System.debug(e);
                return null;
            }
        }
    
        /*
        * @method createContentLink() [private]
        * @desc Creates a content link for a given ContentVersion and record
        * 
        * @param {String} contentVersionId - Id of the ContentVersion of the file
        * @param {String} recordId - Id of the record you want to attach this file to
        * 
        * @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
        *   or null if there was an error inserting the record
        */
        private ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
            if (contentVersionId == null || recordId == null) { return null; }
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id =: contentVersionId
            ].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            // ShareType is either 'V', 'C', or 'I'
            // V = Viewer, C = Collaborator, I = Inferred
            cdl.ShareType = 'V';
            try {
                insert cdl;
                return cdl;
            } catch(DMLException e) {
                System.debug(e);        
                return null;
            }
        }
    }

    @AuraEnabled
    public static Boolean deleteBySingleId(Id recordId){
        try {

            Database.DeleteResult dr = Database.delete(recordId, false);

            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted record with ID: ' + dr.getId());
                return true;
            } else {
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Record fields that affected this error: ' + err.getFields());
                }
            }

            return false;

        } catch(Exception ex) {
            System.debug(ex.getMessage()+' '+ex.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static string getProfileLanguage(){
        try {
            return (UserInfo.getUserType() != 'Guest') ? UserInfo.getLanguage() : null;
        } catch (Exception e) {
            System.debug(e.getMessage()+' '+e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<Object> getPicklistFields(String lookUpReference){
        try {

            List<Object> lst = new List<Object>();

            for(Schema.SObjectField fld: (List<Schema.SObjectField>) fieldsOf(lookUpReference, false)) {
                List<Schema.PicklistEntry> ples = new List<Schema.PicklistEntry>();
                ples = fld.getDescribe().getPicklistValues();
                if(ples.size() > 1) {
                    List<Map<String, String>> values = new List<Map<String, String>>();
                    Map<String, Object> mp = new Map<String, Object>();
                    for(PicklistEntry ple: ples) {
                        values.add(new Map<String, String>{'label' => ple.getLabel(), 'value' => ple.getValue()});
                    }
                    mp.put('field', fld.getDescribe().getLabel());
                    mp.put('apiName', fld.getDescribe().getName());
                    mp.put('picklist', values);
                    lst.add(mp);
                }
            }

            return lst;

        } catch (Exception e) {
            System.debug(e.getMessage()+' at '+e.getLineNumber());
            return null;
        }
    }

    public static Object fieldsOf(String SObjectName, Boolean keySets) {
        if(keySets) {
            return new List<String>(System.Schema.getGlobalDescribe().get(SObjectName).getDescribe().fields.getMap().keySet());
        }
        
        return System.Schema.getGlobalDescribe().get(SObjectName).getDescribe().fields.getMap().values();
    }
}