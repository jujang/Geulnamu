package com.geulnamu.infrastructure.exception;

import com.geulnamu.global.response.ResponseMessage;

public class ExistDataException extends ServerException {

    public ExistDataException() {
        super(422, ResponseMessage.NO_CHANGE_DETECTED);
    }

    public ExistDataException(String message) {
        super(409, message);
    }

}
