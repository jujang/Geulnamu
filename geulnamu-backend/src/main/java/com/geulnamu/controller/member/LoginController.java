package com.geulnamu.controller.member;

import com.geulnamu.global.response.BaseResponse;
import com.geulnamu.infrastructure.annotation.AuthToken;
import com.geulnamu.service.member.LoginService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;

@RestController
@RequiredArgsConstructor
@RequestMapping("/login")
public class LoginController {

    private final LoginService loginService;


    // TODO: redirect_uri를 프론트엔드에서 받아서 POST로 code를 전달하는 방식으로 변경할 것
    // 계정이 없었다면 생성 후 토큰 발급, 있었다면 바로 토큰 발급
    @GetMapping(value = "/oauth/kakao", name = "로그인 redirect url")
    public BaseResponse kakaoRedirectDestination(@RequestParam("code") String authorizationCode, HttpServletResponse servletResponse) {
        HashMap<String, Object> userInfo = loginService.findOAuthUserInfoFromKakao(authorizationCode);
        HashMap<String, Object> loginInfo = loginService.findUserAndCreateAccessToken(userInfo, servletResponse);
        return BaseResponse.ofSuccess(loginInfo);
    }

    @PostMapping(value = "/{memberId}/direct", name = "서버 직접 로그인 - 실 운영시 없어질 기능")
    public BaseResponse login(@PathVariable @Min(value = 1) Long memberId, HttpServletResponse servletResponse) {
        HashMap<String, Object> loginInfo = loginService.findUserAndCreateAccessToken(memberId, servletResponse);
        return BaseResponse.ofSuccess(loginInfo);
    }

    @PostMapping(value = "/re-issue/accessToken", name = "엑세스 토큰 재발급")
    public BaseResponse tokenReIssue(@CookieValue("refreshToken") String refreshToken, HttpServletResponse servletResponse) {
        String accessToken = loginService.accessTokenReIssue(refreshToken, servletResponse);
        return BaseResponse.ofSuccess(accessToken);
    }

    @PostMapping(value = "/logout", name = "로그아웃")
    public BaseResponse logout(@AuthToken String accessToken) {
        loginService.logoutMember(accessToken);
        return BaseResponse.ofSuccess();
    }

}
