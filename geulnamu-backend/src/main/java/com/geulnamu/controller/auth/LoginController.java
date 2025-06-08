package com.geulnamu.controller.auth;

import com.geulnamu.controller.auth.dto.response.LoginResponseDTO;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.service.auth.LoginFacade;
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
    // TODO: 해당 요청중 계정 생성은 이력이 남아야 될 것 같은데...
    // 계정이 없었다면 생성 후 토큰 발급, 있었다면 바로 토큰 발급
    @AccessLevel(Level.PUBLIC)
    @GetMapping(value = "/oauth/kakao", name = "로그인 redirect url")
    public BaseResponse<LoginResponseDTO> processKakaoLogin(@RequestParam("code") String authorizationCode, HttpServletResponse response) {
        LoginResponseDTO loginResponseDTO = loginFacade.loginWithKakao(authorizationCode, response);
        return BaseResponse.ofSuccess(loginResponseDTO);
    }

    @AccessLevel(Level.PUBLIC)
    @PostMapping(value = "/{memberId}/direct", name = "서버 직접 로그인 - 실 운영시 없어질 기능")
    public BaseResponse<LoginResponseDTO> login(@PathVariable @Min(value = 1) Long memberId, HttpServletResponse response) {
        LoginResponseDTO loginResponseDTO = loginFacade.loginForDevelopment(memberId, response);
        return BaseResponse.ofSuccess(loginResponseDTO);
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

}
