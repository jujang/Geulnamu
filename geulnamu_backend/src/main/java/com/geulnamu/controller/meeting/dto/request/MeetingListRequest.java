package com.geulnamu.controller.meeting.dto.request;

import com.geulnamu.domain.meeting.MeetingType;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

public class MeetingListRequest extends PagingRequest {

    @Pattern(regexp = "REGULAR|FLASH|SPECIAL", message = "모임 유형은 'REGULAR', 'FLASH', 'SPECIAL' 중 하나만 가능합니다.")
    private final String meetingType;

    @Pattern(regexp = "true|false", message = "오늘의 모임 조회 여부 값은 'true' 또는 'false' 만 가능합니다.")
    private final String isTodayMeeting; // 오늘의 모임 조회 여부

    @Getter
    @Pattern(regexp = "NOT_STARTED|ATTEND|ATTEND_LATE|NOT_ATTEND", message = "참석 상태 값은 'NOT_STARTED', 'ATTEND', 'ATTEND_LATE', 'NOT_ATTEND' 중 하나만 가능합니다.")
    private final String attendanceStatus; // 참석 상태 (일반 목록 조회에서만 사용되는 값)

    @Pattern(regexp = "true|false", message = "모임 비공개 여부 값은 'true' 또는 'false' 만 가능합니다.")
    private final String isPrivate; // 관리자용 목록 조회에서만 사용되는 값

    @Getter
    @Pattern(regexp = "meetingDate|id", message = "정렬 기준 값은 'meetingDate', 'id' 중 하나만 가능합니다.")
    private final String sortBy; // 여기서 id는 meetingId를 뜻함

    @Pattern(regexp = "true|false", message = "오름차순 여부 값은 'true' 또는 'false' 만 가능합니다.")
    private final String isAsc;


    public MeetingType getMeetingType() {
        return meetingType != null ? MeetingType.valueOf(meetingType) : null;
    }

    public Boolean getIsTodayMeeting() {
        return isTodayMeeting != null ? Boolean.valueOf(isTodayMeeting) : null;
    }

    public Boolean getIsPrivate() {
        return isPrivate != null ? Boolean.valueOf(isPrivate) : null;
    }

    public Boolean getIsAsc() {
        return isAsc != null ? Boolean.valueOf(isAsc) : null;
    }

    public MeetingListRequest(String meetingType, String isTodayMeeting, String isPrivate,
                              String attendanceStatus, String sortBy, String isAsc, Integer page, Integer size) {
        super(page, size);
        this.meetingType = meetingType;
        this.isTodayMeeting = isTodayMeeting;
        this.isPrivate = isPrivate;
        this.attendanceStatus = attendanceStatus;
        this.sortBy = sortBy;
        this.isAsc = isAsc;
    }
}
