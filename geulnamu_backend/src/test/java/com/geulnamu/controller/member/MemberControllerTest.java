package com.geulnamu.controller.member;

import com.geulnamu.controller.member.dto.request.MemberInfoRequest;
import com.geulnamu.controller.member.dto.request.MemberNameUpdateRequest;
import com.geulnamu.controller.member.dto.request.MemberPushSettingRequest;
import com.geulnamu.controller.member.dto.request.MemberRoleUpdateRequest;
import com.geulnamu.controller.member.dto.response.MemberInfoResponse;
import com.geulnamu.controller.member.dto.response.MemberListResponse;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.domain.member.Gender;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.infrastructure.response.ResponseMessage;
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
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static com.geulnamu.common.ApiDocumentUtils.getDocumentRequest;
import static com.geulnamu.common.ApiDocumentUtils.getDocumentResponse;
import static com.geulnamu.infrastructure.format.DocumentOptionalGenerator.setAttributes;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.springframework.restdocs.headers.HeaderDocumentation.headerWithName;
import static org.springframework.restdocs.headers.HeaderDocumentation.requestHeaders;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.patch;
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.request.RequestDocumentation.*;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;


@WebMvcTest(value = MemberController.class)
public class MemberControllerTest extends ControllerTest {

    @MockitoBean
    private MemberService memberService;


    @Test
    @WithMockUser(roles = "MEMBER")
    public void checkMyInfoRegisterTest() throws Exception {
        // given
        Boolean response = true;
        String accessToken = "Bearer access_token";

        given(memberService.isMemberInfoRegistered(any())).willReturn(response);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/members/me/profile-status")
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
                "members/check/status/my",
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
    public void findMyInfoTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        MemberInfoResponse memberInfoResponse = new MemberInfoResponse(
            1L, "나뭉일", Gender.valueOf("MALE"), LocalDate.of(2022, 1, 1), "namu_1", Role.LEADER, LocalDateTime.of(2022, 1, 3, 11, 30, 0)
        );

        given(memberService.findMember(any())).willReturn(memberInfoResponse);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.get("/members/me/profile")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andDo(document(
                "members/my/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data.memberId").type(JsonFieldType.NUMBER).description("모임원 고유번호"),
                    fieldWithPath("data.name").type(JsonFieldType.STRING).description("이름").optional(),
                    fieldWithPath("data.gender").type(JsonFieldType.STRING).description("성별").optional(),
                    fieldWithPath("data.birthDate").type(JsonFieldType.STRING).description("생년월일").optional(),
                    fieldWithPath("data.nickname").type(JsonFieldType.STRING).description("닉네임(카카오 닉네임)"),
                    fieldWithPath("data.role").type(JsonFieldType.STRING).description("권한 등급"),
                    fieldWithPath("data.deletedAt").type(JsonFieldType.STRING).description("삭제일자 (삭제되지 않은 경우 null)").optional()
                )
            ));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void findMemberTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        MemberInfoResponse memberInfoResponse = new MemberInfoResponse(
            1L, "나뭉일", Gender.valueOf("MALE"), LocalDate.of(2022, 1, 1), "namu_1", Role.LEADER, LocalDateTime.of(2022, 1, 3, 11, 30, 0)
        );

        given(memberService.findMember(any())).willReturn(memberInfoResponse);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/members/{memberId}", 1)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andDo(document(
                "members/view",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("memberId").attributes(key("format").value("1 이상의 정수")).description("모임원 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data.memberId").type(JsonFieldType.NUMBER).description("모임원 고유번호"),
                    fieldWithPath("data.name").type(JsonFieldType.STRING).description("이름").optional(),
                    fieldWithPath("data.gender").type(JsonFieldType.STRING).description("성별").optional(),
                    fieldWithPath("data.birthDate").type(JsonFieldType.STRING).description("생년월일").optional(),
                    fieldWithPath("data.nickname").type(JsonFieldType.STRING).description("닉네임(카카오 닉네임)"),
                    fieldWithPath("data.role").type(JsonFieldType.STRING).description("권한 등급"),
                    fieldWithPath("data.deletedAt").type(JsonFieldType.STRING).optional().description("삭제일자 (삭제되지 않은 경우 null)")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "STAFF")
    public void getMembersTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        List<MemberInfoResponse> memberInfoResponseList =
            Arrays.asList(
                new MemberInfoResponse(1L, "나뭉일", Gender.valueOf("MALE"),
                    LocalDate.of(2022, 1, 1), "namu_1", Role.LEADER,
                    LocalDateTime.of(2022, 1, 3, 11, 30, 0)),
                new MemberInfoResponse(2L, "나뭉이", Gender.valueOf("FEMALE"),
                    LocalDate.of(2022, 1, 2), "namu_2", Role.VICE_STAFF, null)
            );

        PagingResponse pagingResponse = new PagingResponse(
            1, 3, 6
        );

        MemberListResponse memberListResponse = new MemberListResponse(pagingResponse, memberInfoResponseList);


        given(memberService.getMembers(any())).willReturn(memberListResponse);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/members/list")
                    .param("gender", "MALE")
                    .param("role", "MEMBER")
                    .param("isDeleted", "true")
                    .param("sortBy", "role")
                    .param("isAsc", "true")
                    .param("page", "1")
                    .param("size", "10")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andDo(document(
                "members/list/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("gender").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'MALE', 'FEMALE' 중 하나의 값")).description("성별").optional(),
                    parameterWithName("role").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'MEMBER', 'VICE_STAFF', 'STAFF', 'VICE_LEADER', 'LEADER', 'ADMIN' 중 하나의 값")).description("등급").optional(),
                    parameterWithName("isDeleted").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'true', 'false' 중 하나의 값")).description("비활성 여부").optional(),
                    parameterWithName("sortBy").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'id', 'role', 'name', 'gender', 'birthDate' 중 하나의 값")).description("정렬 기준 (id는 memberId를 뜻함)").optional(),
                    parameterWithName("isAsc").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'true', 'false' 중 하나의 값")).description("오름차순 여부").optional(),
                    parameterWithName("page").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("페이지"),
                    parameterWithName("size").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("사이즈")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data.pagingResponse").type(JsonFieldType.OBJECT).description("페이지 정보"),
                    fieldWithPath("data.pagingResponse.pageNumber").type(JsonFieldType.NUMBER).description("현재 페이지"),
                    fieldWithPath("data.pagingResponse.totalPages").type(JsonFieldType.NUMBER).description("전체 페이지 수"),
                    fieldWithPath("data.pagingResponse.totalElements").type(JsonFieldType.NUMBER).description("전체 데이터 수"),
                    fieldWithPath("data.memberList[]").type(JsonFieldType.ARRAY).description("데이터 정보"),
                    fieldWithPath("data.memberList[].memberId").type(JsonFieldType.NUMBER).description("모임원 고유번호"),
                    fieldWithPath("data.memberList[].name").type(JsonFieldType.STRING).description("이름").optional(),
                    fieldWithPath("data.memberList[].gender").type(JsonFieldType.STRING).description("성별").optional(),
                    fieldWithPath("data.memberList[].birthDate").type(JsonFieldType.STRING).description("생년월일").optional(),
                    fieldWithPath("data.memberList[].nickname").type(JsonFieldType.STRING).description("닉네임(카카오 닉네임)"),
                    fieldWithPath("data.memberList[].role").type(JsonFieldType.STRING).description("권한 등급"),
                    fieldWithPath("data.memberList[].deletedAt").type(JsonFieldType.STRING).optional().description("삭제일자 (삭제되지 않은 경우 null)")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getPushSettingTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        Boolean response = true;

        given(memberService.getPushSetting(any())).willReturn(response);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/members/me/push-setting")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andDo(document(
                "members/my/push-setting/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.BOOLEAN).description("앱 푸시 수신 여부")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void updatePushSettingTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MemberPushSettingRequest request = new MemberPushSettingRequest("true");

        doNothing().when(memberService).updatePushSetting(any(), any(Boolean.class));

        // when
        ResultActions actions =
            mockMvc.perform(
                patch("/members/me/push-setting")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "members/my/push-setting/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("isPushEnabled").type(JsonFieldType.BOOLEAN).attributes(key("format").value("'true', 'false' 중 하나의 값")).description("앱 푸시 수신 여부")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void updateMyInfoTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MemberInfoRequest request = new MemberInfoRequest("나뭉이", "MALE", LocalDate.of(2022, 1, 1));

        doNothing().when(memberService).updateMemberInfo(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                patch("/members/me/profile")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "members/info/modify/my",
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
        MemberRoleUpdateRequest request = new MemberRoleUpdateRequest("STAFF");

        doNothing().when(memberService).updateMemberRole(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/members/{memberId}/role", 1L)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "members/role/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("memberId").attributes(key("format").value("1 이상의 정수")).description("모임원 고유번호")
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
    public void updateMemberNameTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MemberNameUpdateRequest request = new MemberNameUpdateRequest("나뭉이");

        doNothing().when(memberService).updateMemberName(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/members/{memberId}/name", 1L)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(request))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "members/name/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("memberId").attributes(key("format").value("1 이상의 정수")).description("모임원 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("name").type(JsonFieldType.STRING).attributes(key("format").value("특수 문자를 제외한 2자 이상, 10자 이하 문자열")).description("이름")
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
    public void activateMemberTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(memberService).activateMember(any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/members/{memberId}/activate", 1L)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "members/activate",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("memberId").attributes(key("format").value("1 이상의 정수")).description("모임원 고유번호")
                ),
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

    @Test
    @WithMockUser(roles = "ADMIN")
    public void deactivateMember() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(memberService).deactivateMember(any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/members/{memberId}/deactivate", 1L)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "members/deactivate",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("memberId").attributes(key("format").value("1 이상의 정수")).description("모임원 고유번호")
                ),
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
