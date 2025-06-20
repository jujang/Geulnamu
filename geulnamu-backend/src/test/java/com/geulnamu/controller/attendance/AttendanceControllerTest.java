package com.geulnamu.controller.attendance;

import com.geulnamu.controller.attendance.dto.request.AttendanceNoteRequest;
import com.geulnamu.controller.attendance.dto.response.AttendanceInfoResponse;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.domain.meeting.MeetingType;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.service.attendance.AttendanceService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.restdocs.payload.JsonFieldType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.ResultActions;

import java.time.LocalDateTime;

import static com.geulnamu.common.ApiDocumentUtils.getDocumentRequest;
import static com.geulnamu.common.ApiDocumentUtils.getDocumentResponse;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.springframework.restdocs.headers.HeaderDocumentation.headerWithName;
import static org.springframework.restdocs.headers.HeaderDocumentation.requestHeaders;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(value = AttendanceController.class)
public class AttendanceControllerTest extends ControllerTest {

    @MockitoBean
    private AttendanceService attendanceService;


    @Test
    @WithMockUser(roles = "MEMBER")
    public void meetingAttendTest() throws Exception  {
        // given
        Long attendanceId = 1L;
        String accessToken = "Bearer access_token";

        given(attendanceService.createAttendance(any(), any())).willReturn(attendanceId);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.post("/attendance/{meetingId}", 1)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value(attendanceId))
            .andDo(document(
                "attendance/create",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("meetingId").attributes(key("format").value("1 이상의 정수")).description("모임 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NUMBER).description("출석 고유번호")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getAttendanceInfoTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        AttendanceInfoResponse attendanceInfoResponse = new AttendanceInfoResponse(
            1L, MeetingType.REGULAR, LocalDateTime.of(2126, 6, 14, 10, 30),
            LocalDateTime.of(2126, 6, 14, 10, 45), "1000회 정기모임",
            "합정 저스티나", "조심히 오세요~", "1등으로 왔지롱~",
            LocalDateTime.of(2126, 6, 14, 12, 0), null,
            LocalDateTime.of(2126, 6, 13, 20, 0)
        );

        given(attendanceService.getAttendanceInfo(any(), any())).willReturn(attendanceInfoResponse);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.get("/attendance/{attendanceId}", 1L)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
            );

        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andDo(document(
                "/attendance/view",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("attendanceId").attributes(key("format").value("1 이상의 정수")).description("참석 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data.attendanceId").type(JsonFieldType.NUMBER).description("참석 고유번호"),
                    fieldWithPath("data.meetingType").type(JsonFieldType.STRING).description("모임 유형"),
                    fieldWithPath("data.meetingDateTime").type(JsonFieldType.STRING).description("모임 개최일자"),
                    fieldWithPath("data.lateThresholdTime").type(JsonFieldType.STRING).description("지각 기준 시간"),
                    fieldWithPath("data.meetingName").type(JsonFieldType.STRING).description("모임 제목"),
                    fieldWithPath("data.meetingPlace").type(JsonFieldType.STRING).description("모임 장소"),
                    fieldWithPath("data.description").type(JsonFieldType.STRING).description("모임 상세내용").optional(),
                    fieldWithPath("data.note").type(JsonFieldType.STRING).description("참석 관련 비고").optional(),
                    fieldWithPath("data.discussionTime").type(JsonFieldType.STRING).description("토론 시간").optional(),
                    fieldWithPath("data.groupMemberList").type(JsonFieldType.STRING).description("토론 조 명단").optional(),
                    fieldWithPath("data.createdAt").type(JsonFieldType.STRING).optional().description("모임 개설일자")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void writeNoteTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        AttendanceNoteRequest request = new AttendanceNoteRequest("지각 안 했는데요!");

        doNothing().when(attendanceService).writeNote(any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/attendance/{attendanceId}/note", 1L)
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
                "attendance/modify/note",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("attendanceId").attributes(key("format").value("1 이상의 정수")).description("출석 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("note").type(JsonFieldType.STRING).attributes(key("format").value("한글, 영문, 숫자, 공백 및 일부 특수분자(: / [ ] ( ) ~ _ ! ? . , ; -)만으로 사용한 1자 이상, 255자 이하의 문자열")).description("비고(출석 관련 사유 작성)")
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
    public void notWantDiscussionTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(attendanceService).notWantDiscussion(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/attendance/{attendanceId}/just-read", 1L)
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
                "attendance/modify/just-read",
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
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void wantDiscussionTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(attendanceService).wantDiscussion(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/attendance/{attendanceId}/want-discussion", 1L)
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
                "attendance/modify/want-discussion",
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
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void DeleteMeetingAttendTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(attendanceService).deleteAttendance(any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.delete("/attendance/{attendanceId}/delete", 1)
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
                "attendance/delete",
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
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

}
