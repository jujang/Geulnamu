package com.geulnamu.global.response;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor(staticName = "of")
public class BaseResponse {

    private final int code;
    private final String message;
    private final Object Data;

    // success default response
    public static BaseResponse ofSuccess() {
        return new BaseResponse(200, ResponseMessage.SUCCESS, null);
    }

    // success response with data
    public static BaseResponse ofSuccess(Object data) {
        return new BaseResponse(200, ResponseMessage.SUCCESS, data);
    }

    // success response with message and data
    public static BaseResponse ofSuccess(String message, Object data) {
        return new BaseResponse(200, message, data);
    }


    // fail default response with a message
    public static BaseResponse ofFail(HttpStatus httpStatus, String message) {
        return new BaseResponse(httpStatus.value(), message, null);
    }

    // fail default response with httpStatus and message and data
    public static BaseResponse ofFail(int code, String message, Object data) {
        return new BaseResponse(code, message, data);
    }

//    // fail default response with httpStatus and message and data
//    public static BaseResponse ofFail(HttpStatus httpStatus, String message, Object data) {
//        return new BaseResponse(httpStatus.value(), message, data);
//    }

}
