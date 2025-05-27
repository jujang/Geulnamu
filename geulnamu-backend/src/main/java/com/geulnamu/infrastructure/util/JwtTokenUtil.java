package com.geulnamu.infrastructure.util;

import com.geulnamu.domain.member.Role;
import com.geulnamu.domain.shared.TokenInfo;
import com.geulnamu.domain.shared.TokenType;
import com.geulnamu.global.response.ResponseMessage;
import com.geulnamu.infrastructure.exception.TokenException;
import io.jsonwebtoken.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import javax.crypto.spec.SecretKeySpec;
import java.security.Key;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
public class JwtTokenUtil {

    private final Key accessTokenKey;
    private final Key refreshTokenKey;

    public JwtTokenUtil(
        @Value("${spring.jwt.accessTokenKey}") String accessTokenKey,
        @Value("${spring.jwt.refreshTokenKey}") String refreshTokenKey) {
        this.accessTokenKey = new SecretKeySpec(accessTokenKey.getBytes(), 0, accessTokenKey.getBytes().length, "HmacSHA512");
        this.refreshTokenKey = new SecretKeySpec(refreshTokenKey.getBytes(), 0, refreshTokenKey.getBytes().length, "HmacSHA512");
    }

    // 토큰 발행
    public String createToken(Long memberId, Role role, TokenType tokenType) {
        long addTokenTime = (tokenType.equals(TokenType.AccessToken)) ? TokenInfo.LOGIN_VALID_TIME : TokenInfo.REFRESH_TOKEN_VALID_TIME;
        Date validity = new Date((new Date()).getTime() + addTokenTime);
        Claims claims = Jwts.claims().setSubject(String.valueOf(memberId));
        switch(role) {
            case MEMBER -> claims.put("roles", String.valueOf(Role.MEMBER));
            case VICE_STAFF -> claims.put("roles", String.valueOf(Role.VICE_STAFF));
            case STAFF -> claims.put("roles", String.valueOf(Role.STAFF));
            case VICE_LEADER -> claims.put("roles", String.valueOf(Role.VICE_LEADER));
            case LEADER -> claims.put("roles", String.valueOf(Role.LEADER));
            case ADMIN -> claims.put("roles", String.valueOf(Role.ADMIN));
        }

        return Jwts.builder()
            .setClaims(claims)
            .setIssuedAt(new Date())
            .setExpiration(validity)
            .signWith((tokenType.equals(TokenType.AccessToken)) ? accessTokenKey : refreshTokenKey, SignatureAlgorithm.HS512)
            .compact();
    }

    // 토큰 내부 값 반환
    public Claims getClaims(String token, TokenType tokenType) {
        Key secretKey = tokenType.equals(TokenType.AccessToken) ? accessTokenKey : refreshTokenKey;

        try {
            return Jwts.parserBuilder().setSigningKey(secretKey).build().parseClaimsJws(token).getBody();
        } catch (Exception e) {
            log.error("토큰이 유효하지 않습니다.");
            throw new TokenException(tokenType.equals(TokenType.AccessToken) ? ResponseMessage.ACCESS_TOKEN_NOT_VALIDATE : ResponseMessage.REFRESH_TOKEN_NOT_VALIDATE);
        }
    }

    public Long getMemberId(String token, TokenType tokenType) {
        Claims claims = getClaims(token, tokenType);
        return Long.parseLong(claims.getSubject());
    }

    public Role getRole(String token, TokenType tokenType) {
        Claims claims = getClaims(token, tokenType);
        return Role.valueOf(claims.get("roles").toString());
    }

    public Date getExpiredTime(String token, TokenType tokenType) {
        Claims claims = getClaims(token, tokenType);
        return claims.getExpiration();
    }

    public Long getValidTimeToLong(String token, TokenType tokenType) {
        Claims claims = getClaims(token, tokenType);
        long now = new Date().getTime();
        return (claims.getExpiration().getTime() - now);
    }

//    public String getAccessToken(HttpServletRequest request) {
//        return request.getHeader(HttpHeaders.AUTHORIZATION);
//    }

    // 토큰 유효성 + 만료일자 확인
    public boolean validateToken(String token, TokenType tokenType) {
        try {
            Key secretKey = tokenType.equals(TokenType.AccessToken) ? accessTokenKey : refreshTokenKey;
            Jwts.parserBuilder().setSigningKey(secretKey).build().parseClaimsJws(token);
            return true;
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            log.error("잘못된 JWT 서명입니다.");
        } catch (ExpiredJwtException e) {
            log.error("만료된 JWT 토큰입니다.");
        } catch (UnsupportedJwtException e) {
            log.error("지원되지 않는 JWT 토큰입니다.");
        } catch(IllegalArgumentException e) {
            log.error("JWT 토큰이 잘못되었습니다.");
        }
        return false;
    }

    // JWT 토큰 인증정보 조회
    public Authentication getAuthentication(String token, TokenType tokenType) {
        Claims claims = getClaims(token, tokenType);
        List<String> roles = new ArrayList<>();
        roles.add(claims.get("roles", String.class));

        Collection<? extends GrantedAuthority> getAuthorities = roles.stream()
            .map(role -> new SimpleGrantedAuthority("ROLE_" + role))  // ROLE_ 접두사 추가 (securityConfig의 filterChain 에서 검증 시 접두사가 있어야 해서 붙여줌)
            .collect(Collectors.toList());

        return new UsernamePasswordAuthenticationToken(claims, "", getAuthorities);
    }
}
