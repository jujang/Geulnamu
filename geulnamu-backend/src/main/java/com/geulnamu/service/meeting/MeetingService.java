package com.geulnamu.service.meeting;

import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponse;
import com.geulnamu.controller.meeting.dto.response.MeetingListResponse;
import com.geulnamu.controller.meeting.dto.response.StaffResponse;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.meeting.MeetingType;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.repository.meeting.MeetingQueryRepository;
import com.geulnamu.repository.meeting.MeetingCommandRepository;
import com.geulnamu.repository.member.MemberQueryRepository;
import com.geulnamu.service.authorization.MeetingAuthorizationService;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@AllArgsConstructor
public class MeetingService {

    private final MeetingAuthorizationService authorizationService;
    private final MemberQueryRepository memberQueryRepository;
    private final MeetingCommandRepository meetingCommandRepository;
    private final MeetingQueryRepository meetingQueryRepository;


    @Transactional(rollbackFor = Exception.class)
    public void createMeeting(Long memberId, String meetingName, MeetingType meetingType, LocalDateTime meetingDate, String meetingPlace, String description) {
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        Meeting meeting = Meeting.createMeeting(member, meetingName, meetingType, meetingDate, meetingPlace, description);
        meetingCommandRepository.save(meeting);
    }

    @Transactional(readOnly = true)
    public MeetingInfoResponse findMeeting(Long meetingId) {
        Meeting meeting = meetingQueryRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        return MeetingInfoResponse.of(meeting);
    }

    @Transactional(readOnly = true)
    public List<StaffResponse> getStaffList() {
        return meetingQueryRepository.findStaffList();
    }

    @Transactional(readOnly = true)
    public MeetingListResponse getMeetingList(PagingRequest pagingRequest) {
        Pageable pageable = pagingRequest.toPageable();
        Page<MeetingInfoResponse> meetingDslList = meetingQueryRepository.findMeetingsWithPaging(pageable);

        PagingResponse pagingResponse = PagingResponse.from(meetingDslList);
        List<MeetingInfoResponse> meetingList = meetingDslList.getContent();
        return new MeetingListResponse(pagingResponse, meetingList);
    }

    @Transactional(readOnly = true)
    public MeetingListResponse getMeetingListForAdmin(PagingRequest pagingRequest) {
        Pageable pageable = pagingRequest.toPageable();
        Page<MeetingInfoResponse> meetingDslList = meetingQueryRepository.findMeetingsForAdminWithPaging(pageable);

        PagingResponse pagingResponse = PagingResponse.from(meetingDslList);
        List<MeetingInfoResponse> meetingList = meetingDslList.getContent();
        return new MeetingListResponse(pagingResponse, meetingList);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMeeting(Long meetingId, Long memberId, String meetingName, MeetingType meetingType, LocalDateTime meetingDate, String meetingPlace, String description) {
        // 모임 정보 수정 가능 권한 검사
        Meeting meeting = meetingQueryRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        authorizationService.validateModificationBy(meeting, member);

        // 수정 가능 시간 확인(모임 시작 이후, 수정 불가) - 관리자급의 경우, 시간이 넘었더라도 수정 가능
        if(!authorizationService.hasAdminPrivileges(member)) {
            meeting.checkTimeCanUpdateMeeting();
        }

        // 수정 필요 부분 적용
        if(meetingName == null && meetingType == null && meetingDate == null && meetingPlace == null && description == null) {
            throw new BadRequestException(ResponseMessage.NO_CHANGE_DETECTED);
        }
        if(meetingName != null) meeting.updateMeetingName(meetingName);
        if(meetingType != null) meeting.updateMeetingType(meetingType);
        if(meetingDate != null) meeting.updateMeetingDate(meetingDate);
        if(meetingPlace != null) meeting.updateMeetingPlace(meetingPlace);
        if(description != null) meeting.updateMeetingDescription(description);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMeetingForDiscussion(Long meetingId, Long memberId, LocalDateTime discussionTime, String alarmMessage) {
        // 모임 정보 수정 가능 권한 검사
        Meeting meeting = meetingQueryRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        authorizationService.validateModificationBy(meeting, member);

        // 수정 가능 시간 확인(토론 시작 이후, 수정 불가) - 관리자급의 경우, 시간이 넘었더라도 수정 가능
        if(!authorizationService.hasAdminPrivileges(member)) {
            meeting.checkTimeCanUpdateMeetingForDiscussion();
        }

        // 수정 필요 부분 적용
        if(discussionTime == null && alarmMessage == null) {
            throw new BadRequestException(ResponseMessage.NO_CHANGE_DETECTED);
        }
        if(discussionTime != null) meeting.updateDiscussionTime(discussionTime);
        if(alarmMessage != null) meeting.updateAlarmMessage(alarmMessage);
    }

    // 모임일 익일부터 비공개 처리 가능
    @Transactional(rollbackFor = Exception.class)
    public void makeMeetingPrivate(Long meetingId) {
        Meeting meeting = meetingQueryRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        meeting.validateTimeForPrivateMeeting();
        meeting.makeMeetingPrivate();
    }

    @Transactional(rollbackFor = Exception.class)
    public void makeMeetingPublic(Long meetingId) {
        Meeting meeting = meetingQueryRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        meeting.makeMeetingPublic();
    }

    // 모임 시작 6시간 전까지만 삭제 가능
    @Transactional(rollbackFor = Exception.class)
    public void removeMeeting(Long meetingId, Long memberId) {
        // 모임 삭제 가능 여부 검사
        Meeting meeting = meetingQueryRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        authorizationService.validateDeletionBy(meeting, member);
        meeting.validateTimeForDeleteMeeting();

        // 모임 삭제 (hard delete)
        meetingCommandRepository.delete(meeting);
    }

}
