package com.geulnamu.controller.member.dto.request;

import com.geulnamu.domain.member.Gender;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

public class MemberListRequest extends PagingRequest {

    @Pattern(regexp = "MALE|FEMALE", message = "성별은 'MALE' 또는 'FEMALE' 만 가능합니다.")
    private final String gender;

    @Pattern(regexp = "MEMBER|VICE_STAFF|STAFF|VICE_LEADER|LEADER|ADMIN", message = "역할은 'MEMBER', 'VICE_STAFF', 'STAFF', 'VICE_LEADER', 'LEADER', 'ADMIN' 중 하나만 가능합니다.")
    private final String role;

    @Pattern(regexp = "true|false", message = "비활성 여부 값은 'true' 또는 'false' 만 가능합니다.")
    private final String isDeleted;

    @Getter
    @Pattern(regexp = "id|role|name|gender|birthDate", message = "정렬 기준 값은 'id', 'role', 'name', 'gender', 'birthDate' 만 가능합니다.")
    private final String sortBy;

    @Pattern(regexp = "true|false", message = "오름차순 여부 값은 'true' 또는 'false' 만 가능합니다.")
    private final String isAsc;


    public Gender getGender() {
        return gender != null ? Gender.valueOf(gender) : null;
    }

    public Role getRole() {
        return role != null ? Role.valueOf(role) : null;
    }

    public Boolean getIsDeleted() {
        return isDeleted != null ? Boolean.valueOf(isDeleted) : null;
    }

    public Boolean getIsAsc() {
        return isAsc != null ? Boolean.valueOf(isAsc) : null;
    }

    public MemberListRequest(String gender, String role, String isDeleted,
                             String sortBy, String isAsc, Integer page, Integer size) {
        super(page, size);
        this.gender = gender;
        this.role = role;
        this.isDeleted = isDeleted;
        this.sortBy = sortBy;
        this.isAsc = isAsc;
    }

}
