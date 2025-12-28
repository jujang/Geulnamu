package com.geulnamu.controller.bookQuestion;

import com.geulnamu.controller.bookQuestion.dto.request.BookQuestionCreateRequest;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionGroupViewResponse;
import com.geulnamu.controller.bookQuestion.dto.response.BookQuestionViewResponse;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.service.bookQuestion.BookQuestionService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
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
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.*;
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.request.RequestDocumentation.*;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(value = BookQuestionController.class)
public class BookQuestionControllerTest extends ControllerTest {

    @MockitoBean
    private BookQuestionService bookQuestionService;


    @Test
    @WithMockUser(roles = "MEMBER")
    public void writeBookQuestionTest() throws Exception {
        // given
        Long bookQuestionId = 1L;
        String accessToken = "Bearer access_token";

        BookQuestionCreateRequest bookQuestionCreateRequest = new BookQuestionCreateRequest("속독하는 본인만의 노하우가 있을까요??");

        given(bookQuestionService.createBookQuestion(any(), any(), any())).willReturn(bookQuestionId);

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.post("/book-questions/create?attendanceId={attendanceId}", 1)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(bookQuestionCreateRequest))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value(bookQuestionId))
            .andDo(document(
                "book-questions/create",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("attendanceId").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("출석 고유번호")
                ),
                requestFields(
                    fieldWithPath("content").type(JsonFieldType.STRING).attributes(key("format").value("255자 이하의 형식 제한 없는 문자열")).description("발제문 내용")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NUMBER).description("발제문 고유번호")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getMyBookQuestionsTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        List<BookQuestionViewResponse> bookQuestionViewResponseList =
            Arrays.asList(
                new BookQuestionViewResponse(1L, 1L, "오늘 점심 뭔가요?"),
                new BookQuestionViewResponse(2L, 1L, "사랑이 뭐라고 생각하시나요?")
            );

        given(bookQuestionService.findMyBookQuestions(any(), any())).willReturn(bookQuestionViewResponseList);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/book-questions/me")
                    .param("attendanceId", "1")
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
                "book-questions/me/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("attendanceId").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("출석 고유번호")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.ARRAY).description("토론 그룹 단위 발제문 리스트"),
                    fieldWithPath("data[].bookQuestionId").type(JsonFieldType.NUMBER).description("발제문 고유번호"),
                    fieldWithPath("data[].writerMemberId").type(JsonFieldType.NUMBER).description("발제문 작성 모임원 고유번호"),
                    fieldWithPath("data[].content").type(JsonFieldType.STRING).description("발제문 내용")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getMyGroupBookQuestions_originTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        List<BookQuestionViewResponse> bookQuestionViewResponseList =
            Arrays.asList(
                new BookQuestionViewResponse(1L, 1L, "오늘 점심 뭔가요?"),
                new BookQuestionViewResponse(2L, 1L, "사랑이 뭐라고 생각하시나요?"),
                new BookQuestionViewResponse(3L, 2L, "속독하는 본인만의 노하우가 있을까요??")
            );

        given(bookQuestionService.findMyDiscussionGroupBookQuestions_origin(any())).willReturn(bookQuestionViewResponseList);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/book-questions/my-group/origin")
                    .param("attendanceId", "1")
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
                "book-questions/my-group/origin/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("attendanceId").attributes(key("type").value(JsonFieldType.NUMBER)).attributes(setAttributes("1 이상의 정수")).description("출석 고유번호")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.ARRAY).description("토론 그룹 단위 발제문 리스트"),
                    fieldWithPath("data[].bookQuestionId").type(JsonFieldType.NUMBER).description("발제문 고유번호"),
                    fieldWithPath("data[].writerMemberId").type(JsonFieldType.NUMBER).description("발제문 작성 모임원 고유번호"),
                    fieldWithPath("data[].content").type(JsonFieldType.STRING).description("발제문 내용")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "STAFF")
    public void getMyGroupBookQuestionsTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        List<BookQuestionViewResponse> bookQuestionViewResponseList =
            Arrays.asList(
                new BookQuestionViewResponse(1L, 1L, "오늘 점심 뭔가요?"),
                new BookQuestionViewResponse(2L, 1L, "사랑이 뭐라고 생각하시나요?"),
                new BookQuestionViewResponse(3L, 2L, "속독하는 본인만의 노하우가 있을까요??")
            );

        given(bookQuestionService.findMyDiscussionGroupBookQuestions(any(), any())).willReturn(bookQuestionViewResponseList);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/book-questions/my-group")
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
                "book-questions/my-group/view",
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
                    fieldWithPath("data").type(JsonFieldType.ARRAY).description("토론 그룹 단위 발제문 리스트"),
                    fieldWithPath("data[].bookQuestionId").type(JsonFieldType.NUMBER).description("발제문 고유번호"),
                    fieldWithPath("data[].writerMemberId").type(JsonFieldType.NUMBER).description("발제문 작성 모임원 고유번호"),
                    fieldWithPath("data[].content").type(JsonFieldType.STRING).description("발제문 내용")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void getMeetingBookQuestionsTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        List<BookQuestionGroupViewResponse> bookQuestionGroupViewResponseList =
            Arrays.asList(
                new BookQuestionGroupViewResponse(Arrays.asList(
                    new BookQuestionViewResponse(1L, 1L, "오늘 점심 뭔가요?"),
                    new BookQuestionViewResponse(2L, 1L, "사랑이 뭐라고 생각하시나요?"),
                    new BookQuestionViewResponse(3L, 2L, "속독하는 본인만의 노하우가 있을까요??")
                )),
                new BookQuestionGroupViewResponse(Arrays.asList(
                    new BookQuestionViewResponse(4L, 3L, "하루에 최대 몇 시간까지 책을 읽어보았나요?"),
                    new BookQuestionViewResponse(5L, 4L, "세상이 정의로울 필요가 있을까요?")
                ))
            );

        given(bookQuestionService.findMeetingBookQuestions(any())).willReturn(bookQuestionGroupViewResponseList);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/book-questions/meeting")
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
                "book-questions/meeting/view",
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
                    fieldWithPath("data").type(JsonFieldType.ARRAY).description("모임 단위 발제문 리스트"),
                    fieldWithPath("data[].bookQuestionViewResponseList").type(JsonFieldType.ARRAY).description("토론 그룹 단위 발제문 리스트"),
                    fieldWithPath("data[].bookQuestionViewResponseList[].bookQuestionId").type(JsonFieldType.NUMBER).description("발제문 고유번호"),
                    fieldWithPath("data[].bookQuestionViewResponseList[].writerMemberId").type(JsonFieldType.NUMBER).description("발제문 작성 모임원 고유번호"),
                    fieldWithPath("data[].bookQuestionViewResponseList[].content").type(JsonFieldType.STRING).description("발제문 내용")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void modifyBookQuestionTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        BookQuestionCreateRequest bookQuestionCreateRequest = new BookQuestionCreateRequest("오늘 점심 뭔가요?");

        doNothing().when(bookQuestionService).modifyBookQuestion(any(), any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                patch("/book-questions/{bookQuestionId}", 1)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(bookQuestionCreateRequest))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "book-questions/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("bookQuestionId").attributes(key("format").value("1 이상의 정수")).description("발제문 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("content").type(JsonFieldType.STRING).attributes(key("format").value("255자 이하의 형식 제한 없는 문자열")).description("발제문 내용")
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
    public void removeBookQuestionTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        doNothing().when(bookQuestionService).removeBookQuestion(any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                delete("/book-questions/{bookQuestionId}", 1)
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
                "book-questions/remove",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("bookQuestionId").attributes(key("format").value("1 이상의 정수")).description("발제문 고유번호")
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
