package com.geulnamu;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;
import org.springframework.scheduling.annotation.EnableAsync;

@EnableAsync
@SpringBootApplication
@EnableAutoConfiguration(exclude = {
	UserDetailsServiceAutoConfiguration.class // 기본 보안 계정 생성 비활성화 (=활성화 시, 앱 실행하면 콘솔에 기본 계정 비밀번호 출력됨)
})
public class GeulnamuApplication {

	public static void main(String[] args) {
		SpringApplication.run(GeulnamuApplication.class, args);
	}

}
