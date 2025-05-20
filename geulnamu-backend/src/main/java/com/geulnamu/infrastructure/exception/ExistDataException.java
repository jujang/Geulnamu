package com.geulnamu.infrastructure.exception;

import com.geulnamu.global.response.ResponseMessage;

public class ExistDataException extends ServerException {

    public ExistDataException() {
        super(409, ResponseMessage.DUPLICATE_DATA_EXIST);
    }

    public ExistDataException(String message) {
        super(409, message);
    }

}
