package com.geulnamu.infrastructure.exception;

import lombok.Getter;

@Getter
public class ServerException extends RuntimeException{

    private final int code;
    private final String message;
    private final String field;

    public ServerException(int code, String message) {
        super(message); // Runtime에 보내주기
        this.code = code;
        this.message = message;
        this.field = null;
    }

    public ServerException(int code, String message, String field) {
        super(message);
        this.code = code;
        this.message = message;
        this.field = field;
    }
}
