package com.geulnamu.infrastructure.response;

import com.geulnamu.infrastructure.util.JsonUtils;
import jakarta.servlet.http.HttpServletResponse;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

import java.io.IOException;

@Getter
@RequiredArgsConstructor(staticName = "of")
public class BaseResponse<D> {

    private final int code;
    private final String message;
    private final D data;

    // success default response
    public static BaseResponse<Void> ofSuccess() {
        return new BaseResponse<>(200, ResponseMessage.SUCCESS, null);
    }

    // success response with data
    public static <D> BaseResponse<D> ofSuccess(D data) {
        return new BaseResponse<>(200, ResponseMessage.SUCCESS, data);
    }

    // success response with message and data
    public static <D> BaseResponse<D> ofSuccess(String message, D data) {
        return new BaseResponse<>(200, message, data);
    }


    // fail default response with a message
    public static BaseResponse<Void> ofFail(HttpStatus httpStatus, String message) {
        return new BaseResponse<>(httpStatus.value(), message, null);
    }

//    public static BaseResponse ofFail(HttpStatus httpStatus, String message, Object data) {
//        return new BaseResponse(httpStatus.value(), message, data);
//    }

    // fail default response with httpStatus and message and data
    public static <D> BaseResponse<D> ofFail(int code, String message, D data) {
        return new BaseResponse<>(code, message, data);
    }

//    // fail default response with httpStatus and message and data
//    public static BaseResponse ofFail(HttpStatus httpStatus, String message, Object data) {
//        return new BaseResponse(httpStatus.value(), message, data);
//    }

    public static void ofFail(HttpServletResponse response, HttpStatus httpStatus, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(200);
        response.getWriter().write(JsonUtils.convertObjectToJson(BaseResponse.ofFail(httpStatus, message)));
    }

}
