package com.geulnamu.infrastructure.response.paging;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.Page;

@Builder
@Getter
@NoArgsConstructor  // Redis 역직렬화용 기본 생성자
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
