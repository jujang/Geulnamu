package com.geulnamu.controller.voc;

import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.controller.voc.dto.request.VoCCreateRequest;
import com.geulnamu.controller.voc.dto.request.VoCManageRequest;
import com.geulnamu.controller.voc.dto.request.VoCViewListRequest;
import com.geulnamu.controller.voc.dto.response.VoCViewListResponse;
import com.geulnamu.controller.voc.dto.response.VoCViewResponse;
import com.geulnamu.domain.voc.IssueStatus;
import com.geulnamu.domain.voc.VoCType;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.service.voc.VoCService;
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
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.request.RequestDocumentation.*;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(value = VoCController.class)
public class VoCControllerTest extends ControllerTest {

    @MockitoBean
    private VoCService voCService;

    @Test
    @WithMockUser(roles = "MEMBER")
    public void reportErrorTest() throws Exception  {
        // given
        String accessToken = "Bearer access_token";

        VoCCreateRequest voCCreateRequest = new VoCCreateRequest("응답이 느려요ㅠㅠ");

        doNothing().when(voCService).reportError(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                post("/voc/error-report")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(voCCreateRequest))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "/voc/error-report/create",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("content").type(JsonFieldType.STRING).attributes(key("format").value("형식, 길이 제한 없는 문자열")).description("내용")
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
    public void requestFeatureTest() throws Exception  {
        // given
        String accessToken = "Bearer access_token";

        VoCCreateRequest voCCreateRequest = new VoCCreateRequest("점심 메뉴 추천 기능은 없나요?");

        doNothing().when(voCService).requestFeature(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                post("/voc/feature-request")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(voCCreateRequest))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "/voc/feature-request/create",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("content").type(JsonFieldType.STRING).attributes(key("format").value("형식, 길이 제한 없는 문자열")).description("내용")
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
    public void getIssueListTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        VoCViewListRequest voCViewListRequest = new VoCViewListRequest(
            "PENDING", "ERROR_REPORT", "createdAt", "true", 1, 2
        );

        VoCViewListResponse voCViewListResponse =
            new VoCViewListResponse(
                new PagingResponse(1, 4, 7),
                Arrays.asList(
                    new VoCViewResponse(
                        1L, 1L, VoCType.ERROR_REPORT, "응답이 느려요~", IssueStatus.PENDING, null,
                        LocalDateTime.of(2025, 6, 27, 18, 0),
                        LocalDateTime.of(2025, 6, 27, 18, 0)
                    ),
                    new VoCViewResponse(
                        1L, 1L, VoCType.FEATURE_REQUEST, "점심 메뉴 추천 기능 만들어주세요!",
                        IssueStatus.IN_PROGRESS, "확인중~",
                        LocalDateTime.of(2025, 6, 27, 18, 10),
                        LocalDateTime.of(2025, 6, 27, 18, 10)
                    )
                )
            );

        given(voCService.getIssueList(any())).willReturn(voCViewListResponse);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/voc/list")
                    .param("issueStatus", "PENDING")
                    .param("voCType", "FEATURE_REQUEST")
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
                "/voc/list/view",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                queryParameters(
                    parameterWithName("issueStatus").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'PENDING', 'IN_PROGRESS', 'RESOLVED', 'REJECTED', 'ON_HOLD' 중 하나의 값")).description("이슈 상태").optional(),
                    parameterWithName("voCType").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'ERROR_REPORT', 'FEATURE_REQUEST' 둘 중 하나의 값")).description("이슈 유형").optional(),
                    parameterWithName("sortBy").attributes(key("type").value(JsonFieldType.STRING)).attributes(setAttributes("'id', 'memberId', 'issueStatus', 'createdAt' 중 하나의 값")).description("페이지네이션 정렬 기준 (id는 voc_id를 뜻함)").optional(),
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
                    fieldWithPath("data.voCViewResponseList[]").type(JsonFieldType.ARRAY).description("데이터 정보"),
                    fieldWithPath("data.voCViewResponseList[].vocId").type(JsonFieldType.NUMBER).description("이슈 고유번호"),
                    fieldWithPath("data.voCViewResponseList[].memberId").type(JsonFieldType.NUMBER).description("이슈 작성 모임원 고유번호"),
                    fieldWithPath("data.voCViewResponseList[].voCType").type(JsonFieldType.STRING).description("이슈 유형"),
                    fieldWithPath("data.voCViewResponseList[].content").type(JsonFieldType.STRING).description("이슈 세부내용"),
                    fieldWithPath("data.voCViewResponseList[].issueStatus").type(JsonFieldType.STRING).description("이슈 상태"),
                    fieldWithPath("data.voCViewResponseList[].adminComment").type(JsonFieldType.STRING).description("관리자 코멘트").optional(),
                    fieldWithPath("data.voCViewResponseList[].createdAt").type(JsonFieldType.STRING).description("이슈 등록일자"),
                    fieldWithPath("data.voCViewResponseList[].lastModifiedAt").type(JsonFieldType.STRING).description("이슈 수정일자")
                )
            ));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void modifyIssueStatusTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";

        VoCManageRequest voCManageRequest = new VoCManageRequest(
            "IN_PROGRESS", "확인중~"
        );

        doNothing().when(voCService).modifyIssueStatus(any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                RestDocumentationRequestBuilders.patch("/voc/{vocId}/status", 1L)
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(voCManageRequest))
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value((Object) null))
            .andDo(document(
                "/voc/status/modify",
                getDocumentRequest(),
                getDocumentResponse(),
                pathParameters(
                    parameterWithName("vocId").attributes(key("format").value("1 이상의 정수")).description("이슈 고유번호")
                ),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("issueStatus").type(JsonFieldType.STRING).attributes(key("format").value("'PENDING', 'IN_PROGRESS', 'RESOLVED', 'REJECTED', 'ON_HOLD' 중 하나의 값")).description("변경할 이슈 상태"),
                    fieldWithPath("adminComment").type(JsonFieldType.STRING).attributes(key("format").value("형식의 제한이 없는 255자 이내의 문자열")).description("관리자 코멘트")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.NULL).description("-")
                )
            ));
    }

}
