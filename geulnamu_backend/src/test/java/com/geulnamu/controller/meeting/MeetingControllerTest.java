package com.geulnamu.controller.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingCreateRequest;
import com.geulnamu.controller.meeting.dto.request.MeetingGroupUpdateRequest;
import com.geulnamu.controller.meeting.dto.request.MeetingUpdateRequest;
import com.geulnamu.controller.meeting.dto.response.*;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.meeting.MeetingType;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.service.meeting.MeetingService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.restdocs.payload.JsonFieldType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.ResultActions;

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
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.post;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.get;
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.request.RequestDocumentation.*;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(value = MeetingController.class)
public class MeetingControllerTest extends ControllerTest {

    @MockitoBean
    private MeetingService meetingService;


    @Test
    @WithMockUser(roles = "STAFF")
    public void createMeetingTest() throws Exception {
        // given
        Long meetingId = 1L;
        String accessToken = "Bearer access_token";
        MeetingCreateRequest request = new MeetingCreateRequest("REGULAR", "제 200회 정기모임",
            LocalDateTime.of(2126, 6, 14, 10, 30),
            LocalDateTime.of(2126, 6, 14, 10, 45),
            "추후 공지 예정 (합정역 주변 카페)", "늦지 않게 오세요~");

        given(meetingService.createMeeting(any(), any())).willReturn(meetingId);

        // when
        ResultActions actions =
            mockMvc.perform(
                post("/meetings/create")
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
            .andExpect(jsonPath("data").value(meetingId))
            .andDo(document(
                "meetings/create",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("meetingType").type(JsonFieldType.STRING).attributes(key("format").value("'REGULAR', 'FLASH', 'SPECIAL' 중 하나의 값")).description("모임 종류"),
                    fieldWithPath("meetingName").type(JsonFieldType.STRING).attributes(key("format").value("한글, 영문, 숫자, 공백 및 일부 특수문자(: / @ [ ] ( ) ~ _ -)만으로 사용한 1자 이상, 70자 이하")).description("모임 제목"),
                    fieldWithPath("meetingDate").type(JsonFieldType.STRING).attributes(key("format").value("yyyyMMdd HH:mm 형식으로 이뤄진 미래 시간대의 문자열")).description("모임 개최일자"),
                    fieldWithPath("lateThresholdTime").type(JsonFieldType.STRING).attributes(key("format").value("yyyyMMdd HH:mm 형식으로 이뤄진 미래 시간대의 문자열")).description("지각 기준 시간(모임 개최일자보다 빠르면 안 됨. 입력 안 할 시 모임 개최시간과 동일값 처리)").optional(),
                    fieldWithPath("meetingPlace").type(JsonFieldType.STRING).attributes(key("format").value("한글, 영문, 숫자, 공백 및 일부 특수문자(: / @ [ ] ( ) ~ _ -)만으로 사용한 1자 이상, 255자 이하")).description("모임 장소"),
                    fieldWithPath("description").type(JsonFieldType.STRING).attributes(key("format").value("형식, 길이 제한 없는 문자열")).description("상세 내용").optional()
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NUMBER).description("모임 고유번호")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getStaffListTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        List<MemberIdAndNameResponse> memberIdAndNameResponseList =
            Arrays.asList(
                new MemberIdAndNameResponse(1L, "나뭉모임장"),
                new MemberIdAndNameResponse(2L, "나순부모임장")
            );

        given(meetingService.getStaffList()).willReturn(memberIdAndNameResponseList);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/meetings/staff-list")
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
                "meetings/staff-list/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data[].memberId").type(JsonFieldType.NUMBER).description("모임원 고유번호"),
                    fieldWithPath("data[].memberName").type(JsonFieldType.STRING).description("모임 개설자 이름")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getMeetingListTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MeetingListResponse meetingListResponse =
            new MeetingListResponse(
                new PagingResponse(1, 3, 6),
                Arrays.asList(
                    new MeetingInfoResponse(
                        1L, "나뭉이", 1L, MeetingType.REGULAR, "1회 정기모임",
                        LocalDateTime.of(2025, 5, 31, 10, 30),
                        "합정 빌리프커피로스터리스", "~~",
                        LocalDateTime.of(2025, 5, 31, 12, 0), false
                    ),
                    new MeetingInfoResponse(
                        2L, "나뭉이", 1L, MeetingType.FLASH, "금요 독서벙",
                        LocalDateTime.of(2025, 6, 3, 18, 30),
                        "합정 저스티나", "~~",
                        LocalDateTime.of(2025, 5, 1, 12, 31), true
                    )
                )
            );

        given(meetingService.getMeetingList(any(), any())).willReturn(meetingListResponse);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/meetings/list")
                    .param("meetingType", "REGULAR")
                    .param("isTodayMeeting", "true")
                    .param("attendanceStatus", "ATTEND")
                    .param("isPrivate", "false")
                    .param("sortBy", "meetingDate")
                    .param("isAsc", "false")
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
                "meetings/list/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("meetingType").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'REGULAR', 'FLASH', 'SPECIAL' 중 하나의 값")).description("모임 종류").optional(),
                    parameterWithName("isTodayMeeting").attributes(key("type").value(JsonFieldType.BOOLEAN)).attributes(setAttributes("'true', 'false' 중 하나의 값")).description("오늘자 모임만 조회 여부").optional(),
                    parameterWithName("attendanceStatus").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'NOT_STARTED', 'ATTEND', 'ATTEND_LATE', 'NOT_ATTEND' 중 하나의 값")).description("출석 상태").optional(),
                    parameterWithName("isPrivate").attributes(key("type").value(JsonFieldType.BOOLEAN)).attributes(setAttributes("'true', 'false' 중 하나의 값")).description("모임 비공개 여부").optional(),
                    parameterWithName("sortBy").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'meetingDate', 'id' 중 하나의 값")).description("페이지네이션 정렬 기준 (id는 meetingId를 뜻함)").optional(),
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
                    fieldWithPath("data.meetingList[]").type(JsonFieldType.ARRAY).description("데이터 정보").optional(),
                    fieldWithPath("data.meetingList[].meetingId").type(JsonFieldType.NUMBER).description("모임 고유번호"),
                    fieldWithPath("data.meetingList[].meetingCreatorName").type(JsonFieldType.STRING).description("모임 개설자 이름"),
                    fieldWithPath("data.meetingList[].meetingCreatorId").type(JsonFieldType.NUMBER).description("모임 개설자 고유번호"),
                    fieldWithPath("data.meetingList[].meetingType").type(JsonFieldType.STRING).description("모임 유형"),
                    fieldWithPath("data.meetingList[].meetingName").type(JsonFieldType.STRING).description("모임 제목"),
                    fieldWithPath("data.meetingList[].meetingDateTime").type(JsonFieldType.STRING).description("모임 개최일자"),
                    fieldWithPath("data.meetingList[].meetingPlace").type(JsonFieldType.STRING).description("모임 장소"),
                    fieldWithPath("data.meetingList[].attendanceStatus").type(JsonFieldType.STRING).description("출석 상태"),
                    fieldWithPath("data.meetingList[].discussionTime").type(JsonFieldType.STRING).description("토론 시간").optional(),
                    fieldWithPath("data.meetingList[].isPrivate").type(JsonFieldType.BOOLEAN).description("모임 비공개 여부")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "STAFF")
    public void findMeetingTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        MeetingDetailResponse meetingDetailResponse_01 = new MeetingDetailResponse(
            1L, "나뭉이", 1L, MeetingType.REGULAR, "1회 정기모임",
            LocalDateTime.of(2025, 5, 31, 10, 30),
            LocalDateTime.of(2025, 5, 31, 10, 45), "추후 공지 예정 (합정역 주변 카페)",
            "~~", LocalDateTime.of(2025, 5, 1, 12, 0),
            5L, "~~", "저 안 늦었어요",
            LocalDateTime.of(2025, 5, 12, 12, 0), null, true,
            null, null
        );

        given(meetingService.getMeeting(any(), any())).willReturn(meetingDetailResponse_01);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.get("/meetings/{meetingId}", 1)
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
                "meetings/detail/view",
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
                    fieldWithPath("data.meetingId").type(JsonFieldType.NUMBER).description("모임 고유번호"),
                    fieldWithPath("data.meetingCreatorName").type(JsonFieldType.STRING).description("모임 개설자 이름"),
                    fieldWithPath("data.meetingCreatorId").type(JsonFieldType.NUMBER).description("모임 개설자 고유번호"),
                    fieldWithPath("data.meetingType").type(JsonFieldType.STRING).description("모임 유형"),
                    fieldWithPath("data.meetingName").type(JsonFieldType.STRING).description("모임 제목"),
                    fieldWithPath("data.meetingDateTime").type(JsonFieldType.STRING).description("모임 개최일자"),
                    fieldWithPath("data.lateThresholdTime").type(JsonFieldType.STRING).description("지각 기준 시간"),
                    fieldWithPath("data.meetingPlace").type(JsonFieldType.STRING).description("모임 장소"),
                    fieldWithPath("data.description").type(JsonFieldType.STRING).description("모임 상세내용").optional(),
                    fieldWithPath("data.createdAt").type(JsonFieldType.STRING).optional().description("모임 개설일자"),
                    fieldWithPath("data.attendanceId").type(JsonFieldType.NUMBER).description("출석 고유번호").optional(),
                    fieldWithPath("data.attendanceStatus").type(JsonFieldType.STRING).description("출석 상태").optional(),
                    fieldWithPath("data.note").type(JsonFieldType.STRING).description("출석 비고").optional(),
                    fieldWithPath("data.discussionTime").type(JsonFieldType.STRING).description("토론 시간").optional(),
                    fieldWithPath("data.alarmMessage").type(JsonFieldType.STRING).description("토론 시작 알림 메세지").optional(),
                    fieldWithPath("data.wantDiscussion").type(JsonFieldType.BOOLEAN).description("비공개 여부").optional(),
                    fieldWithPath("data.discussionGroup").type(JsonFieldType.STRING).description("토론 조").optional(),
                    fieldWithPath("data.groupMemberList").type(JsonFieldType.ARRAY).description("같은 토론 조 리스트").optional(),
                    fieldWithPath("data.groupMemberList[].memberId").type(JsonFieldType.NUMBER).description("모임원 고유번호").optional(),
                    fieldWithPath("data.groupMemberList[].memberName").type(JsonFieldType.STRING).description("모임원 이름").optional()
                )
            ));
    }

    @Test
    @WithMockUser(roles = "STAFF")
    public void findMeetingForStaffTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        MeetingDetailResponseForStaff meetingDetailResponseForStaff_01 = new MeetingDetailResponseForStaff(
            1L, "나뭉이", 1L, MeetingType.REGULAR, "1회 정기모임",
            LocalDateTime.of(2025, 5, 31, 10, 30),
            LocalDateTime.of(2025, 5, 31, 10, 45), "추후 공지 예정 (합정역 주변 카페)",
            "~~", LocalDateTime.of(2025, 5, 1, 12, 0), false,
            LocalDateTime.of(2025, 5, 12, 12, 0), null
        );

        given(meetingService.getMeetingForStaff(any())).willReturn(meetingDetailResponseForStaff_01);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.get("/meetings/{meetingId}/staff", 1)
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
                "meetings/detail/staff/view",
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
                    fieldWithPath("data.meetingId").type(JsonFieldType.NUMBER).description("모임 고유번호"),
                    fieldWithPath("data.meetingCreatorName").type(JsonFieldType.STRING).description("모임 개설자 이름"),
                    fieldWithPath("data.meetingCreatorId").type(JsonFieldType.NUMBER).description("모임 개설자 고유번호"),
                    fieldWithPath("data.meetingType").type(JsonFieldType.STRING).description("모임 유형"),
                    fieldWithPath("data.meetingName").type(JsonFieldType.STRING).description("모임 제목"),
                    fieldWithPath("data.meetingDateTime").type(JsonFieldType.STRING).description("모임 개최일자"),
                    fieldWithPath("data.lateThresholdTime").type(JsonFieldType.STRING).description("지각 기준 시간"),
                    fieldWithPath("data.meetingPlace").type(JsonFieldType.STRING).description("모임 장소"),
                    fieldWithPath("data.description").type(JsonFieldType.STRING).description("모임 상세내용").optional(),
                    fieldWithPath("data.createdAt").type(JsonFieldType.STRING).optional().description("모임 개설일자"),
                    fieldWithPath("data.isPrivateMeeting").type(JsonFieldType.BOOLEAN).description("비공개 여부"),
                    fieldWithPath("data.discussionTime").type(JsonFieldType.STRING).description("토론 시간").optional(),
                    fieldWithPath("data.alarmMessage").type(JsonFieldType.STRING).description("토론 시작 알림 메세지").optional()
                )
            ));
    }

    @Test
    @WithMockUser(roles = "STAFF")
    public void updateMeetingTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MeetingUpdateRequest request = new MeetingUpdateRequest(
            null, null, null, null, "합정 저스티나", "늦지 않게 오세요~"
        );

        doNothing().when(meetingService).updateMeeting(any(), any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/meetings/{meetingId}/basic", 1L)
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
                "meetings/basic/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("meetingId").attributes(key("format").value("1 이상의 정수")).description("모임 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("meetingType").type(JsonFieldType.STRING).attributes(key("format").value("'REGULAR', 'FLASH', 'SPECIAL' 중 하나의 값")).description("모임 종류").optional(),
                    fieldWithPath("meetingName").type(JsonFieldType.STRING).attributes(key("format").value("한글, 영문, 숫자, 공백 및 일부 특수문자(: / @ [ ] ( ) ~ _ -)만으로 사용한 1자 이상, 70자 이하의 문자열")).description("모임 제목").optional(),
                    fieldWithPath("meetingDate").type(JsonFieldType.STRING).attributes(key("format").value("yyyyMMdd HH:mm 형식으로 이뤄진 미래 시간대의 문자열")).description("모임 개최일자").optional(),
                    fieldWithPath("lateThresholdTime").type(JsonFieldType.STRING).attributes(key("format").value("yyyyMMdd HH:mm 형식으로 이뤄진 미래 시간대의 문자열")).description("지각 기준 시간(모임 개최 시간보다 빠르면 안 됨)").optional(),
                    fieldWithPath("meetingPlace").type(JsonFieldType.STRING).attributes(key("format").value("한글, 영문, 숫자, 공백 및 일부 특수문자(: / @ [ ] ( ) ~ _ -)만으로 사용한 1자 이상, 255자 이하의 문자열")).description("모임 장소").optional(),
                    fieldWithPath("description").type(JsonFieldType.STRING).attributes(key("format").value("형식, 길이 제한 없는 문자열")).description("상세 내용").optional()
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "STAFF")
    public void updateMeetingForDiscussionTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MeetingGroupUpdateRequest request = new MeetingGroupUpdateRequest(
            LocalDateTime.of(2026, 5, 1, 12, 30), null,"모두 올라와주세요~"
        );

        doNothing().when(meetingService).updateMeetingForDiscussion(any(), any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/meetings/{meetingId}/discussion", 1L)
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
                "meetings/discussion/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("meetingId").attributes(key("format").value("1 이상의 정수")).description("모임 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("discussionTime").type(JsonFieldType.STRING).attributes(key("format").value("yyyyMMdd HH:mm 형식으로 이뤄진 미래 시간대의 문자열")).description("토론 시간").optional(),
                    fieldWithPath("discussionTimeNull").type(JsonFieldType.BOOLEAN).attributes(key("format").value("true 또는 false 중 하나의 값")).description("토론 시간 초기화 플래그").optional(),
                    fieldWithPath("alarmMessage").type(JsonFieldType.STRING).attributes(key("format").value("형식제한 없는 최대 255자 이하의 문자열")).description("토론 시작 알림용 메세지").optional()
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
    public void makeMeetingPrivateTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(meetingService).makeMeetingPrivate(any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/meetings/{meetingId}/make-private", 1L)
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
                "meetings/make-private/modify",
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
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void makeMeetingPublicTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(meetingService).makeMeetingPublic(any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/meetings/{meetingId}/make-public", 1L)
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
                "meetings/make-public/modify",
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
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "STAFF")
    public void removeMeetingTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(meetingService).removeMeeting(any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.delete("/meetings/{meetingId}/remove", 1L)
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
                "meetings/remove",
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
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

}
