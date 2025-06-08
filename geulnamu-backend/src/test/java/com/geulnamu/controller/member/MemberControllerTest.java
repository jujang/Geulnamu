package com.geulnamu.controller.member;

import com.geulnamu.controller.member.dto.request.MemberInfoRequestDTO;
import com.geulnamu.controller.member.dto.request.MemberNameUpdateRequestDTO;
import com.geulnamu.controller.member.dto.request.MemberRoleUpdateRequestDTO;
import com.geulnamu.controller.member.dto.response.MemberInfoResponseDTO;
import com.geulnamu.controller.member.dto.response.MemberListResponseDTO;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.domain.shared.enums.Gender;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
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
import java.util.ArrayList;
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

        given(memberService.isMemberInfoRegistered(any())).willReturn(response);

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

        doNothing().when(memberService).updateMemberInfo(any(), any(), any(), any());

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
    public void getMembersTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        PagingRequest pagingRequest = new PagingRequest(1, 10);

        MemberInfoResponseDTO memberInfoResponseDTO1 = new MemberInfoResponseDTO(
            1L, "나뭉일", Gender.valueOf("MALE"), LocalDate.of(2022, 1, 1), "namu_1", Role.LEADER, LocalDateTime.of(2022, 1, 3, 11, 30, 0)
        );
        MemberInfoResponseDTO memberInfoResponseDTO2 = new MemberInfoResponseDTO(
            2L, "나뭉이", Gender.valueOf("FEMALE"), LocalDate.of(2022, 1, 2), "namu_2", Role.VICE_STAFF, null
        );
        List<MemberInfoResponseDTO> memberInfoResponseDTOList = new ArrayList<>();
        memberInfoResponseDTOList.add(memberInfoResponseDTO1);
        memberInfoResponseDTOList.add(memberInfoResponseDTO2);

        PagingResponse pagingResponse = new PagingResponse(
            1, 3, 6
        );

        MemberListResponseDTO memberListResponseDTO = new MemberListResponseDTO(pagingResponse, memberInfoResponseDTOList);


        given(memberService.getMembers(any())).willReturn(memberListResponseDTO);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.get("/member?page={page}&size={size}", 1, 10)
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
                "/member/list",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
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
                    fieldWithPath("data.memberList[].memberId").type(JsonFieldType.NUMBER).description("데이터 정보"),
                    fieldWithPath("data.memberList[].name").type(JsonFieldType.STRING).description("이름"),
                    fieldWithPath("data.memberList[].gender").type(JsonFieldType.STRING).description("성별"),
                    fieldWithPath("data.memberList[].birthDate").type(JsonFieldType.STRING).description("생년월일"),
                    fieldWithPath("data.memberList[].nickname").type(JsonFieldType.STRING).description("닉네임(카카오 닉네임)"),
                    fieldWithPath("data.memberList[].role").type(JsonFieldType.STRING).description("권한 등급"),
                    fieldWithPath("data.memberList[].deletedAt").type(JsonFieldType.STRING).optional().description("삭제일자 (삭제되지 않은 경우 null)")
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
        MemberNameUpdateRequestDTO requestDTO = new MemberNameUpdateRequestDTO("나뭉이");

        doNothing().when(memberService).updateMemberName(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/member/{memberId}/name", 1L)
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
                "member/name/modify",
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
                RestDocumentationRequestBuilders.patch("/member/{memberId}/activate", 1L)
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
                "member/activate",
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
                RestDocumentationRequestBuilders.patch("/member/{memberId}/deactivate", 1L)
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
                "member/deactivate",
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
