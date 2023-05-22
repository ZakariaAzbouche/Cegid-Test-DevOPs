public with sharing class SYS_SessionId_Controller {
    public static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference sessionIdPage = Page.SYS_ApiSessionId;
        // Get the content of the VF page
        String vfContent;

        if(Test.isRunningTest()) {
            vfContent = 'Start'+UserInfo.getSessionId()+'End';
        } else {
            vfContent = sessionIdPage.getContent().toString();
        }

        // Find the position of Start and End
        Integer startPosition = vfContent.indexOf('Start') + 'Start'.length();
        Integer endPosition = vfContent.indexOf('End');
        // Get the Session Id
        sessionId = vfContent.substring(startPosition, endPosition);
        System.debug('sessionId '+sessionId);
        // Return Session Id
        return sessionId;
    }
}