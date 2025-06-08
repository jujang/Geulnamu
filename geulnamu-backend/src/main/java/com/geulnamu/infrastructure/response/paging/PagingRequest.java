package com.geulnamu.infrastructure.response.paging;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.data.domain.PageRequest;

@Getter
@AllArgsConstructor
public class PagingRequest {

    @NotNull(message = "page 필수 입력")
    @Min(value = 1, message = "page는 1 이상이어야 합니다.")
    private Integer page; // 요청 페이지
    @NotNull(message = "size 필수 입력")
    @Min(value = 1, message = "size는 1 이상이어야 합니다.")
    private Integer size; // 한 페이지 당 보여질 개수

    public PageRequest of() {
        return PageRequest.of(page - 1, size);
    }
}
