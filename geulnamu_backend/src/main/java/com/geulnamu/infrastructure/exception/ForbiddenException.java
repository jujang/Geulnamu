package com.geulnamu.infrastructure.exception;

import com.geulnamu.infrastructure.response.ResponseMessage;

public class ForbiddenException extends ServerException{

    public ForbiddenException() {
        super(403, ResponseMessage.FORBIDDEN);
    }

    public ForbiddenException(String message) {
        super(403, message);
    }

    public ForbiddenException(String message, String field) {
        super(403, message, field);
    }
}
