package com.geulnamu.infrastructure.exception;

import com.geulnamu.global.response.BaseResponse;
import com.geulnamu.global.response.ResponseMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

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
