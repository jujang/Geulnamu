package com.geulnamu.infrastructure.response.paging;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.data.domain.PageRequest;

@Getter
@AllArgsConstructor
public class PagingRequest {

    @NotNull(message = "'page' 는 반드시 입력해야 합니다.")
    @Min(value = 1, message = "'page' 는 1 이상이어야 합니다.")
    private final Integer page; // 요청 페이지

    @NotNull(message = "'size' 는 반드시 입력해야 합니다.")
    @Min(value = 1, message = "'size' 는 1 이상이어야 합니다.")
    private final Integer size; // 한 페이지 당 보여질 개수


    public PageRequest toPageable() {
        return PageRequest.of(page - 1, size);
    }

}
