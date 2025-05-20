package com.geulnamu.infrastructure.exception;

import com.geulnamu.global.response.ResponseMessage;
import lombok.Getter;

@Getter
public class NotFoundDataException extends ServerException {

    public NotFoundDataException() {
        super(404, ResponseMessage.NOT_FOUND);
    }

    public NotFoundDataException(String message) {
        super(404, message);
    }
}
