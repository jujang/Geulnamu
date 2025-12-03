package com.geulnamu.controller.attendance;

import com.geulnamu.controller.attendance.dto.request.AssignDiscussionGroupsRequest;
import com.geulnamu.controller.attendance.dto.request.DiscussionGroupRequest;
import com.geulnamu.controller.attendance.dto.response.DiscussionGroupResponse;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.controller.shared.dto.response.AttendanceIdAndNameResponse;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.service.attendance.AttendanceService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.payload.JsonFieldType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.ResultActions;

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
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.get;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.patch;
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.request.RequestDocumentation.*;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(value = DiscussionController.class)
public class DiscussionControllerTest extends ControllerTest {

    @MockitoBean
    private AttendanceService attendanceService;


    @Test
    @WithMockUser(roles = "STAFF")
    public void getWantDiscussionMemberListTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        List<AttendanceIdAndNameResponse> attendanceIdAndNameResponseList =
            Arrays.asList(
                new AttendanceIdAndNameResponse(1L, "나뭉일"),
                new AttendanceIdAndNameResponse(2L, "나뭉이")
            );

        given(attendanceService.getWantDiscussionMemberList(any())).willReturn(attendanceIdAndNameResponseList);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/discussions/list/want-discussion")
                    .param("meetingId", "1")
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
                "/discussions/list/want-discussion/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("meetingId").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("모임 고유번호")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.ARRAY).description("토론 참여 희망자 명단"),
                    fieldWithPath("data[].attendanceId").type(JsonFieldType.NUMBER).description("출석 고유번호"),
                    fieldWithPath("data[].memberName").type(JsonFieldType.STRING).description("모임원 이름")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getMyDiscussionGroupMemberListTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        List<AttendanceIdAndNameResponse> attendanceIdAndNameResponseList =
            Arrays.asList(
                new AttendanceIdAndNameResponse(1L, "나뭉일"),
                new AttendanceIdAndNameResponse(2L, "나뭉이")
            );

        given(attendanceService.getMyDiscussionMemberList(any(), any())).willReturn(attendanceIdAndNameResponseList);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/discussions/{attendanceId}/my-group", 1)
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
                "/discussions/my-group/view",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("attendanceId").attributes(key("format").value("1 이상의 정수")).description("출석 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.ARRAY).description("토론 참여 희망자 명단"),
                    fieldWithPath("data[].attendanceId").type(JsonFieldType.NUMBER).description("출석 고유번호"),
                    fieldWithPath("data[].memberName").type(JsonFieldType.STRING).description("모임원 이름")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getAllDiscussionGroupMemberListTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        List<DiscussionGroupResponse> discussionGroupResponseList =
            Arrays.asList(
                new DiscussionGroupResponse(Arrays.asList(
                    new AttendanceIdAndNameResponse(1L, "나뭉일"),
                    new AttendanceIdAndNameResponse(2L, "나뭉이")
                )),
                new DiscussionGroupResponse(Arrays.asList(
                    new AttendanceIdAndNameResponse(3L, "나뭉삼"),
                    new AttendanceIdAndNameResponse(4L, "나뭉사")
                ))
            );

        given(attendanceService.getAllDiscussionGroupMemberList(any())).willReturn(discussionGroupResponseList);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/discussions/groups?meetingId={meetingId}", 1)
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
                "/discussions/groups/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("meetingId").attributes(key("type").value(JsonFieldType.NUMBER))
                        .attributes(setAttributes("1 이상의 정수")).description("모임 고유번호")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.ARRAY).description("토론 참여 희망자 명단"),
                    fieldWithPath("data[]").type(JsonFieldType.ARRAY).description("전체 토론 그룹"),
                    fieldWithPath("data[].attendanceIdAndNameResponseList").type(JsonFieldType.ARRAY).description("토론 그룹별 명단"),
                    fieldWithPath("data[].attendanceIdAndNameResponseList[].attendanceId").type(JsonFieldType.NUMBER).description("출석 고유번호"),
                    fieldWithPath("data[].attendanceIdAndNameResponseList[].memberName").type(JsonFieldType.STRING).description("모임원 이름")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "STAFF")
    public void manuallyAssignDiscussionGroupsTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        AssignDiscussionGroupsRequest request = new AssignDiscussionGroupsRequest(
            Arrays.asList(
                new DiscussionGroupRequest(Arrays.asList(1L, 10L)),
                new DiscussionGroupRequest(Arrays.asList(2L, 20L))
            )
        );

        doNothing().when(attendanceService).manuallyAssignDiscussionGroups(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                patch("/discussions/groups/assign?meetingId={meetingId}", 1)
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
            .andDo(document(
                "/discussions/groups/assign/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("meetingId").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("모임 고유번호")
                ),
                requestFields(
                    fieldWithPath("groups[]").type(JsonFieldType.ARRAY).attributes(key("format").value("7개 이하의 리스트를 담고 있는 리스트")).description("전체 그룹(7개 이하)"),
                    fieldWithPath("groups[].attendanceIdList[]").type(JsonFieldType.ARRAY).attributes(key("format").value("1 이상의 정수가 하나 이상 담긴 리스트")).description("출석 고유번호 리스트").optional()
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
    public void manuallyAssignDiscussionGroupTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(attendanceService).assignMemberToDiscussionGroup(any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                patch("/discussions/groups/assign-member" +
                        "?meetingId={meetingId}&attendanceId={attendanceId}&groupNumber={groupNumber}",
                    1, 2, 3)
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
                "/discussions/groups/assign-member/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("meetingId").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("모임 고유번호"),
                    parameterWithName("attendanceId").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("출석 고유번호"),
                    parameterWithName("groupNumber").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상, 7 이하의 정수")).description("그룹 번호")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

}
