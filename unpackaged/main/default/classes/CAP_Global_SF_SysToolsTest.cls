@isTest(SeeAllData=true)
public with sharing class CAP_Global_SF_SysToolsTest {

    public class ToolingAPI implements HttpCalloutMock{
        
        public HttpResponse respond(HttpRequest req) {
            
            HttpResponse res = new HttpResponse();

            System.debug('req = ' + req.getEndpoint()+' '+req.getMethod());
            String reqMethod = req.getMethod();
            String reqEndpoint = req.getEndpoint();
            res.setStatusCode(200);
            res.setBody('{"size":2,"totalSize":2,"done":true,"queryLocator":null,"entityTypeName":"ProfileLayout","records":[{"attributes":{"type":"ProfileLayout","url":"/services/data/v52.0/tooling/sobjects/ProfileLayout/01G0D000004oK8YUAU"},"Layout":{"attributes":{"type":"Layout","url":"/services/data/v52.0/tooling/sobjects/Layout/00h0D000000O0evQAC"},"Name":"Dummy Layout","TableEnumOrId":"Account"},"ProfileId":"00e58000000VRRVAA4","Profile":{"attributes":{"type":"Profile","url":"/services/data/v52.0/tooling/sobjects/Profile/00e58000000VRRVAA4"},"Name":"System Administrator"},"RecordTypeId":"0120D0000004mU7QAI"},{"attributes":{"type":"ProfileLayout","url":"/services/data/v52.0/tooling/sobjects/ProfileLayout/01G0D000004obdeUAA"},"Layout":{"attributes":{"type":"Layout","url":"/services/data/v52.0/tooling/sobjects/Layout/00h58000000YwbAAAS"},"Name":"Fermer la présentation de requête","TableEnumOrId":"CaseClose"},"ProfileId":"00e58000000VRRVAA4","Profile":{"attributes":{"type":"Profile","url":"/services/data/v52.0/tooling/sobjects/Profile/00e58000000VRRVAA4"},"Name":"System Administrator"},"RecordTypeId":"0120D0000004mU7QAI"}]}');

            return res;
        }
    }

    @isTest
    public static void getAllSObjectRecordType(){
        System.assert(CAP_Global_SF_SysTools.getAllSObjectRecordType('Account') != null);
    }

    @isTest
    public static void getProfileLanguage(){
        System.assert(CAP_Global_SF_SysTools.getProfileLanguage() != null);
    }

    @isTest
    public static void getRecordTypeIdByProfile(){
        System.assert(CAP_Global_SF_SysTools.getRecordTypeIdByProfile('Account') != null);
    }
    
    @isTest
    public static void returnSchemaTest() {
        List<Map<String, Object>> lstSchema = CAP_Global_SF_SysTools.returnSchema();
        System.assert(lstSchema.size() > 0);
    }

    @isTest 
    public static void getSObjectFieldsTest() {
        List<Map<String, Object>> lstFields = CAP_Global_SF_SysTools.getSObjectFields('Account', true);
        System.debug(CAP_Global_SF_SysTools.getPicklistFields('Account'));
        System.assert(lstFields.size() > 0);
    }

    @isTest
    public static void getFieldsFromLayoutWithRtypeAndProfileTest() {   
        String[] profiLisList = new String[] {'Administrateur système', 'System Administrator'};

        //Get a profile to create User
        Profile p = [select id from profile where name in:profiLisList limit 1];
        
        String testemail2 = 'assistant_-_User_test@test.com';
        
        User director = new User(profileId = p.id, username = testemail2, email = testemail2,
                                 emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                                 languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                                 alias='cspu', lastname='lastname', IsActive=true);

        System.runAs(director){

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ToolingAPI());
            String lstFieldsNoSection = CAP_Global_SF_SysTools.getFieldsFromLayoutWithRtypeAndProfile([SELECT Id FROM RecordType WHERE DeveloperName = 'DummyRType' LIMIT 1][0].Id, false);
            System.assert(lstFieldsNoSection != null);
            String lstFieldsSection = CAP_Global_SF_SysTools.getFieldsFromLayoutWithRtypeAndProfile([SELECT Id FROM RecordType WHERE DeveloperName = 'DummyRType' LIMIT 1][0].Id, true);
            System.assert(lstFieldsSection != null);
            Test.stopTest();

        }
    }

    @isTest
    public static void testUploadAndDelete() {

        Contact ct = new Contact(LastName = 'Test Contact', FirstName = 'Test', Email = 'test@Test.com', Phone= '0606060606');
        Account acc = new Account(Name = 'Test Fact Acc');
        
        //Quote Section
        Opportunity opp = new Opportunity(Name= 'Test Opp', StageName = 'En cours', CloseDate = Date.today().addDays(10), AccountId = acc.Id);
        insert opp;

        String upload = CAP_Global_SF_SysTools.uploadFile(EncodingUtil.base64Encode(Blob.valueOf('Test Content Data')), 'Test.jpg', opp.Id, UserInfo.getUserId());
        System.assert(upload != null);

        CAP_Global_SF_SysTools.deleteBySingleId(opp.Id);
        
    }
    
    @isTest
    public static void getUrl() {
        System.assertNotEquals(null, CAP_Global_SF_SysTools.getUrl());
    }
    
    @isTest
    public static void getObjectApiName() {
        System.assertEquals('Account', CAP_Global_SF_SysTools.getObjectApiName([SELECT Id FROM Account LIMIT 1].Id));
    }
    
    @isTest
    public static void getRecordTypeId() {
        System.assertNotEquals(null, CAP_Global_SF_SysTools.getRecordTypeId('DummyRType'));
    }    
}