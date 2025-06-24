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

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenUtil jwtTokenUtil;
//    private final CorsFilter corsFilter;
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtAccessDeniedHandler jwtAccessDeniedHandler;

    private static final String[] AUTH_OPEN = {
        "/actuator/health",
        "/login/oauth/kakao",
        "/login/{memberId}/direct", // TODO: 임시 기능 -> 실 운영시 삭제 예정
        "/login/re-issue/accessToken",
        "/members/register",
        "/error" // 향후 개발 완료 후 해당 코드 지워주고 요청들 잘 받아지는지 확인해 볼 것
    };

    private static final String[] AUTH_ALL = {
        "/login/logout",
        "/members/me/profile-status",
        "/members/me/profile",
        "/meeting/list",
        "/meeting/list/staff",
        "/attendance",
        "/attendance/{attendanceId}/my",
        "/attendance/{attendanceId}/note",
        "/attendance/{attendanceId}/just-read",
        "/attendance/{attendanceId}/want-discussion",
        "/discussion/{attendanceId}/my-group"
    };

    private static final String[] AUTH_FOR_STAFF = {
        "/meeting",
        "/meeting/{meetingId}",
        "/meeting/{meetingId}/discussion",
        "/discussion/list/want-discussion",
        "/discussion/all-group",
        "/discussion/assign"
    };

    private static final String[] AUTH_FOR_ADMIN = {
        "/members/{memberId}/**",
        "/members/list",
        "/meeting/list/admin",
        "/meeting/{meetingId}/private",
        "/meeting/{meetingId}/public",
        "/attendance/{attendanceId}/delete",
        "/discussion/assign/solo"
    };


    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
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
