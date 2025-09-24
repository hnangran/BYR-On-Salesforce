@IsTest
private class BYROS_ResumePDFControllerTest {
    @IsTest static void canConstructWithNullId() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', null);
        BYROS_ResumePdfController c = new BYROS_ResumePdfController();
        Test.stopTest();
        System.assertNotEquals(null, c.resumeDetails, 'details should be initialized');
    }
}