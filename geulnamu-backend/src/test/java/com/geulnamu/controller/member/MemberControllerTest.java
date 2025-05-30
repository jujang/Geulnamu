package com.geulnamu.controller.member;

import com.geulnamu.controller.member.dto.MemberInfoRequestDTO;
import com.geulnamu.controller.member.dto.MemberRoleUpdateRequestDTO;
import com.geulnamu.controller.member.dto.MemberStatusUpdateRequestDTO;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.global.response.ResponseMessage;
import com.geulnamu.service.member.MemberService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.restdocs.payload.JsonFieldType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.ResultActions;

import java.time.LocalDate;

import static com.geulnamu.common.ApiDocumentUtils.getDocumentRequest;
import static com.geulnamu.common.ApiDocumentUtils.getDocumentResponse;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.springframework.restdocs.headers.HeaderDocumentation.headerWithName;
import static org.springframework.restdocs.headers.HeaderDocumentation.requestHeaders;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.patch;
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
//import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;


@WebMvcTest(value = MemberController.class)
public class MemberControllerTest extends ControllerTest {

    @MockitoBean
    private MemberService memberService;


    @Test
    @WithMockUser(roles = "MEMBER")
    public void checkMemberInfoRegisterTest() throws Exception {
        // given
        Boolean response = true;
        String accessToken = "Bearer access_token";

        given(memberService.checkMemberInfoRegister(any())).willReturn(response);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/member/info")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value(response))
            .andDo(document(
                "member/info/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.BOOLEAN).description(response)
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void updateMemberInfoTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MemberInfoRequestDTO requestDTO = new MemberInfoRequestDTO("나뭉이", "MALE", LocalDate.of(2022, 1, 1));

        doNothing().when(memberService).updateMemberInfo(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                patch("/member/info")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(requestDTO))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "member/info/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("name").type(JsonFieldType.STRING).attributes(key("format").value("특수 문자를 제외한 2자 이상, 10자 이하 문자열")).description("이름"),
                    fieldWithPath("gender").type(JsonFieldType.STRING).attributes(key("format").value("'MALE', 'FEMALE' 중 하나의 값")).description("성별"),
                    fieldWithPath("birthDate").type(JsonFieldType.STRING).attributes(key("format").value("yyyyMMdd 형식의 숫자값")).description("생년월일")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void updateMemberRoleTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MemberRoleUpdateRequestDTO requestDTO = new MemberRoleUpdateRequestDTO("STAFF");

        doNothing().when(memberService).updateMemberRole(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/member/{memberId}/role", 1L)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(requestDTO))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "member/role/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("memberId").attributes(key("format").value("0보다 큰 숫자값")).description("모임원 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("role").type(JsonFieldType.STRING).attributes(key("format").value("'MEMBER', 'VICE_STAFF', 'STAFF', 'VICE_LEADER', 'LEADER', 'ADMIN' 중 하나의 값")).description("변경할 등급")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void updateMemberStatusTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MemberStatusUpdateRequestDTO requestDTO = new MemberStatusUpdateRequestDTO("INACTIVE");

        doNothing().when(memberService).updateMemberStatus(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/member/{memberId}/status", 1L)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(requestDTO))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "member/status/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("memberId").attributes(key("format").value("0보다 큰 숫자값")).description("모임원 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("status").type(JsonFieldType.STRING).attributes(key("format").value("'ACTIVE', 'INACTIVE' 중 하나의 값")).description("변경할 활성화/비활성화 상태")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }
}
