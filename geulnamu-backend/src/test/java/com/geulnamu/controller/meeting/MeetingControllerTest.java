package com.geulnamu.controller.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingCreateRequestDTO;
import com.geulnamu.controller.meeting.dto.request.MeetingUpdateRequestDTO;
import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponseDTO;
import com.geulnamu.controller.meeting.dto.response.MeetingListResponseDTO;
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
        MeetingCreateRequestDTO requestDTO = new MeetingCreateRequestDTO(
            "REGULAR", "제 200회 정기모임", LocalDateTime.of(2126, 6, 14, 10, 30), "늦지 않게 오세요~");

        doNothing().when(meetingService).createMeeting(any(), any(), any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                post("/meeting")
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
    @WithMockUser(roles = "MEMBER")
    public void getMeetingListTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        MeetingInfoResponseDTO meetingInfoResponseDTO_01 = new MeetingInfoResponseDTO(
            1L, "나뭉이", MeetingType.REGULAR, LocalDateTime.of(2025, 5, 31, 10, 45),
            "~~", LocalDateTime.of(2025, 5, 1, 12, 30), false);
        MeetingInfoResponseDTO meetingInfoResponseDTO_02 = new MeetingInfoResponseDTO(
            2L, "나뭉이", MeetingType.FLASH, LocalDateTime.of(2025, 6, 3, 18, 30),
            "~~", LocalDateTime.of(2025, 5, 1, 12, 31), false);
        List<MeetingInfoResponseDTO> meetingInfoResponseDTOList = new ArrayList<>();
        meetingInfoResponseDTOList.add(meetingInfoResponseDTO_01);
        meetingInfoResponseDTOList.add(meetingInfoResponseDTO_02);

        PagingResponse pagingResponse = new PagingResponse(
            1, 3, 6);

        MeetingListResponseDTO meetingListResponseDTO = new MeetingListResponseDTO(pagingResponse, meetingInfoResponseDTOList);

        given(meetingService.getMeetingList(any())).willReturn(meetingListResponseDTO);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.get("/meeting/list?page={page}&size={size}", 1, 2)
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
                    fieldWithPath("data.meetingList[].meetingType").type(JsonFieldType.STRING).description("모임 개설자 이름"),
                    fieldWithPath("data.meetingList[].meetingDateTime").type(JsonFieldType.STRING).description("모임 개최일자"),
                    fieldWithPath("data.meetingList[].description").type(JsonFieldType.STRING).description("모임 상세내용").optional(),
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

        MeetingInfoResponseDTO meetingInfoResponseDTO_01 = new MeetingInfoResponseDTO(
            1L, "나뭉이", MeetingType.REGULAR, LocalDateTime.of(2025, 5, 31, 10, 45),
            "~~", LocalDateTime.of(2025, 5, 1, 12, 30), false);
        MeetingInfoResponseDTO meetingInfoResponseDTO_02 = new MeetingInfoResponseDTO(
            2L, "나뭉이", MeetingType.FLASH, LocalDateTime.of(2025, 6, 3, 18, 30),
            "~~", LocalDateTime.of(2025, 5, 1, 12, 31), false);
        List<MeetingInfoResponseDTO> meetingInfoResponseDTOList = new ArrayList<>();
        meetingInfoResponseDTOList.add(meetingInfoResponseDTO_01);
        meetingInfoResponseDTOList.add(meetingInfoResponseDTO_02);

        PagingResponse pagingResponse = new PagingResponse(
            1, 3, 6);

        MeetingListResponseDTO meetingListResponseDTO = new MeetingListResponseDTO(pagingResponse, meetingInfoResponseDTOList);

        given(meetingService.getMeetingListForAdmin(any())).willReturn(meetingListResponseDTO);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.get("/meeting/list/admin?page={page}&size={size}", 1, 2)
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
                    fieldWithPath("data.meetingList[].meetingType").type(JsonFieldType.STRING).description("모임 개설자 이름"),
                    fieldWithPath("data.meetingList[].meetingDateTime").type(JsonFieldType.STRING).description("모임 개최일자"),
                    fieldWithPath("data.meetingList[].description").type(JsonFieldType.STRING).description("모임 상세내용").optional(),
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
        MeetingUpdateRequestDTO requestDTO = new MeetingUpdateRequestDTO(
            null, null, null, "늦지 않게 오세요~");

        doNothing().when(meetingService).updateMeeting(any(), any(), any(), any(), any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/meeting/{meetingId}", 1L)
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

        doNothing().when(meetingService).removeMeeting(any(), any(), any());

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
