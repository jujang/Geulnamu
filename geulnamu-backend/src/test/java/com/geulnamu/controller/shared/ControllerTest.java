package com.geulnamu.controller.shared;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.geulnamu.infrastructure.jwt.JwtAccessDeniedHandler;
import com.geulnamu.infrastructure.jwt.JwtAuthenticationEntryPoint;
import com.geulnamu.infrastructure.config.security.SecurityConfig;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.restdocs.AutoConfigureRestDocs;
import org.springframework.context.annotation.Import;
import org.springframework.restdocs.RestDocumentationExtension;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;

@ExtendWith({RestDocumentationExtension.class, SpringExtension.class})
@Import(SecurityConfig.class)
@AutoConfigureRestDocs(uriScheme = "https", uriHost = "docs.api.com") // 문서 생성을 위한 기본 설정 (자동)구성
public class ControllerTest {

    @Autowired
    protected ObjectMapper objectMapper;
    @Autowired
    protected MockMvc mockMvc;

    @MockitoBean
    private JwtTokenUtil jwtTokenUtil;
    @MockitoBean
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    @MockitoBean
    private JwtAccessDeniedHandler jwtAccessDeniedHandler;

}
