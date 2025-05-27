package com.geulnamu.service.member;

import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.domain.shared.TokenInfo;
import com.geulnamu.domain.shared.enums.TokenType;
import com.geulnamu.global.response.ResponseMessage;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.HttpCommunicationErrorException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.exception.TokenException;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import com.geulnamu.repository.member.MemberRepository;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class LoginService {

    private final MemberRepository memberRepository;
    private final JwtTokenUtil jwtTokenUtil;

    @Value("${spring.security.oauth2.client.registration.kakao.client-id}")
    private String kakaoClientId;

    public HashMap<String, Object> findOAuthUserInfoFromKakao(String authorizationCode) {
        String sNSAccessToken = getKakaoAccessToken(authorizationCode);
        HashMap<String, Object> userInfo = findUserInfoFromKakao(sNSAccessToken);
        oAuthKakaoLogout(sNSAccessToken);
        return userInfo;
    }

    public String getKakaoAccessToken(String code) {
        String accessToken = "";
        try {
            RestTemplate restTemplate = new RestTemplate();

            HttpHeaders accessTokenHeaders = new HttpHeaders();
            accessTokenHeaders.add("Content-type", "application/x-www-form-urlencoded");

            MultiValueMap<String, String> accessTokenParams = new LinkedMultiValueMap<>();
            accessTokenParams.add("grant_type", "authorization_code");
            accessTokenParams.add("client_id", kakaoClientId);
            accessTokenParams.add("code", code);

            HttpEntity<MultiValueMap<String, String>> accessTokenRequest = new HttpEntity<>(accessTokenParams, accessTokenHeaders);

            ResponseEntity<Map> accessTokenResponse = restTemplate.exchange(
                "https://kauth.kakao.com/oauth/token",
                HttpMethod.POST,
                accessTokenRequest,
                Map.class
            );

            HashMap<String, String> responseBody = (HashMap)accessTokenResponse.getBody();
            accessToken = responseBody.get("access_token");

        } catch(HttpClientErrorException e) {
            throw new BadRequestException("OAuth 서버 요청에 문제가 있습니다.", e.getMessage());
        } catch(Exception e) {
            throw new HttpCommunicationErrorException("OAuth 서버 요청에 문제가 있습니다.", e.getMessage());
        }

        return accessToken;
    }

    public HashMap<String, Object> findUserInfoFromKakao(String sNSAccessToken) {
        HashMap<String, Object> userInfo = new HashMap<>();
        try {
            RestTemplate restTemplate = new RestTemplate();

            HttpHeaders headers = new HttpHeaders();
            headers.add("Content-type", "application/x-www-form-urlencoded");
            headers.add("Authorization", "Bearer " + sNSAccessToken);

            HttpEntity<MultiValueMap<String, String>> userInfoRequest = new HttpEntity<>(headers);

            ResponseEntity<Map> userInfoResponse = restTemplate.exchange(
                "https://kapi.kakao.com/v2/user/me",
                HttpMethod.POST,
                userInfoRequest,
                Map.class
            );

            userInfo = (HashMap)userInfoResponse.getBody();

        } catch(HttpClientErrorException e) {
            throw new BadRequestException("OAuth 서버 요청에 문제가 있습니다.", e.getMessage());
        } catch(Exception e) {
            throw new HttpCommunicationErrorException("OAuth 서버 요청에 문제가 있습니다.", e.getMessage());
        }

        return userInfo;
    }

    public void oAuthKakaoLogout(String sNSAccessToken) {
        try {
            RestTemplate restTemplate = new RestTemplate();

            HttpHeaders headers = new HttpHeaders();
            headers.add("Content-type", "application/x-www-urlencoded");
            headers.add("Authorization", "Bearer " + sNSAccessToken);

            HttpEntity<MultiValueMap<String, String>> restEntityMap = new HttpEntity<>(headers);

            restTemplate.exchange(
                "https://kapi.kakao.com/v1/user/logout",
                HttpMethod.POST,
                restEntityMap,
                Map.class
            );
        } catch (Exception e) {
            throw new HttpCommunicationErrorException("OAuth 로그아웃 과정에 문제가 있습니다.", e.getMessage());
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public HashMap<String, Object> findUserAndCreateAccessToken(HashMap<String, Object> userInfo, HttpServletResponse servletResponse) {
        HashMap<String, Object> loginInfo = new HashMap<>();

        String kakaoUserId = userInfo.get("id").toString();
        Optional<Member> memberOptional = memberRepository.findByKakaoUserId(kakaoUserId);
        Member member;
        // oAuthCode를 기반으로 유저를 찾는데, 없으면 신규 생성 & 가져오기 / 있으면 유저 정보 가져오기
        if(memberOptional.isEmpty()) {
            log.info("멤버 엔티티 없음");
            String properties = userInfo.get("properties").toString();
            member = Member.builder()
                .role(Role.MEMBER)
                .nickname(userInfo.get("properties").toString().substring(properties.indexOf('=') + 1, properties.lastIndexOf("}")))
                .kakaoUserId(kakaoUserId)
                .build();
            memberRepository.save(member);
            loginInfo.put("MemberAlreadyPresent", false);
        } else {
            log.info("멤버 엔티티 존재");
            member = memberOptional.get();
            loginInfo.put("MemberAlreadyPresent", true);
        }

        String accessToken = jwtTokenUtil.createToken(member.getId(), member.getRole(), TokenType.AccessToken);
        loginInfo.put("AccessToken", accessToken);
        String refreshToken = putRefreshTokenInCookie(member, servletResponse);

        // DB의 멤버정보 속 refresh_token 값 갱신
        member.updateMemberRefreshToken(refreshToken);

        return loginInfo;
    }

    // TODO: 운영시, 삭제할 메서드
    @Transactional(rollbackFor = Exception.class)
    public HashMap<String, Object> findUserAndCreateAccessToken(Long memberId, HttpServletResponse servletResponse) {
        HashMap<String, Object> loginInfo = new HashMap<>();

        Optional<Member> memberOptional = memberRepository.findByIdAndDeletedAtIsNull(memberId);
        Member member;
        // memberId를 기반으로 유저를 찾는데, 없으면 에러 던지기(임시 기능이기에 이 정도면 됨) / 있으면 유저 정보 가져오기
        if(memberOptional.isEmpty()) {
            log.info("멤버 엔티티 없음");
            throw new NotFoundDataException();
        } else {
            log.info("멤버 엔티티 존재");
            member = memberOptional.get();
            loginInfo.put("MemberAlreadyPresent", true);
        }

        String accessToken = jwtTokenUtil.createToken(member.getId(), member.getRole(), TokenType.AccessToken);
        loginInfo.put("AccessToken", accessToken);
        String refreshToken = putRefreshTokenInCookie(member, servletResponse);

        // DB의 멤버정보 속 refresh_token 값 갱신
        member.updateMemberRefreshToken(refreshToken);

        return loginInfo;
    }

    @Transactional(rollbackFor = Exception.class)
    public String accessTokenReIssue(String refreshToken, HttpServletResponse servletResponse) {
        if(!jwtTokenUtil.validateToken(refreshToken, TokenType.RefreshToken)){
            throw new TokenException(ResponseMessage.REFRESH_TOKEN_NOT_VALIDATE);
        }
        Long memberId = jwtTokenUtil.getMemberId(refreshToken, TokenType.RefreshToken);
        Member member = memberRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);
        Role role = jwtTokenUtil.getRole(refreshToken, TokenType.RefreshToken);

        // 액세스 토큰 생성
        String newAccessToken = jwtTokenUtil.createToken(memberId, role, TokenType.AccessToken);
        // 리프레시 토큰 확인해서 기간이 반 이하일 경우, 리프레시 토큰도 재발행하기
        if(checkRefreshTokenValidTimeOverHalf(refreshToken)) {
            refreshToken = putRefreshTokenInCookie(member, servletResponse);
            member.updateMemberRefreshToken(refreshToken);
        }

        return newAccessToken;
    }

    @Transactional(rollbackFor = Exception.class)
    public void logoutMember(String accessToken) {
        Long memberId = jwtTokenUtil.getMemberId(accessToken, TokenType.AccessToken);
        Member member = memberRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        member.updateMemberRefreshToken(null);
    }


    private boolean checkRefreshTokenValidTimeOverHalf(String refreshToken) {
        Long validTime = jwtTokenUtil.getValidTimeToLong(refreshToken, TokenType.RefreshToken);
        if(validTime < TokenInfo.REFRESH_TOKEN_VALID_TIME/2) {
            log.info("리프레시 토큰의 유효시간이 반도 안 남았기에 교체해줍니다.");
            return true;
        }
        return false;
    }

    // 리프레시 토큰을 만들어서 쿠키에 붙임 + 해당 리프레시 토큰 반환
    private String putRefreshTokenInCookie(Member member, HttpServletResponse servletResponse) {
        String refreshToken = jwtTokenUtil.createToken(member.getId(), member.getRole(), TokenType.RefreshToken);

        ResponseCookie cookie =
            ResponseCookie.from("refreshToken", refreshToken)
                .maxAge(TokenInfo.REFRESH_TOKEN_VALID_TIME/1000)
                .path("/")
                .secure(true)
                .httpOnly(true)
                .sameSite("None")
                .build();
        servletResponse.setHeader("Set-Cookie", cookie.toString());

        return refreshToken;
    }

}
