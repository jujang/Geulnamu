package com.geulnamu.controller.meeting.dto.request;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.meeting.MeetingType;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class MeetingCreateRequestDTO {

    @NotBlank(message = "모임 종류 필수 입력")
    @Pattern(regexp = "REGULAR|FLASH|SPECIAL", message = "모임 종류는 'REGULAR', 'FLASH', 'SPECIAL' 중 하나만 가능합니다.")
    private String meetingType;    // 모임 종류

    @NotBlank(message = "모임 제목 필수 입력")
    @Pattern(regexp = "^[ㄱ-ㅎ가-힣a-zA-Z0-9\\s:/@\\[\\]()~_-]{1,30}$",
        message = "모임 제목은 한글, 영문, 숫자, 공백 및 일부 특수분자(: / [ ] ( ) ~ _ -)만 1자 이상, 70자 이하로 입력해주세요.")
    private String meetingName;    // 모임 제목

    @NotNull(message = "모임 개최일자 필수 입력")
    @Future(message = "모임 개최일자는 미래의 시간이어야 합니다.")
    @JsonFormat(pattern = "yyyyMMdd HH:mm")
    private LocalDateTime meetingDate;    // 모임 개최일자

    private String description;    // 상세 내용

    public MeetingType getMeetingType() {
        return MeetingType.valueOf(meetingType);
    }
}
