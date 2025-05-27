package com.geulnamu.controller.member.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.Gender;
import com.geulnamu.domain.shared.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MemberInfoResponseDTO {

    private Long memberId;
    private String name;
    private String nickname;
    private Role role;
    private Gender gender;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate birthDate;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm:SS", timezone = "Asia/Seoul")
    private LocalDateTime createdAt;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm:SS", timezone = "Asia/Seoul")
    private LocalDateTime deletedAt;

    public static MemberInfoResponseDTO of(Member member) {
        return new MemberInfoResponseDTO(member.getId(), member.getName(), member.getNickname(), member.getRole(), member.getGender(), member.getBirthDate(), member.getCreatedAt(), member.getDeletedAt());
    }

}
