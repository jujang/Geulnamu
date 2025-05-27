package com.geulnamu.infrastructure.exception;

import com.geulnamu.global.response.BaseResponse;
import com.geulnamu.global.response.ResponseMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestCookieException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.format.DateTimeParseException;
import java.util.Arrays;

@Slf4j
@RestControllerAdvice
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    // 커스텀 에러 핸들러
    @ExceptionHandler(ServerException.class)
    public BaseResponse serverExceptionHandler(ServerException exception) {
        log.error("message: {} ", exception.getMessage());
        return BaseResponse.ofFail(exception.getCode(), exception.getMessage(), exception.getField());
    }

    /**
     * 입력값으로 LocalDate를 올바른 형식으로 입력하지 않았을 경우
     * HttpStatus 400
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public BaseResponse DateTimeParseExceptionHandler(HttpMessageNotReadableException exception) {
        log.error("message: {} ", exception.getMessage());
        return BaseResponse.ofFail(400, ResponseMessage.BIRTH_DATE_NOT_VALIDATE, null);
    }

    /**
     * Refresh Token 필요한 요청에서 Refresh Token 발견하지 못했을 경우
     * HttpStatus 401
     */
    @ExceptionHandler(MissingRequestCookieException.class)
    public BaseResponse missingRequestCookieException(MissingRequestCookieException exception){
        log.error("message : {} : {}", ResponseMessage.NOT_FOUND_REFRESH_TOKEN, exception.getMessage());
        return BaseResponse.ofFail(401, ResponseMessage.NOT_FOUND_REFRESH_TOKEN, null);
    }

    /**
     * Validation 실패 (RequestBody)
     * HttpStatus 417
     */
    @ExceptionHandler({MethodArgumentNotValidException.class})
    public BaseResponse methodArgumentNotValidException(MethodArgumentNotValidException exception) {
        String errorMessage = exception.getFieldErrors().stream()
            .findFirst()
            .map(DefaultMessageSourceResolvable::getDefaultMessage)
            .orElse("Validation failed");

        return BaseResponse.ofFail(417, ResponseMessage.INVALID_REQ_VALUE, errorMessage);
    }

    /**
     * 다뤄주지 않은 에러 발생 시, TODO: slack 채널로 에러 전송
     */
    @ExceptionHandler(Exception.class)
    public BaseResponse handleException(Exception exception) {
        log.error("message : {}", exception.getMessage());

//        slackSendMessage(exception);

//        if(activeProfile.equals("dev")){
//            exception.printStackTrace();
//        }

        return BaseResponse.ofFail(500, ResponseMessage.INTERNAL_SERVER_ERROR, null);
    }


}
