package com.geulnamu.controller.member;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.domain.shared.TokenInfo;
import com.geulnamu.global.response.ResponseMessage;
import com.geulnamu.service.member.LoginService;
import jakarta.servlet.http.Cookie;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import java.util.HashMap;

import static org.mockito.Mockito.doNothing;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(value = LoginController.class)
public class LoginControllerTest extends ControllerTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private ObjectMapper objectMapper;
    @MockitoBean
    private LoginService loginService;


    @Test
    public void processKakaoLoginTest() throws Exception {
        // given
        String accessToken = "Bearer accessToken";
        HashMap<String, Object> loginInfo = new HashMap<>();
        loginInfo.put("AccessToken", accessToken);
        loginInfo.put("UserAlreadyPresent", true);
        Cookie cookie = new Cookie("refreshToken", "random_refreshToken_code");
        cookie.setMaxAge((int) (TokenInfo.REFRESH_TOKEN_VALID_TIME/1000));
        cookie.setPath("/");
        cookie.setSecure(true);
        cookie.setHttpOnly(true);
        cookie.setSecure(true);

        String authorizationCode = "random_code";

        given(loginService.findOAuthUserInfoFromKakao(any())).willReturn(new HashMap<>());
        given(loginService.findUserAndCreateAccessToken(any(HashMap.class), any())).willReturn(loginInfo);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/login/oauth/kakao")
                    .param("code", authorizationCode)
                    .accept(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andDo(result -> {
                MockHttpServletResponse response = result.getResponse();
                response.addCookie(cookie);
            })
            .andExpect(status().isOk())
            .andExpect(cookie().value(cookie.getName(), cookie.getValue()))
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value(loginInfo));
    }

    @Test
    public void reIssueAccessTokenTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        Cookie requestCookie = new Cookie("refreshToken", "random_refreshToken_code_1");
        requestCookie.setMaxAge((int) (TokenInfo.REFRESH_TOKEN_VALID_TIME/1000));
        requestCookie.setPath("/");
        requestCookie.setSecure(true);
        requestCookie.setHttpOnly(true);
        requestCookie.setSecure(true);

        given(loginService.reissueAccessToken(any(), any())).willReturn(accessToken);

        // when
        ResultActions actions =
            mockMvc.perform(
                post("/login/re-issue/accessToken")
                    .cookie(requestCookie)
                    .accept(MediaType.APPLICATION_JSON)
            );

        // then
        Cookie reseponseCookie = new Cookie("refreshToken", "random_refreshToken_code_2");
        reseponseCookie.setMaxAge((int) (TokenInfo.REFRESH_TOKEN_VALID_TIME/1000));
        reseponseCookie.setPath("/");
        reseponseCookie.setSecure(true);
        reseponseCookie.setHttpOnly(true);
        reseponseCookie.setSecure(true);

        actions
            .andDo(result -> {
                MockHttpServletResponse response = result.getResponse();
                response.addCookie(reseponseCookie);
            })
            .andExpect(status().isOk())
            .andExpect(cookie().value(reseponseCookie.getName(), reseponseCookie.getValue()))
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value(accessToken));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void logoutTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(loginService).logoutMember(any());

        // when
        ResultActions actions =
            mockMvc.perform(
                post("/login/logout")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null));
    }

}
