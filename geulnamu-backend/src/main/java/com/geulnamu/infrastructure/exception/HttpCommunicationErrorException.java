package com.geulnamu.infrastructure.exception;

public class HttpCommunicationErrorException extends ServerException {

    public HttpCommunicationErrorException(String message) {
        super(400, message);
    }

    public HttpCommunicationErrorException(String message, String field) {
        super(400, message, field);
    }
}
