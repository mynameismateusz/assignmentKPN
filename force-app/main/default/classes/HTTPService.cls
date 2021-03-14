public with sharing class HTTPService {

    public static HttpResponse sendRequest(String endpoint, Map<String, String> headers, String body, String method) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        if (headers != null) {
            for (String key : headers.keySet()) {
                request.setHeader(key, headers.get(key));
            }
        }
        request.setBody(body);
        request.setMethod(method);
        HttpResponse response = http.send(request);
        return response;
    }
}
