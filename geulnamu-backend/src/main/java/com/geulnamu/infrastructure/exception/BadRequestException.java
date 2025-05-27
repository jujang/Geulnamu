package com.geulnamu.infrastructure.exception;

public class BadRequestException extends ServerException {

    public BadRequestException(String message) {
        super(400, message);
    }

    public BadRequestException(String message, String field) {
        super(400, message, field);
    }
}
