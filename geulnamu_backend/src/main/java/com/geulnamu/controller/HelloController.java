package com.geulnamu.controller;

import com.geulnamu.infrastructure.response.BaseResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/hello")
public class HelloController {

    @GetMapping("/health-check")
    public BaseResponse<String> healthCheck() {
        return BaseResponse.ofSuccess("hi");
    }

}
