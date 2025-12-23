package com.geulnamu.controller;

import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.infrastructure.response.ResponseMessage;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.payload.JsonFieldType;
import org.springframework.test.web.servlet.ResultActions;

import static com.geulnamu.common.ApiDocumentUtils.getDocumentRequest;
import static com.geulnamu.common.ApiDocumentUtils.getDocumentResponse;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders.get;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;


@WebMvcTest(value = HelloController.class)
public class HelloControllerTest extends ControllerTest {

    @Test
    public void healthCheckTest() throws Exception {
        // given
        String response = "hi";

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/hello/health-check")
                    .accept(MediaType.APPLICATION_JSON)
                    .contentType(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value(response))
            .andDo(document(
                "/hello/health-check/view",
                getDocumentRequest(),
                getDocumentResponse(),
                responseFields(
                    fieldWithPath("code").type(JsonFieldType.NUMBER).description("결과 코드"),
                    fieldWithPath("message").type(JsonFieldType.STRING).description("결과 메세지"),
                    fieldWithPath("data").type(JsonFieldType.STRING).description("헬스 체크 기본 응답")
                )
            ));
    }

}
