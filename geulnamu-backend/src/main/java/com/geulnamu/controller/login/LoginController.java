package com.geulnamu.controller.login;

import com.geulnamu.controller.login.dto.response.LoginResponse;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.LogAction;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.service.login.LoginFacade;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


@RestController
@RequiredArgsConstructor
@RequestMapping("/login")
public class LoginController {

    private final LoginFacade loginFacade;

    // TODO: redirect_uri를 프론트엔드에서 받아서 POST로 code를 전달하는 방식으로 변경할 것
    // 계정이 없었다면 생성 후 토큰 발급, 있었다면 바로 토큰 발급
    @LogAction(value = ActionType.MEMBER_LOGIN, actionDomain = "login")
    @AccessLevel(Level.PUBLIC)
    @GetMapping(value = "/oauth/kakao", name = "로그인 redirect url")
    public BaseResponse<LoginResponse> processKakaoLogin(@RequestParam("code") String authorizationCode, HttpServletResponse response) {
        LoginResponse loginResponse = loginFacade.loginWithKakao(authorizationCode, response);
        return BaseResponse.ofSuccess(loginResponse);
    }

    @AccessLevel(Level.PUBLIC)
    @PostMapping(value = "/re-issue/accessToken", name = "액세스 토큰 재발급")
    public BaseResponse<String> reIssueAccessToken(@CookieValue("refreshToken") String refreshToken, HttpServletResponse response) {
        String accessToken = loginFacade.reissueAccessToken(refreshToken, response);
        return BaseResponse.ofSuccess(accessToken);
    }

    @AccessLevel(Level.MEMBER)
    @PostMapping(value = "/logout", name = "로그아웃")
    public BaseResponse<Void> logout(@AuthMemberId Long memberId, HttpServletResponse response) {
        loginFacade.logout(memberId, response);
        return BaseResponse.ofSuccess();
    }

    @LogAction(value = ActionType.MEMBER_LOGIN, actionDomain = "login")
    @AccessLevel(Level.PUBLIC)
    @PostMapping(value = "/{memberId}/direct", name = "서버 직접 로그인 - 실 운영시 없어질 기능")
    public BaseResponse<LoginResponse> login(@PathVariable @Min(value = 1) Long memberId, HttpServletResponse response) {
        LoginResponse loginResponse = loginFacade.loginForDevelopment(memberId, response);
        return BaseResponse.ofSuccess(loginResponse);
    }

}
