package com.geulnamu.infrastructure.config.security;

import com.geulnamu.infrastructure.jwt.JwtAccessDeniedHandler;
import com.geulnamu.infrastructure.jwt.JwtAuthenticationEntryPoint;
import com.geulnamu.infrastructure.jwt.JwtSecurityConfig;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;

import java.util.Arrays;
import java.util.Collections;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenUtil jwtTokenUtil;
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtAccessDeniedHandler jwtAccessDeniedHandler;

    private static final String[] AUTH_OPEN = {
        "/actuator/health",
        "/login/oauth/kakao",
        "/login/{memberId}/direct", // TODO: 임시 기능 -> 실 운영시 삭제 예정
        "/login/re-issue/accessToken",
        "/members/register", // TODO: 임시 기능 -> 실 운영시 삭제 예정
        "/error" // 향후 개발 완료 후 해당 코드 지워주고 요청들 잘 받아지는지 확인해 볼 것
    };

    private static final String[] AUTH_ALL = {
        "/login/logout",
        "/members/me/profile-status",
        "/members/me/profile",
        "/meetings/staff-list",
        "/meetings/list",
        "/meetings/list/today",
        "/attendances/check-in",
        "/attendances/{attendanceId}/my-info",
        "/attendances/list",
        "/attendances/{attendanceId}/note",
        "/attendances/{attendanceId}/just-read",
        "/attendances/{attendanceId}/want-discussion",
        "/discussions/{attendanceId}/my-group",
        "/book-questions/**",
        "/voc/error-report",
        "/voc/feature-request"
    };

    private static final String[] AUTH_FOR_STAFF = {
        "/members/list",
        "/meetings/create",
        "/meetings/list/staff",
        "/meetings/{meetingId}",
        "/meetings/{meetingId}/basic",
        "/meetings/{meetingId}/discussion",
        "/discussions/list/want-discussion",
        "/discussions/groups",
        "/discussions/groups/assign"
    };

    private static final String[] AUTH_FOR_ADMIN = {
        "/members/{memberId}/**",
        "/meetings/{meetingId}/make-private",
        "/meetings/{meetingId}/make-public",
        "/attendances/{attendanceId}/delete",
        "/discussions/groups/assign-member",
        "/action-histories/list",
        "/voc/list",
        "/voc/{vocId}/status"
    };


    // CORS 설정
    @Bean
    public CorsConfigurationSource configurationSource() {
        return request -> {
            CorsConfiguration config = new CorsConfiguration();
            config.setAllowedHeaders(Collections.singletonList("*"));
            config.setAllowedMethods(Collections.singletonList("*"));
            config.setAllowedOriginPatterns(Arrays.asList("http://localhost:3030", "https://localhost:3030"));
            config.setAllowCredentials(true);
//            config.addExposedHeader("Content-Disposition"); // 첨부파일 파일명 조회 위한 커스텀 헤더 접근 허용 설정
            return config;
        };
    }


    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(corsConfigurer -> corsConfigurer.configurationSource(configurationSource()))
            .csrf(AbstractHttpConfigurer::disable)  // TODO: 추후 토큰을 사용하는 빙식으로 사용할 것이라면 이대로 두면 됨
            .exceptionHandling(exceptionHandling -> exceptionHandling
                .accessDeniedHandler(jwtAccessDeniedHandler)
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)
            )
            .authorizeHttpRequests(authorizeHttpRequests -> authorizeHttpRequests
                .requestMatchers(AUTH_ALL).hasAnyRole("MEMBER", "VICE_STAFF", "STAFF", "VICE_LEADER", "LEADER", "ADMIN")
                .requestMatchers(AUTH_FOR_STAFF).hasAnyRole("VICE_STAFF", "STAFF", "VICE_LEADER", "LEADER", "ADMIN")
                .requestMatchers(AUTH_FOR_ADMIN).hasAnyRole("VICE_LEADER", "LEADER", "ADMIN")
                .requestMatchers(AUTH_OPEN).permitAll()
                .anyRequest().authenticated()
            )
            .with(new JwtSecurityConfig(jwtTokenUtil), Customizer.withDefaults());

        return http.build();
    }
}
