package com.geulnamu.infrastructure.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)  // TODO: 추후 토큰을 사용하는 빙식으로 사용할 것이라면 이대로 두면 됨
            .authorizeHttpRequests(authorizeHttpRequests -> authorizeHttpRequests
                .requestMatchers("/member/**").permitAll()
                .requestMatchers("/error").permitAll() // 향후 개발 완료 후 해당 코드 지워주고 요청들 잘 받아지는지 확인해 볼 것
                .anyRequest().authenticated()
            );
//            .httpBasic(Customizer.withDefaults());

        return http.build();
    }
}
