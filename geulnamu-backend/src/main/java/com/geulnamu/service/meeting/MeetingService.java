package com.geulnamu.service.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingCreateRequest;
import com.geulnamu.controller.meeting.dto.request.MeetingGroupUpdateRequest;
import com.geulnamu.controller.meeting.dto.request.MeetingListRequest;
import com.geulnamu.controller.meeting.dto.request.MeetingUpdateRequest;
import com.geulnamu.controller.meeting.dto.response.*;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.repository.attendance.AttendanceQueryRepository;
import com.geulnamu.repository.meeting.MeetingQueryRepository;
import com.geulnamu.repository.meeting.MeetingCommandRepository;
import com.geulnamu.repository.member.MemberQueryRepository;
import com.geulnamu.service.authorization.MeetingAuthorizationService;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@AllArgsConstructor
public class MeetingService {

    private final MeetingAuthorizationService authorizationService;
    private final MemberQueryRepository memberQueryRepository;
    private final AttendanceQueryRepository attendanceQueryRepository;
    private final MeetingQueryRepository meetingQueryRepository;
    private final MeetingCommandRepository meetingCommandRepository;


    @Transactional(rollbackFor = Exception.class)
    public Long createMeeting(Long memberId, MeetingCreateRequest request) {
        Member member = memberQueryRepository.findById(memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
        Meeting meeting = Meeting.createMeeting(member, request.getMeetingName(), request.getMeetingType(), request.getMeetingDate(),
            request.getLateThresholdTime(), request.getMeetingPlace(), request.getDescription());
        meeting.checkLateThresholdTimeBeforeMeetingTime();
        meetingCommandRepository.save(meeting);
        return meeting.getId();
    }

    @Transactional(readOnly = true)
    public List<MemberIdAndNameResponse> getStaffList() {
        return meetingQueryRepository.findStaffList();
    }

    @Transactional(readOnly = true)
    public MeetingListResponse getMeetingList(Long myMemberId, MeetingListRequest request) {
        Page<MeetingInfoResponse> meetingDslList = meetingQueryRepository.findMeetingsWithPaging(request, myMemberId);

        PagingResponse pagingResponse = PagingResponse.from(meetingDslList);
        List<MeetingInfoResponse> meetingList = meetingDslList.getContent();
        return new MeetingListResponse(pagingResponse, meetingList);
    }

    @Transactional(readOnly = true)
    public MeetingListForStaffResponse getMeetingListForStaff(MeetingListRequest request) {
        Page<MeetingInfoForStaffResponse> meetingDslList = meetingQueryRepository.findMeetingsForAdminWithPaging(request);

        PagingResponse pagingResponse = PagingResponse.from(meetingDslList);
        List<MeetingInfoForStaffResponse> meetingList = meetingDslList.getContent();
        return new MeetingListForStaffResponse(pagingResponse, meetingList);
    }

    @Transactional(readOnly = true)
    public MeetingInfoForStaffResponse findMeetingForStaff(Long meetingId) {
        Meeting meeting = meetingQueryRepository.findById(meetingId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        return MeetingInfoForStaffResponse.of(meeting);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMeeting(Long meetingId, Long memberId, MeetingUpdateRequest request){
        // 모임 정보 수정 가능 권한 검사
        Meeting meeting = meetingQueryRepository.findById(meetingId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        Member member = memberQueryRepository.findById(memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
        authorizationService.validateModificationBy(meeting, member);

        // 수정 가능 시간 확인(모임 시작 이후, 수정 불가) - 관리자급의 경우, 시간이 넘었더라도 수정 가능
        if(!authorizationService.hasAdminPrivileges(member)) {
            meeting.checkMeetingUpdateTime();
        }

        // 수정 필요 부분 적용
        if(request.getMeetingName() == null && request.getMeetingType() == null && request.getMeetingDate() == null
            && request.getMeetingPlace() == null && request.getDescription() == null) {
            throw new BadRequestException(ResponseMessage.NO_CHANGE_DETECTED);
        }
        if(request.getMeetingName() != null) meeting.updateMeetingName(request.getMeetingName());
        if(request.getMeetingType() != null) meeting.updateMeetingType(request.getMeetingType());
        if(request.getMeetingDate() != null) meeting.updateMeetingDate(request.getMeetingDate());
        if(request.getLateThresholdTime() != null) meeting.updateLateThresholdTime(request.getLateThresholdTime());
        if(request.getMeetingPlace() != null) meeting.updateMeetingPlace(request.getMeetingPlace());
        if(request.getDescription() != null) meeting.updateMeetingDescription(request.getDescription());
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMeetingForDiscussion(Long meetingId, Long memberId, MeetingGroupUpdateRequest request) {
        // 모임 정보 수정 가능 권한 검사
        Meeting meeting = meetingQueryRepository.findById(meetingId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        Member member = memberQueryRepository.findById(memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
        authorizationService.validateModificationBy(meeting, member);

        // 수정 가능 시간 확인(토론 시작 이후, 수정 불가) - 관리자급의 경우, 시간이 넘었더라도 수정 가능
        if(!authorizationService.hasAdminPrivileges(member)) {
            meeting.checkDiscussionUpdateTime();
        }

        // 수정 필요 부분 적용
        if(request.getDiscussionTime() == null && request.getAlarmMessage() == null) {
            throw new BadRequestException(ResponseMessage.NO_CHANGE_DETECTED);
        }
        if(request.getDiscussionTime() != null) meeting.updateDiscussionTime(request.getDiscussionTime());
        if(request.getAlarmMessage() != null) meeting.updateAlarmMessage(request.getAlarmMessage());
    }

    // 모임일 익일부터 비공개 처리 가능
    @Transactional(rollbackFor = Exception.class)
    public void makeMeetingPrivate(Long meetingId) {
        Meeting meeting = meetingQueryRepository.findById(meetingId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        meeting.checkTimeForPrivateMeeting();
        meeting.makeMeetingPrivate();
    }

    @Transactional(rollbackFor = Exception.class)
    public void makeMeetingPublic(Long meetingId) {
        Meeting meeting = meetingQueryRepository.findById(meetingId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        meeting.makeMeetingPublic();
    }

    // 모임 시작 6시간 전까지만 삭제 가능
    @Transactional(rollbackFor = Exception.class)
    public void removeMeeting(Long meetingId, Long memberId) {
        // 모임 삭제 가능 여부 검사
        Meeting meeting = meetingQueryRepository.findById(meetingId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        Member member = memberQueryRepository.findById(memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
        authorizationService.validateDeletionBy(meeting, member);
        meeting.checkTimeForDeleteMeeting();

        // 모임 삭제 (hard delete)
        meetingCommandRepository.delete(meeting);
    }

}
