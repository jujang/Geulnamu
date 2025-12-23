package com.geulnamu.controller;

import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.response.BaseResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/hello")
public class HelloController {

    @AccessLevel(Level.PUBLIC)
    @GetMapping("/health-check")
    public BaseResponse<String> healthCheck() {
        return BaseResponse.ofSuccess("hi");
    }

}
