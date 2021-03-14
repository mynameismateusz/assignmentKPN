@IsTest
public class GODISMock {

    public class GODISOrderConfirmSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            return resp;
        }
    }

    public class GODISOrderConfirmFailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(500);
            return resp;
        }
    }

    public class GODISOrderConfirmExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
            throw e;
        }
    }
}
