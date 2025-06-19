package com.geulnamu.controller.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingCreateRequest;
import com.geulnamu.controller.meeting.dto.request.MeetingGroupUpdateRequest;
import com.geulnamu.controller.meeting.dto.request.MeetingUpdateRequest;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.meeting.dto.response.MeetingListResponse;
import com.geulnamu.controller.meeting.dto.response.StaffResponse;
import com.geulnamu.controller.shared.ControllerTest;
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
        String accessToken = "Bearer access_token";
        MeetingCreateRequest request = new MeetingCreateRequest(
            "REGULAR", "제 200회 정기모임", LocalDateTime.of(2126, 6, 14, 10, 30), "추후 공지 예정 (합정역 주변 카페)", "늦지 않게 오세요~");

        doNothing().when(meetingService).createMeeting(any(), any(), any(), any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                post("/meeting")
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
                "meeting/open",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("meetingType").type(JsonFieldType.STRING).attributes(key("format").value("'REGULAR', 'FLASH', 'SPECIAL' 중 하나의 값")).description("모임 종류"),
                    fieldWithPath("meetingName").type(JsonFieldType.STRING).attributes(key("format").value("한글, 영문, 숫자, 공백 및 일부 특수분자(: / [ ] ( ) ~ _ -)만으로 사용한 1자 이상, 70자 이하")).description("모임 제목"),
                    fieldWithPath("meetingDate").type(JsonFieldType.STRING).attributes(key("format").value("yyyyMMdd HH:mm 형식으로 이뤄진 미래 시간대의 문자열")).description("모임 개최일자"),
                    fieldWithPath("meetingPlace").type(JsonFieldType.STRING).attributes(key("format").value("한글, 영문, 숫자, 공백 및 일부 특수분자(: / [ ] ( ) ~ _ -)만으로 사용한 1자 이상, 255자 이하")).description("모임 장소"),
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
    public void findMeeting() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        MeetingInfoResponse meetingInfoResponse_01 = new MeetingInfoResponse(
            1L, "나뭉이", MeetingType.REGULAR, "1회 정기모임", LocalDateTime.of(2025, 5, 31, 10, 45),
            "추후 공지 예정 (합정역 주변 카페)", "~~", LocalDateTime.of(2025, 5, 31, 12, 0), null,
            LocalDateTime.of(2025, 5, 1, 12, 30), false
        );

        given(meetingService.findMeeting(any())).willReturn(meetingInfoResponse_01);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.get("/meeting/{meetingId}", 1)
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
                "/meeting/view",
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
                    fieldWithPath("data.meetingType").type(JsonFieldType.STRING).description("모임 유형"),
                    fieldWithPath("data.meetingName").type(JsonFieldType.STRING).description("모임 제목"),
                    fieldWithPath("data.meetingDateTime").type(JsonFieldType.STRING).description("모임 개최일자"),
                    fieldWithPath("data.meetingPlace").type(JsonFieldType.STRING).description("모임 장소"),
                    fieldWithPath("data.description").type(JsonFieldType.STRING).description("모임 상세내용").optional(),
                    fieldWithPath("data.discussionTime").type(JsonFieldType.STRING).description("토론 시간").optional(),
                    fieldWithPath("data.alarmMessage").type(JsonFieldType.STRING).description("토론 시작 알림 메세지").optional(),
                    fieldWithPath("data.createdAt").type(JsonFieldType.STRING).optional().description("모임 개설일자"),
                    fieldWithPath("data.isPrivateMeeting").type(JsonFieldType.BOOLEAN).description("비공개 여부")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getStaffListTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        StaffResponse staffResponse_01 = new StaffResponse(1L, "나뭉모임장");
        StaffResponse staffResponse_02 = new StaffResponse(2L, "나순부모임장");
        List<StaffResponse> staffResponseList = new ArrayList<>();
        staffResponseList.add(staffResponse_01);
        staffResponseList.add(staffResponse_02);

        given(meetingService.getStaffList()).willReturn(staffResponseList);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/meeting/list/staff")
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
                "/meeting/list/staff",
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

        MeetingInfoResponse meetingInfoResponse_01 = new MeetingInfoResponse(
            1L, "나뭉이", MeetingType.REGULAR, "1회 정기모임", LocalDateTime.of(2025, 5, 31, 10, 45),
            "합정 빌리프커피로스터리스", "~~", LocalDateTime.of(2025, 5, 31, 12, 0), null,
            LocalDateTime.of(2025, 5, 1, 12, 30), false
        );
        MeetingInfoResponse meetingInfoResponse_02 = new MeetingInfoResponse(
            2L, "나뭉이", MeetingType.FLASH, "금요 독서벙", LocalDateTime.of(2025, 6, 3, 18, 30),
            "합정 저스티나", "~~", LocalDateTime.of(2025, 5, 1, 12, 31), null,
            LocalDateTime.of(2025, 5, 1, 12, 30), false
        );
        List<MeetingInfoResponse> meetingInfoResponseList = new ArrayList<>();
        meetingInfoResponseList.add(meetingInfoResponse_01);
        meetingInfoResponseList.add(meetingInfoResponse_02);

        PagingResponse pagingResponse = new PagingResponse(
            1, 3, 6);

        MeetingListResponse meetingListResponse = new MeetingListResponse(pagingResponse, meetingInfoResponseList);

        given(meetingService.getMeetingList(any())).willReturn(meetingListResponse);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/meeting/list")
                    .param("meetingType", "REGULAR")
                    .param("meetingCreatorId", "1")
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
                "/meeting/list",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("meetingType").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'REGULAR', 'FLASH', 'SPECIAL' 중 하나의 값")).description("모임 종류").optional(),
                    parameterWithName("meetingCreatorId").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("(운영진의) 모임원 고유번호").optional(),
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
                    fieldWithPath("data.meetingList[]").type(JsonFieldType.ARRAY).description("데이터 정보"),
                    fieldWithPath("data.meetingList[].meetingId").type(JsonFieldType.NUMBER).description("모임 고유번호"),
                    fieldWithPath("data.meetingList[].meetingCreatorName").type(JsonFieldType.STRING).description("모임 개설자 이름"),
                    fieldWithPath("data.meetingList[].meetingType").type(JsonFieldType.STRING).description("모임 유형"),
                    fieldWithPath("data.meetingList[].meetingName").type(JsonFieldType.STRING).description("모임 제목"),
                    fieldWithPath("data.meetingList[].meetingDateTime").type(JsonFieldType.STRING).description("모임 개최일자"),
                    fieldWithPath("data.meetingList[].meetingPlace").type(JsonFieldType.STRING).description("모임 장소"),
                    fieldWithPath("data.meetingList[].description").type(JsonFieldType.STRING).description("모임 상세내용").optional(),
                    fieldWithPath("data.meetingList[].discussionTime").type(JsonFieldType.STRING).description("토론 시간").optional(),
                    fieldWithPath("data.meetingList[].alarmMessage").type(JsonFieldType.STRING).description("토론 시작 알림 메세지").optional(),
                    fieldWithPath("data.meetingList[].createdAt").type(JsonFieldType.STRING).optional().description("모임 개설일자"),
                    fieldWithPath("data.meetingList[].isPrivateMeeting").type(JsonFieldType.BOOLEAN).description("비공개 여부")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void getMeetingListForAdminLevelTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        MeetingInfoResponse meetingInfoResponse_01 = new MeetingInfoResponse(
            1L, "나뭉이", MeetingType.REGULAR, "1회 정기모임", LocalDateTime.of(2025, 5, 31, 10, 45),
            "합정 빌리프커피로스터리스", "~~", LocalDateTime.of(2025, 5, 31, 12, 0), null,
            LocalDateTime.of(2025, 5, 1, 12, 30), false
        );
        MeetingInfoResponse meetingInfoResponse_02 = new MeetingInfoResponse(
            2L, "나뭉이", MeetingType.FLASH, "금요 독서벙", LocalDateTime.of(2025, 6, 3, 18, 30),
            "합정 저스티나", "~~", LocalDateTime.of(2025, 5, 1, 12, 31), null,
            LocalDateTime.of(2025, 5, 1, 12, 30), false
        );
        List<MeetingInfoResponse> meetingInfoResponseList = new ArrayList<>();
        meetingInfoResponseList.add(meetingInfoResponse_01);
        meetingInfoResponseList.add(meetingInfoResponse_02);

        PagingResponse pagingResponse = new PagingResponse(
            1, 3, 6);

        MeetingListResponse meetingListResponse = new MeetingListResponse(pagingResponse, meetingInfoResponseList);

        given(meetingService.getMeetingListForAdmin(any())).willReturn(meetingListResponse);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/meeting/list/admin")
                    .param("meetingType", "REGULAR")
                    .param("meetingCreatorId", "1")
                    .param("isPrivate", "true")
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
                "/meeting/list/admin",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("meetingType").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'REGULAR', 'FLASH', 'SPECIAL' 중 하나의 값")).description("모임 종류").optional(),
                    parameterWithName("meetingCreatorId").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("(운영진의) 모임원 고유번호").optional(),
                    parameterWithName("isPrivate").attributes(key("type").value(JsonFieldType.BOOLEAN)).attributes(setAttributes("'true', 'false' 중 하나의 값")).description("모임 비공개 여부").optional(),
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
                    fieldWithPath("data.meetingList[]").type(JsonFieldType.ARRAY).description("데이터 정보"),
                    fieldWithPath("data.meetingList[].meetingId").type(JsonFieldType.NUMBER).description("모임 고유번호"),
                    fieldWithPath("data.meetingList[].meetingCreatorName").type(JsonFieldType.STRING).description("모임 개설자 이름"),
                    fieldWithPath("data.meetingList[].meetingType").type(JsonFieldType.STRING).description("모임 유형"),
                    fieldWithPath("data.meetingList[].meetingName").type(JsonFieldType.STRING).description("모임 제목"),
                    fieldWithPath("data.meetingList[].meetingDateTime").type(JsonFieldType.STRING).description("모임 개최일자"),
                    fieldWithPath("data.meetingList[].meetingPlace").type(JsonFieldType.STRING).description("모임 장소"),
                    fieldWithPath("data.meetingList[].description").type(JsonFieldType.STRING).description("모임 상세내용").optional(),
                    fieldWithPath("data.meetingList[].discussionTime").type(JsonFieldType.STRING).description("토론 시간").optional(),
                    fieldWithPath("data.meetingList[].alarmMessage").type(JsonFieldType.STRING).description("토론 시작 알림 메세지").optional(),
                    fieldWithPath("data.meetingList[].createdAt").type(JsonFieldType.STRING).optional().description("모임 개설일자"),
                    fieldWithPath("data.meetingList[].isPrivateMeeting").type(JsonFieldType.BOOLEAN).description("비공개 여부")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "STAFF")
    public void updateMeetingTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MeetingUpdateRequest request = new MeetingUpdateRequest(
            null, null, null, "합정 저스티나", "늦지 않게 오세요~"
        );

        doNothing().when(meetingService).updateMeeting(any(), any(), any(), any(), any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/meeting/{meetingId}", 1L)
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
                "meeting/modify",
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
                    fieldWithPath("meetingName").type(JsonFieldType.STRING).attributes(key("format").value("한글, 영문, 숫자, 공백 및 일부 특수분자(: / [ ] ( ) ~ _ -)만으로 사용한 1자 이상, 70자 이하")).description("모임 제목").optional(),
                    fieldWithPath("meetingDate").type(JsonFieldType.STRING).attributes(key("format").value("yyyyMMdd HH:mm 형식으로 이뤄진 미래 시간대의 문자열")).description("모임 개최일자").optional(),
                    fieldWithPath("meetingPlace").type(JsonFieldType.STRING).attributes(key("format").value("한글, 영문, 숫자, 공백 및 일부 특수분자(: / [ ] ( ) ~ _ -)만으로 사용한 1자 이상, 255자 이하")).description("모임 장소").optional(),
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
            LocalDateTime.of(2026, 5, 1, 12, 30), "모두 올라와주세요~"
        );

        doNothing().when(meetingService).updateMeetingForDiscussion(any(), any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/meeting/{meetingId}/discussion", 1L)
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
                "meeting/modify/discussion",
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
                RestDocumentationRequestBuilders.patch("/meeting/{meetingId}/private", 1L)
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
                "meeting/private",
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
                RestDocumentationRequestBuilders.patch("/meeting/{meetingId}/public", 1L)
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
                "meeting/public",
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

        doNothing().when(meetingService).removeMeeting(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.delete("/meeting/{meetingId}", 1L)
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
                "meeting/remove",
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
