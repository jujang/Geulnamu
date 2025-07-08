package com.geulnamu.infrastructure.exception;

public class TokenException extends ServerException {

    public TokenException(String message) {
        super(401, message);
    }
}
