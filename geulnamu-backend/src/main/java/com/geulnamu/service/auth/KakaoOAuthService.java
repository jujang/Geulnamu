package com.geulnamu.service.auth;

import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.HttpCommunicationErrorException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class KakaoOAuthService {

    @Value("${spring.security.oauth2.client.registration.kakao.client-id}")
    private String kakaoClientId;

    /**
     * 카카오 OAuth 전체 플로우 (토큰 발급 -> 유저 정보 조회 -> 로그아웃)
     */
    public Map<String, Object> getKakaoUserInfoAndLogout(String authorizationCode) {
        String kakaoAccessToken = getKakaoAccessToken(authorizationCode);
        Map<String, Object> userInfo = getKakaoUserInfo(kakaoAccessToken);
        logoutFromKakao(kakaoAccessToken);
        return userInfo;
    }

    /**
     * 카카오 액세스 토큰 발급
     */
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

            HttpEntity<MultiValueMap<String, String>> accessTokenRequest =
                new HttpEntity<>(accessTokenParams, accessTokenHeaders);

            ResponseEntity<Map> accessTokenResponse = restTemplate.exchange(
                "https://kauth.kakao.com/oauth/token",
                HttpMethod.POST,
                accessTokenRequest,
                Map.class
            );

            HashMap<String, String> responseBody = (HashMap) accessTokenResponse.getBody();
            accessToken = responseBody.get("access_token");
        } catch (HttpClientErrorException e) {
            throw new BadRequestException(ResponseMessage.OAUTH_SERVER_REQUEST_ISSUE, e.getMessage());
        } catch (Exception e) {
            throw new HttpCommunicationErrorException(ResponseMessage.OAUTH_SERVER_REQUEST_ISSUE, e.getMessage());
        }

        return accessToken;
    }

    /**
     * 카카오 사용자 정보 조회
     */
    public HashMap<String, Object> getKakaoUserInfo(String kakaoAccessToken) {
        HashMap<String, Object> userInfo = new HashMap<>();
        try {
            RestTemplate restTemplate = new RestTemplate();

            HttpHeaders headers = new HttpHeaders();
            headers.add("Content-type", "application/x-www-form-urlencoded");
            headers.add("Authorization", "Bearer " + kakaoAccessToken);

            HttpEntity<MultiValueMap<String, String>> userInfoRequest = new HttpEntity<>(headers);

            ResponseEntity<Map> userInfoResponse = restTemplate.exchange(
                "https://kapi.kakao.com/v2/user/me",
                HttpMethod.POST,
                userInfoRequest,
                Map.class
            );

            userInfo = (HashMap) userInfoResponse.getBody();
        } catch (HttpClientErrorException e) {
            throw new BadRequestException(ResponseMessage.OAUTH_SERVER_REQUEST_ISSUE, e.getMessage());
        } catch (Exception e) {
            throw new HttpCommunicationErrorException(ResponseMessage.OAUTH_SERVER_REQUEST_ISSUE, e.getMessage());
        }

        return userInfo;
    }


    /**
     * 카카오 로그아웃
     */
    public void logoutFromKakao(String kakaoAccessToken) {
        try {
            RestTemplate restTemplate = new RestTemplate();

            HttpHeaders headers = new HttpHeaders();
            headers.add("Content-type", "application/x-www-urlencoded");
            headers.add("Authorization", "Bearer " + kakaoAccessToken);

            HttpEntity<MultiValueMap<String, String>> restEntityMap = new HttpEntity<>(headers);

            restTemplate.exchange(
                "https://kapi.kakao.com/v1/user/logout",
                HttpMethod.POST,
                restEntityMap,
                Map.class
            );
        } catch (Exception e) {
            throw new HttpCommunicationErrorException(ResponseMessage.OAUTH_SERVER_LOGOUT_ISSUE, e.getMessage());
        }
    }

}
