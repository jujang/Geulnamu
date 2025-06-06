package com.geulnamu.domain.shared.paging;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import org.springframework.data.domain.Page;

@Builder
@Getter
@AllArgsConstructor
public class PagingResponse {

    private int pageNumber; // 현재 페이지
    private int totalPages; // 전체 페이지수
    private long totalElements; // 전체 데이터 수

    public static PagingResponse from(Page<?> page) {
        return PagingResponse.builder()
            .pageNumber(page.getNumber() + 1)
            .totalPages(page.getTotalPages())
            .totalElements(page.getTotalElements())
            .build();
    }
}
