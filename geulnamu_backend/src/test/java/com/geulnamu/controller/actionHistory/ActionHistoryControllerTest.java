package com.geulnamu.controller.actionHistory;

import com.geulnamu.controller.actionHistory.dto.request.ActionHistoryListRequest;
import com.geulnamu.controller.actionHistory.dto.response.ActionHistoryListResponse;
import com.geulnamu.controller.actionHistory.dto.response.ActionHistoryResponse;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.domain.actionHistory.ApiMethod;
import com.geulnamu.domain.shared.enums.ActionStatus;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.service.actionHistory.ActionHistoryService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.payload.JsonFieldType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.ResultActions;

import java.time.LocalDateTime;
import java.util.Arrays;

import static com.geulnamu.common.ApiDocumentUtils.getDocumentRequest;
import static com.geulnamu.common.ApiDocumentUtils.getDocumentResponse;
import static com.geulnamu.infrastructure.format.DocumentOptionalGenerator.setAttributes;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.restdocs.headers.HeaderDocumentation.headerWithName;
import static org.springframework.restdocs.headers.HeaderDocumentation.requestHeaders;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.get;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.queryParameters;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(value = ActionHistoryController.class)
public class ActionHistoryControllerTest extends ControllerTest {

    @MockitoBean
    private ActionHistoryService actionHistoryService;

    @Test
    @WithMockUser(roles = "ADMIN")
    public void getActionHistoriesTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        ActionHistoryListRequest actionHistoryListRequest = new ActionHistoryListRequest(
            "SUCCESS", "MEMBER", "POST", "createdAt", "true", 1, 10
        );

        ActionHistoryListResponse actionHistoryListResponse =
            new ActionHistoryListResponse(
                new PagingResponse(1, 4, 7),
                Arrays.asList(
                    new ActionHistoryResponse(
                        1L, ActionType.ACCOUNT_LOGIN, ActionStatus.FAILURE, 1L, DomainType.LOGIN,
                        null, "~", "~", ApiMethod.POST, "~", 350L,
                        "~", "~", LocalDateTime.of(2025, 6, 27, 14, 0)
                    ),
                    new ActionHistoryResponse(
                        2L, ActionType.ACCOUNT_LOGIN, ActionStatus.FAILURE, 1L, DomainType.LOGIN,
                        null, "~", "~", ApiMethod.POST, "~", 20L,
                        "~", "~", LocalDateTime.of(2025, 6, 27, 14, 2)
                    )
                )
            );

        given(actionHistoryService.getActionHistoryList(any())).willReturn(actionHistoryListResponse);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/action-histories/list")
                    .param("status", "FAILURE")
                    .param("actionDomain", "LOGIN")
                    .param("apiMethod", "POST")
                    .param("sortBy", "createdAt")
                    .param("isAsc", "false")
                    .param("page", "1")
                    .param("size", "2")
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
                "action-histories/list/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("status").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'SUCCESS', 'FAILURE' 중 하나의 값")).description("응답 상태").optional(),
                    parameterWithName("actionDomain").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'LOGIN', 'MEMBER', 'MEETING', 'ATTENDANCE', 'BOOK_QUESTION', 'VOC', 'ACTION_HISTORY' 중 하나의 값")).description("활동 유형").optional(),
                    parameterWithName("apiMethod").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'POST', 'GET', 'PATCH', 'DELETE' 중 하나의 값")).description("API 유형").optional(),
                    parameterWithName("sortBy").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'id', 'processingTimeMs', 'createdAt' 중 하나의 값")).description("페이지네이션 정렬 기준 (id는 action_history_id를 뜻함)").optional(),
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
                    fieldWithPath("data.actionHistoryResponseList[]").type(JsonFieldType.ARRAY).description("데이터 정보"),
                    fieldWithPath("data.actionHistoryResponseList[].actionHistoryId").type(JsonFieldType.NUMBER).description("활동내역 고유번호"),
                    fieldWithPath("data.actionHistoryResponseList[].actionType").type(JsonFieldType.STRING).description("활동 내용"),
                    fieldWithPath("data.actionHistoryResponseList[].status").type(JsonFieldType.STRING).description("응답 상태"),
                    fieldWithPath("data.actionHistoryResponseList[].actorMemberId").type(JsonFieldType.NUMBER).description("활동 모임원 고유번호").optional(),
                    fieldWithPath("data.actionHistoryResponseList[].actionDomain").type(JsonFieldType.STRING).description("활동 유형"),
                    fieldWithPath("data.actionHistoryResponseList[].targetId").type(JsonFieldType.NUMBER).description("활동 대상 모임원 고유번호").optional(),
                    fieldWithPath("data.actionHistoryResponseList[].requestData").type(JsonFieldType.STRING).description("요청 내용").optional(),
                    fieldWithPath("data.actionHistoryResponseList[].responseData").type(JsonFieldType.STRING).description("응답 내용"),
                    fieldWithPath("data.actionHistoryResponseList[].requestMethod").type(JsonFieldType.STRING).description("요청 API 유형"),
                    fieldWithPath("data.actionHistoryResponseList[].requestURI").type(JsonFieldType.STRING).description("요청한 URL"),
                    fieldWithPath("data.actionHistoryResponseList[].processingTimeMs").type(JsonFieldType.NUMBER).description("처리 시간(ms 단위)"),
                    fieldWithPath("data.actionHistoryResponseList[].ipAddress").type(JsonFieldType.STRING).description("ip 주소"),
                    fieldWithPath("data.actionHistoryResponseList[].userAgent").type(JsonFieldType.STRING).description("브라우저 정보"),
                    fieldWithPath("data.actionHistoryResponseList[].createdAt").type(JsonFieldType.STRING).description("활동내역 등록일자")
                )
            ));
    }
}
