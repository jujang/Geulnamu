package com.geulnamu.controller.fcm;

import com.geulnamu.controller.fcm.dto.request.FcmTokenRequest;
import com.geulnamu.controller.fcm.dto.request.NotificationRequest;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.infrastructure.firebase.FcmSendResult;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.service.fcm.FcmService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.payload.JsonFieldType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.ResultActions;

import java.util.Arrays;

import static com.geulnamu.common.ApiDocumentUtils.getDocumentRequest;
import static com.geulnamu.common.ApiDocumentUtils.getDocumentResponse;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.springframework.restdocs.headers.HeaderDocumentation.headerWithName;
import static org.springframework.restdocs.headers.HeaderDocumentation.requestHeaders;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.post;
import static org.springframework.restdocs.payload.PayloadDocumentation.*;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(value = FcmController.class)
public class FcmControllerTest extends ControllerTest {

    @MockitoBean
    private FcmService fcmService;


    @Test
    @WithMockUser(roles = "MEMBER")
    public void registerTokenTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        FcmTokenRequest request = new FcmTokenRequest("fcm_token_123456789", "mobile");

        doNothing().when(fcmService).registerToken(any(), any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                post("/fcm/token")
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
                "fcm/token/register",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("token").type(JsonFieldType.STRING).attributes(key("format").value("255자 이하의 형식 제한 없는 문자열")).description("fcm 토큰값"),
                    fieldWithPath("deviceType").type(JsonFieldType.STRING).attributes(key("format").value("255자 이하의 형식 제한 없는 문자열")).description("기기 유형")
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
    public void sendNotificationTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        NotificationRequest request = new NotificationRequest("title", "body", Arrays.asList(1L, 2L));
        FcmSendResult result = new FcmSendResult(2, 0);

        given(fcmService.sendNotification(any(), any(), any())).willReturn(result);

        // when
        ResultActions actions =
            mockMvc.perform(
                post("/fcm/notification")
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
            .andExpect(jsonPath("data.successCount").value(result.successCount()))
            .andExpect(jsonPath("data.failureCount").value(result.failureCount()))
            .andExpect(jsonPath("data.allSuccess").value(result.isAllSuccess()))
            .andExpect(jsonPath("data.allFailed").value(result.isAllFailed()))
            .andDo(document(
                "fcm/notification/send",
                getDocumentRequest(),
                getDocumentResponse(),
                requestHeaders(
                    headerWithName("Authorization").description("액세스 토큰")
                ),
                requestFields(
                    fieldWithPath("title").type(JsonFieldType.STRING).attributes(key("format").value("형식, 길이 제한 없는 문자열")).description("모임 종류"),
                    fieldWithPath("body").type(JsonFieldType.STRING).attributes(key("format").value("형식, 길이 제한 없는 문자열")).description("모임 제목"),
                    fieldWithPath("memberList[]").type(JsonFieldType.ARRAY).attributes(key("format").value("1 이상의 정수가 하나 이상 담긴 리스트")).description("모임원 고유번호 리스트")
                ),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data.successCount").type(JsonFieldType.NUMBER).description("푸시 전송 성공 카운트"),
                    fieldWithPath("data.failureCount").type(JsonFieldType.NUMBER).description("푸시 전송 실패 카운트"),
                    fieldWithPath("data.allSuccess").type(JsonFieldType.BOOLEAN).description("푸시 전송 전체 성공 여부"),
                    fieldWithPath("data.allFailed").type(JsonFieldType.BOOLEAN).description("푸시 전송 전체 실패 여부")

                )
            ));

    }


}
