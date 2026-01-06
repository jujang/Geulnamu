package com.geulnamu.service.meeting;

import com.geulnamu.controller.meeting.dto.request.*;
import com.geulnamu.controller.meeting.dto.response.*;
import com.geulnamu.controller.shared.dto.response.AttendanceIdAndNameResponse;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.repository.attendance.AttendanceQueryRepository;
import com.geulnamu.repository.meeting.MeetingQueryRepository;
import com.geulnamu.repository.meeting.MeetingCommandRepository;
import com.geulnamu.repository.member.MemberQueryRepository;
import lombok.AllArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@AllArgsConstructor
public class MeetingService {

    private final MemberQueryRepository memberQueryRepository;
    private final MeetingQueryRepository meetingQueryRepository;
    private final MeetingCommandRepository meetingCommandRepository;
    private final AttendanceQueryRepository attendanceQueryRepository;


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

    @Cacheable(
        value = "meeting:list",
        key = "(#request.meetingType ?: 'ALL') + ':' + " +
            "(#request.isTodayMeeting ?: 'ALL') + ':' + " +
            "(#request.attendanceStatus ?: 'ALL') + ':' + " +
            "(#request.isPrivate ?: 'ALL') + ':' + " +
            "(#request.sortBy ?: 'id') + ':' + " +
            "(#request.isAsc ?: 'true') + ':' + " +
            "'page=' + #request.page + ':' + " +
            "'size=' + #request.size + ':' + " +
            "'member=' + #myMemberId",
        unless = "#result == null || #result.meetingList.isEmpty()"
    )
    @Transactional(readOnly = true)
    public MeetingListResponse getMeetingList(Long myMemberId, MeetingListRequest request) {
        Page<MeetingInfoResponse> meetingDslList = meetingQueryRepository.findMeetingsWithPaging(request, myMemberId);

        PagingResponse pagingResponse = PagingResponse.from(meetingDslList);
        List<MeetingInfoResponse> meetingList = meetingDslList.getContent();
        return new MeetingListResponse(pagingResponse, meetingList);
    }

    // TODO: 추후 쿼리 하나로 다 뽑아내도록 개선할 것!
    @Cacheable(
        value = "meeting:detail",
        key = "#meetingId + ':' + #memberId",
        unless = "#result == null"
    )
    @Transactional(readOnly = true)
    public MeetingDetailResponse getMeeting(Long meetingId, Long memberId) {
        MeetingDetailResponse meetingDetailResponse = meetingQueryRepository.findMeeting(meetingId, memberId);
        if(meetingDetailResponse == null) {
            throw new NotFoundDataException(DomainType.MEETING.getDescription());
        }
        if(meetingDetailResponse.getDiscussionGroup() != null) {
            List<AttendanceIdAndNameResponse> groupMemberList = attendanceQueryRepository.findMyDiscussionMemberList(
                meetingDetailResponse.getMeetingId(), meetingDetailResponse.getDiscussionGroup());
            meetingDetailResponse.updateGroupMemberList(groupMemberList);
        }
        return meetingDetailResponse;
    }

    @Transactional(readOnly = true)
    public MeetingDetailResponseForStaff getMeetingForStaff(Long meetingId) {
        Meeting meeting = findMeetingOrThrow(meetingId);
        return MeetingDetailResponseForStaff.of(meeting);
    }

    @CacheEvict(
        value = {"meeting:detail", "meeting:list"},
        allEntries = true
    )
    @Transactional(rollbackFor = Exception.class)
    public void updateMeeting(Long meetingId, Long memberId, Role role, MeetingUpdateRequest request){
        // 모임 정보 수정 가능 권한 검사
        Meeting meeting = findMeetingOrThrow(meetingId);

        // 수정 가능 시간 확인(모임 시작 이후, 수정 불가) - 관리자급의 경우, 시간이 넘었더라도 수정 가능
        if(!hasAdminPrivileges(role)) {
            checkMeetingOpenedMember(meeting.getMember().getId(), memberId);
            meeting.checkMeetingUpdateTime();
        }

        // 수정 필요 부분 적용
        if(request.getMeetingName() == null && request.getMeetingType() == null && request.getMeetingDate() == null
            && request.getLateThresholdTime() == null && request.getMeetingPlace() == null && request.getDescription() == null) {
            throw new BadRequestException(ResponseMessage.NO_CHANGE_DETECTED);
        }
        if(request.getMeetingName() != null) meeting.updateMeetingName(request.getMeetingName());
        if(request.getMeetingType() != null) meeting.updateMeetingType(request.getMeetingType());
        if(request.getMeetingDate() != null) meeting.updateMeetingDate(request.getMeetingDate());
        if(request.getLateThresholdTime() != null) meeting.updateLateThresholdTime(request.getLateThresholdTime());
        if(request.getMeetingPlace() != null) meeting.updateMeetingPlace(request.getMeetingPlace());
        if(request.getDescription() != null) meeting.updateMeetingDescription(request.getDescription());
    }

    @CacheEvict(
        value = {"meeting:detail", "meeting:list"},
        allEntries = true
    )
    @Transactional(rollbackFor = Exception.class)
    public void updateMeetingForDiscussion(Long meetingId, Long memberId, Role role, MeetingGroupUpdateRequest request) {
        // 모임 정보 수정 가능 권한 검사
        Meeting meeting = findMeetingOrThrow(meetingId);

        // 수정 가능 시간 확인(토론 시작 이후, 수정 불가) - 관리자급의 경우, 시간이 넘었더라도 수정 가능
        if(!hasAdminPrivileges(role)) {
            checkMeetingOpenedMember(meeting.getMember().getId(), memberId);
            meeting.checkDiscussionUpdateTime();
        }

        // 수정 필요 부분 적용
        if(request.getDiscussionTime() == null && request.getDiscussionTimeNull() == null && request.getAlarmMessage() == null) {
            throw new BadRequestException(ResponseMessage.NO_CHANGE_DETECTED);
        }
        if(request.getDiscussionTime() != null) meeting.updateDiscussionTime(request.getDiscussionTime());
        if(Boolean.TRUE.equals(request.getDiscussionTimeNull())) meeting.updateDiscussionTime(null);
        if(request.getAlarmMessage() != null) meeting.updateAlarmMessage(request.getAlarmMessage());
    }

    // 모임일 익일부터 비공개 처리 가능
    @Transactional(rollbackFor = Exception.class)
    public void makeMeetingPrivate(Long meetingId) {
        Meeting meeting = findMeetingOrThrow(meetingId);
        meeting.checkTimeForPrivateMeeting();
        meeting.makeMeetingPrivate();
    }

    @Transactional(rollbackFor = Exception.class)
    public void makeMeetingPublic(Long meetingId) {
        Meeting meeting = findMeetingOrThrow(meetingId);
        meeting.makeMeetingPublic();
    }

    // 모임 시작 6시간 전까지만 삭제 가능
    @CacheEvict(
        value = {"meeting:detail", "meeting:list"},
        allEntries = true
    )
    @Transactional(rollbackFor = Exception.class)
    public void removeMeeting(Long meetingId, Long memberId, Role role) {
        // 모임 삭제 가능 여부 검사
        Meeting meeting = findMeetingOrThrow(meetingId);

        if(!hasAdminPrivileges(role)) {
            checkMeetingOpenedMember(meeting.getMember().getId(), memberId);
        }

        meeting.checkTimeForDeleteMeeting(); // TODO: 삭제는 관리자급이어도 모임 시작 6시간 남았을 때부터는 삭제 불가능, 추후 관리자는(모임 시작 전까지는) 삭제 가능하게 것도 고려해 볼 것

        // 모임 삭제 (hard delete)
        meetingCommandRepository.delete(meeting);
    }

    private Meeting findMeetingOrThrow(Long meetingId) {
        return meetingQueryRepository.findById(meetingId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
    }

    public static void checkMeetingOpenedMember(Long meetingMemberId, Long requestedMemberId) {
        if(!meetingMemberId.equals(requestedMemberId)) {
            throw new BadRequestException(ResponseMessage.NOT_SUITABLE_MEMBER);
        }
    }

    public static boolean hasAdminPrivileges(Role role) {
        return (role.equals(Role.ADMIN) || role.equals(Role.LEADER) || role.equals(Role.VICE_LEADER));
    }

}
