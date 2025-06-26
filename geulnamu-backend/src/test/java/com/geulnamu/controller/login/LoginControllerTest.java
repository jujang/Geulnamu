package com.geulnamu.controller.login;

import com.geulnamu.controller.login.dto.response.LoginResponse;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.security.token.TokenInfo;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.service.login.LoginFacade;
import jakarta.servlet.http.Cookie;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.restdocs.payload.JsonFieldType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.ResultActions;

import static com.geulnamu.common.ApiDocumentUtils.getDocumentRequest;
import static com.geulnamu.common.ApiDocumentUtils.getDocumentResponse;
import static com.geulnamu.infrastructure.format.DocumentOptionalGenerator.setAttributes;
import static org.mockito.Mockito.doNothing;
import static org.springframework.restdocs.cookies.CookieDocumentation.cookieWithName;
import static org.springframework.restdocs.cookies.CookieDocumentation.requestCookies;
import static org.springframework.restdocs.headers.HeaderDocumentation.*;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.post;
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.queryParameters;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(value = LoginController.class)
public class LoginControllerTest extends ControllerTest {

    @MockitoBean
    private LoginFacade loginFacade;


    @Test
    public void processKakaoLoginTest() throws Exception {
        // given
        String accessToken = "Bearer accessToken";
        LoginResponse loginResponse = new LoginResponse(1L, Role.MEMBER, accessToken, true);
        Cookie cookie = new Cookie("refreshToken", "random_refreshToken_code");
        cookie.setMaxAge((int) (TokenInfo.REFRESH_TOKEN_VALID_TIME/1000));
        cookie.setPath("/");
        cookie.setSecure(true);
        cookie.setHttpOnly(true);
        cookie.setSecure(true);

        String authorizationCode = "random_code";

        given(loginFacade.loginWithKakao(any(), any())).willReturn(loginResponse);

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
            .andExpect(jsonPath("data.memberId").value(loginResponse.memberId()))
            .andExpect(jsonPath("data.accessToken").value(loginResponse.accessToken()))
            .andExpect(jsonPath("data.newMember").value(loginResponse.newMember()))
            .andDo(document(
                "/login/oauth/kakao",
                getDocumentRequest(),
                getDocumentResponse(),
                responseHeaders(
                    headerWithName(HttpHeaders.SET_COOKIE).description("리프레시 토큰")
                ),
                queryParameters(
                    parameterWithName("code").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("카카오 oauth를 통해 받은 code")).description("kakao oauth code")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data.memberId").type(JsonFieldType.NUMBER).description("모임원 고유번호"),
                    fieldWithPath("data.role").type(JsonFieldType.STRING).description("모임원 역할"),
                    fieldWithPath("data.accessToken").type(JsonFieldType.STRING).description("액세스 토큰 값"),
                    fieldWithPath("data.newMember").type(JsonFieldType.BOOLEAN).description("멤버 신규 여부")
                )
            ));
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

        given(loginFacade.reissueAccessToken(any(), any())).willReturn(accessToken);

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
            .andExpect(jsonPath("data").value(accessToken))
            .andDo(document(
                "/login/re-issue/accessToken",
                getDocumentRequest(),
                getDocumentResponse(),
                requestCookies(
                    cookieWithName("refreshToken").description("리프레시 토큰")
                ),
                responseHeaders(
                    headerWithName(HttpHeaders.SET_COOKIE).description("새로 발급된 리프레시 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.STRING).description("신규 발급 액세스 토큰")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void logoutTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(loginFacade).logout(any(), any());

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
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "/login/logout",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

}
