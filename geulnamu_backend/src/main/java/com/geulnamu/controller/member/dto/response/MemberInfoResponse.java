package com.geulnamu.controller.member.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.member.Gender;
import com.geulnamu.domain.shared.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MemberInfoResponse {

    private Long memberId;
    private String name;
    private Gender gender;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate birthDate;
    private String nickname;
    private Role role;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm:SS")
    private LocalDateTime deletedAt;

    public static MemberInfoResponse of(Member member) {
        return new MemberInfoResponse(member.getId(), member.getName(), member.getGender(), member.getBirthDate(), member.getNickname(), member.getRole(), member.getDeletedAt());
    }

}
