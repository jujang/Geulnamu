package com.geulnamu.service.login;

import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.security.token.TokenInfo;
import com.geulnamu.infrastructure.security.token.TokenPair;
import com.geulnamu.infrastructure.security.token.TokenReissueResult;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.security.token.TokenType;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Service;

import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthTokenService {

    private final JwtTokenUtil jwtTokenUtil;

    /**
     * 토큰 페어 생성 (액세스 토큰 + 리프레시 토큰)
     */
    public TokenPair createTokenPair(Long memberId, Role role) {
        String accessToken = jwtTokenUtil.createToken(memberId, role, TokenType.AccessToken);
        String refreshToken = jwtTokenUtil.createToken(memberId, role, TokenType.RefreshToken);
        return new TokenPair(accessToken, refreshToken);
    }

    /**
     * 리프레시 토큰을 쿠키에 설정하고 액세스 토큰 반환
     */
    public TokenPair createTokensAndSetCookie(Long memberId, Role role, HttpServletResponse response) {
        TokenPair tokenPair = createTokenPair(memberId, role);
        setRefreshTokenCookie(tokenPair.refreshToken(), response);
        return tokenPair;
    }

    /**
     * 액세스 토큰 재발급 (리프래시 토큰 갱신 포함)
     */
    public TokenReissueResult reissueAccessToken(String refreshToken, Long memberId, Role role, HttpServletResponse response) {
        // 새로운 액세스 토큰 생성
        String newAccessToken = jwtTokenUtil.createToken(memberId, role, TokenType.AccessToken);

        // 리프레시 토큰이 만료 임박하면 갱신
        if(jwtTokenUtil.checkRefreshTokenValidTimeOverHalf(refreshToken)) {
            log.info("리프레시 토큰 갱신 진행");
            String newRefreshToken = jwtTokenUtil.createToken(memberId, role, TokenType.RefreshToken);
            setRefreshTokenCookie(newRefreshToken, response);
            return new TokenReissueResult(newAccessToken, newRefreshToken, true); // 갱신된 리프레시 토큰 함께 반환
        }

        return new TokenReissueResult(newAccessToken, refreshToken, false); // 기존 리프레시 토큰 함께 반환
    }

    /**
     * 리프레시 토큰 검증
     */
    public boolean validateRefreshToken(String refreshToken) {
        return jwtTokenUtil.validateToken(refreshToken, TokenType.RefreshToken);
    }

    /**
     * 쿠키 삭제 (로그아웃 시)
     */
    public void clearRefreshTokenCookie(HttpServletResponse response) {
        ResponseCookie cookie = ResponseCookie.from("refreshToken", "")
            .maxAge(0)
            .path("/")
            .secure(true)
            .httpOnly(true)
            .sameSite("None")
            .build();
        response.setHeader("Set-Cookie", cookie.toString());
    }

    public String extractNickname(Map<String, Object> userInfo) {
        try {
            Object propertiesObj = userInfo.get("properties");
            Map<String, Object> properties = (Map<String, Object>) propertiesObj;
            return (String) properties.get("nickname");
        } catch (Exception e) {
            log.error("카카오 닉네임 추출 중 예외 발생: {}", e.getMessage(), e);
            throw new BadRequestException(ResponseMessage.KAKAO_NICKNAME_PARSE_ISSUE);
        }
    }

    /**
     * 리프레시 토큰을 쿠키에 설정하는 내부 메서드
     */
    private static void setRefreshTokenCookie(String refreshToken, HttpServletResponse response) {
        ResponseCookie cookie = ResponseCookie.from("refreshToken", refreshToken)
            .maxAge(TokenInfo.REFRESH_TOKEN_VALID_TIME / 1000)
            .path("/")
            .secure(true)
            .httpOnly(true)
            .sameSite("None")
            .build();
        response.setHeader("Set-Cookie", cookie.toString());
    }

}
