package com.geulnamu.infrastructure.response.paging;

import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.PageRequest;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class PagingRequest {

    @Min(value = 1, message = "'page' 는 1 이상이어야 합니다.")
    private int page; // 요청 페이지

    @Min(value = 1, message = "'size' 는 1 이상이어야 합니다.")
    private int size; // 한 페이지 당 보여질 개수


    public PageRequest toPageable() {
        return PageRequest.of(page - 1, size);
    }
}
