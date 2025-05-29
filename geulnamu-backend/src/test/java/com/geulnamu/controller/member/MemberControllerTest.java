package com.geulnamu.controller.member;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.geulnamu.controller.member.dto.MemberInfoRequestDTO;
import com.geulnamu.controller.member.dto.MemberRoleUpdateRequestDTO;
import com.geulnamu.controller.member.dto.MemberStatusUpdateRequestDTO;
import com.geulnamu.controller.shared.ControllerTest;
import com.geulnamu.global.response.ResponseMessage;
import com.geulnamu.service.member.MemberService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import java.time.LocalDate;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;


@WebMvcTest(value = MemberController.class)
public class MemberControllerTest extends ControllerTest {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private ObjectMapper objectMapper;
    @MockitoBean
    private MemberService memberService;


    @Test
    @WithMockUser(roles = "MEMBER")
    public void checkMemberInfoRegisterTest() throws Exception {
        // given
        Boolean response = true;
        String accessToken = "Bearer access_token";

        given(memberService.checkMemberInfoRegister(any())).willReturn(response);

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/member/info")
                    .header("Authorization", accessToken)
                    .accept(MediaType.APPLICATION_JSON)
            );

        // then
        actions
            .andExpect(status().isOk())
            .andExpect(jsonPath("code").value(200))
            .andExpect(jsonPath("message").value(ResponseMessage.SUCCESS))
            .andExpect(jsonPath("data").value(response));
    }

    @Test
    @WithMockUser(roles = "MEMBER")
    public void updateMemberInfoTest() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MemberInfoRequestDTO requestDTO = new MemberInfoRequestDTO("나뭉이", "MALE", LocalDate.of(2022, 1, 1));

        doNothing().when(memberService).updateMemberInfo(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                patch("/member/info")
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
            .andExpect(jsonPath("data").value((Object) null));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void updateMemberRole() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MemberRoleUpdateRequestDTO requestDTO = new MemberRoleUpdateRequestDTO("STAFF");

        doNothing().when(memberService).updateMemberRole(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/member/{memberId}", 1L)
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
            .andExpect(jsonPath("data").value((Object) null));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    public void updateMemberStatus() throws Exception {
        // given
        String accessToken = "Bearer access_token";
        MemberStatusUpdateRequestDTO requestDTO = new MemberStatusUpdateRequestDTO("INACTIVE");

        doNothing().when(memberService).updateMemberRole(any(), any());

        // when
        ResultActions actions =
            mockMvc.perform(
                get("/member/{memberId}", 1L)
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
            .andExpect(jsonPath("data").value((Object) null));
    }
}
