@IsTest
private class HTTPService_Test {

    final static String ENDPOINT = 'TestEndpoint';
    final static Map<String, String> HEADERS = new Map<String, String>{ 'Key' => 'Val' };
    final static String BODY = '{ "test": "test" }';

    private class HTTP200Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            return resp;
        }
    }

    private class HTTPExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }
    }

    @IsTest
    static void sendRequest_POS() {
        //GIVEN
        Test.setMock(HTTPCalloutMock.class, new HTTPService_Test.HTTP200Mock());
        final String METHOD = 'POST';

        //WHEN
        Test.startTest();
        HTTPResponse res = HTTPService.sendRequest(ENDPOINT, HEADERS, BODY, METHOD);
        Test.stopTest();

        //THEN
        System.assertEquals(res.getStatusCode(), 200, 'Status code should be 200');
    }

    @IsTest
    static void sendRequest_NEG() {
        //GIVEN
        Test.setMock(HTTPCalloutMock.class, new HTTPService_Test.HTTPExceptionMock());
        final String METHOD = 'POST';
        Boolean exceptionThrown = false;

        //WHEN
        Test.startTest();
        try {
        HTTPResponse res = HTTPService.sendRequest(ENDPOINT, null, BODY, METHOD);
        } catch (CalloutException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(true, exceptionThrown, 'Exception should be thrown');
    }
}
