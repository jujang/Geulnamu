package com.geulnamu.infrastructure.exception;

import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.infrastructure.response.ResponseMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.MessageSourceResolvable;
import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestCookieException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.HandlerMethodValidationException;
import org.springframework.web.servlet.NoHandlerFoundException;

@Slf4j
@RestControllerAdvice
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    // 커스텀 에러 핸들러
    @ExceptionHandler(ServerException.class)
    public BaseResponse serverExceptionHandler(ServerException exception) {
        log.error("message : {} ", exception.getMessage());
        return BaseResponse.ofFail(exception.getCode(), exception.getMessage(), exception.getField());
    }

    /**
     * HTTP 요청 타입이 잘못됨
     * HttpStatus 400
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public BaseResponse httpRequestMethodNotSupportedException(HttpRequestMethodNotSupportedException exception){
        log.error("message : {} : {}", ResponseMessage.BAD_REQUEST, exception.getMessage());
        return BaseResponse.ofFail(400, ResponseMessage.BAD_REQUEST, exception.getMessage());
    }

    /**
     * 매핑되는 API URL을 찾을 수 없음
     */
    @ExceptionHandler(NoHandlerFoundException.class)
    public BaseResponse noHandlerFoundException(NoHandlerFoundException exception) {
        log.error("message : {} : {}", ResponseMessage.NOT_FOUND_URL, exception.getRequestURL());
        return BaseResponse.ofFail(404, ResponseMessage.NOT_FOUND_URL, exception.getRequestURL());
    }

    /**
     * queryString이 전달되지 않았을 경우
     * HttpStatus 400
     */
    @ExceptionHandler({MissingServletRequestParameterException.class})
    public BaseResponse missingServletRequestParameterException(MissingServletRequestParameterException exception) {
        log.error("message : {} : {} : {}", ResponseMessage.BAD_REQUEST, exception.getMessage(), exception.getParameterName());
        return BaseResponse.of(400, ResponseMessage.BAD_REQUEST, exception.getMessage());
    }

    /**
     * 요청(requestBody) 값 null이거나 원하는 형식이 아님
     * HttpStatus 400
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public BaseResponse DateTimeParseExceptionHandler(HttpMessageNotReadableException exception) {
        log.error("message : {} : {} ", ResponseMessage.BAD_REQUEST, exception.getMessage());
        return BaseResponse.ofFail(400, ResponseMessage.BAD_REQUEST, "요청 정보가 존재하지 않습니다.");
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
     * Validation 실패 (Method Parameter)
     * HttpStatus 417
     */
    @ExceptionHandler({HandlerMethodValidationException.class})
    public BaseResponse handlerMethodValidationException(HandlerMethodValidationException exception) {
        log.error("HandlerMethodValidationException: {} ", exception.getMessage());
        
        // 실제 검증 에러 메시지 추출 (최신 버전)
        String errorMessage = exception.getAllErrors().stream()
            .findFirst()
            .map(MessageSourceResolvable::getDefaultMessage)
            .orElse("Method parameter validation failed");
            
        return BaseResponse.ofFail(417, ResponseMessage.INVALID_REQ_VALUE, errorMessage);
    }

    /**
     * 다뤄주지 않은 에러 발생 시, TODO: slack 채널로 에러 전송
     */
    @ExceptionHandler(Exception.class)
    public BaseResponse handleException(Exception exception) {
        log.error("message : {}", exception.getMessage());
        log.error(exception.toString());

//        slackSendMessage(exception);

//        if(activeProfile.equals("dev")){
//            exception.printStackTrace();
//        }

        return BaseResponse.ofFail(500, ResponseMessage.INTERNAL_SERVER_ERROR, null);
    }


}
