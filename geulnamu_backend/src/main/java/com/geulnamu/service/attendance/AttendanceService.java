package com.geulnamu.service.attendance;

import com.geulnamu.controller.attendance.dto.MemberInfoWithGroup;
import com.geulnamu.controller.attendance.dto.request.DiscussionGroupRequest;
import com.geulnamu.controller.attendance.dto.request.AssignDiscussionGroupsRequest;
import com.geulnamu.controller.attendance.dto.response.*;
import com.geulnamu.controller.shared.dto.response.MemberIdAndNameResponse;
import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.repository.attendance.AttendanceCommandRepository;
import com.geulnamu.repository.attendance.AttendanceQueryRepository;
import com.geulnamu.repository.meeting.MeetingQueryRepository;
import com.geulnamu.repository.member.MemberQueryRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class AttendanceService {

    private final MemberQueryRepository memberQueryRepository;
    private final MeetingQueryRepository meetingQueryRepository;
    private final AttendanceQueryRepository attendanceQueryRepository;
    private final AttendanceCommandRepository attendanceCommandRepository;


    // TODO: 추후 lock을 걸지 고민해 볼 것
    @Transactional(rollbackFor = Exception.class)
    public Long createAttendance(Long memberId, Long meetingId) {
        Member member =  memberQueryRepository.findById(memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
        Meeting meeting = meetingQueryRepository.findById(meetingId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        meeting.checkMemberIsDeActivated(memberId); // 비활성화 계정은 출석하지 못하게 제한

        meeting.checkTimeCanAttendMeeting();
        // 동일한 모임원이 해당 모임에 출석한 이력이 있는지 확인
        if(attendanceQueryRepository.findByMeetingIdAndMemberId(meetingId, memberId).isPresent()) {
            throw new BadRequestException(ResponseMessage.ATTENDANCE_DUPLICATE_ISSUE);
        }

        Attendance attendance = Attendance.createAttendance(meeting, member);
        attendanceCommandRepository.save(attendance);
        return attendance.getId();
    }

    @Transactional(readOnly = true)
    public AttendanceInfoResponse getMyAttendanceInfo(Long memberId, Long meetingId) {
        Attendance attendance = attendanceQueryRepository.findByMeetingIdAndMemberId(meetingId, memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        List<MemberIdAndNameResponse> memberIdAndNameResponseList = getDiscussionGroupMembers(attendance);
        return new AttendanceInfoResponse(attendance, memberIdAndNameResponseList);
    }

    @Transactional(readOnly = true)
    public MeetingAttendanceDetailsResponse getMeetingAttendanceStatus(Long meetingId) {
        MeetingAttendanceSummaryResponse meetingAttendanceSummaryResponse = attendanceQueryRepository.findMeetingAttendanceSummary(meetingId);
        List<MeetingAttendanceStatusResponse> meetingAttendanceStatusResponseList
            = attendanceQueryRepository.findMeetingAttendanceStatus(meetingId);
        return new MeetingAttendanceDetailsResponse(meetingAttendanceSummaryResponse, meetingAttendanceStatusResponseList);
    }

    @Transactional(readOnly = true)
    public List<MemberIdAndNameResponse> getWantDiscussionMemberList(Long meetingId) {
        return attendanceQueryRepository.findWantDiscussionMemberList(meetingId);
    }

    @Transactional(readOnly = true)
    public List<MemberIdAndNameResponse> getMyDiscussionMemberList(Long attendanceId, Long memberId) {
        Attendance attendance = getValidateAttendance(attendanceId, memberId);
        return attendanceQueryRepository.findMyDiscussionMemberList(attendance.getMeeting().getId(),
            attendance.getDiscussionGroup());
    }

    @Transactional(readOnly = true)
    public List<DiscussionGroupResponse> getAllDiscussionGroupMemberList(Long meetingId) {
        List<MemberInfoWithGroup> memberInfoWithGroupList = attendanceQueryRepository.findAllDiscussionGroupMemberList(meetingId);
        return convertToDiscussionGroupResponse(memberInfoWithGroupList);
    }

    @Transactional(rollbackFor = Exception.class)
    public void writeNote(Long attendanceId, Long memberId, String note) {
        Attendance attendance = getValidateAttendance(attendanceId, memberId);
        attendance.updateNote(note);
    }

    @Transactional(rollbackFor = Exception.class)
    public void notWantDiscussion(Long attendanceId, Long memberId) {
        Attendance attendance = getValidateAttendance(attendanceId, memberId);

        // 처리 가능한지 체크
        attendance.checkSettingDiscussionTime();
        attendance.getMeeting().checkTimeCanSwitchDiscussionAttendance();

        attendance.updateNotWantDiscussion();
    }

    @Transactional(rollbackFor = Exception.class)
    public void wantDiscussion(Long attendanceId, Long memberId) {
        Attendance attendance = getValidateAttendance(attendanceId, memberId);

        // 처리 가능한지 체크
        attendance.checkSettingDiscussionTime();
        attendance.getMeeting().checkTimeCanSwitchDiscussionAttendance();

        attendance.updateWantDiscussion();
    }

    @Transactional(rollbackFor = Exception.class)
    public void manuallyAssignDiscussionGroups(Long meetingId, AssignDiscussionGroupsRequest request) {
        meetingQueryRepository.findById(meetingId).orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        validateGroupNumberOver(request.getGroups().size()); // 토론 그룹 수 (7개) 초과 체크
        validateDiscussionGroupAssignment(request); // 모임원 그룹 중복 할당 체크
        attendanceCommandRepository.resetDiscussionGroups(meetingId); // 기존 그룹 생성 했었다면 초기화 (bulk update)
        assignGroupsToMembers(request, meetingId); // 토론 그룹 할당
    }

    @Transactional(rollbackFor = Exception.class)
    public void assignMemberToDiscussionGroup(Long meetingId, Long memberId, Integer optimizedGroupNumber) {
        meetingQueryRepository.findById(meetingId).orElseThrow(() -> new NotFoundDataException(DomainType.MEETING.getDescription()));
        validateGroupNumberOver(optimizedGroupNumber); // 토론 그룹 수 (7개) 초과 체크
        Attendance attendance = attendanceQueryRepository.findByMeetingIdAndMemberId(meetingId, memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        attendance.updateDiscussionGroup(DiscussionGroup.values()[optimizedGroupNumber]);
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteAttendance(Long attendanceId) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        attendanceQueryRepository.delete(attendance);
    }

    private Attendance getValidateAttendance(Long attendanceId, Long memberId) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.ATTENDANCE.getDescription()));
        attendance.checkRequestedMember(memberId);
        return attendance;
    }

    private List<MemberIdAndNameResponse> getDiscussionGroupMembers(Attendance attendance) {
        return attendance.getDiscussionGroup() != null
            ? attendanceQueryRepository.findMyDiscussionMemberList(
            attendance.getMeeting().getId(), attendance.getDiscussionGroup())
            : null;
    }

    private List<DiscussionGroupResponse> convertToDiscussionGroupResponse(List<MemberInfoWithGroup> memberInfoWithGroupList) {
        // discussionGroup 값을 기준으로 같은 discussionGroup 끼리 List로 묶어서 map 으로 만들기
        Map<DiscussionGroup, List<MemberIdAndNameResponse>> groupMap = memberInfoWithGroupList.stream()
            .collect(Collectors.groupingBy(
                MemberInfoWithGroup::getDiscussionGroup,
                Collectors.mapping(this::toMemberResponse, Collectors.toList())
            ));

        // 맵들을 discussionGroup 값으로 정렬하고, 값들을 DiscussionGroupResponse 타입에 담아 전체를 list로 만들어 반환
        return groupMap.entrySet().stream()
            .sorted(Map.Entry.comparingByKey())
            .map(entry -> new DiscussionGroupResponse(entry.getValue()))
            .collect(Collectors.toList());
    }

    private MemberIdAndNameResponse toMemberResponse(MemberInfoWithGroup memberInfoWithGroup) {
        return new MemberIdAndNameResponse(
            memberInfoWithGroup.getMemberId(),
            memberInfoWithGroup.getMemberName()
        );
    }

    private static void validateGroupNumberOver(int requestGroupSize) {
        if(requestGroupSize > DiscussionGroup.values().length) {
            throw new BadRequestException(ResponseMessage.OVER_DISCUSSION_GROUP_NUMBER);
        }
    }

    private static void validateDiscussionGroupAssignment(AssignDiscussionGroupsRequest request) {
        List<Long> memberIdList = new ArrayList<>();
        for(DiscussionGroupRequest requestList : request.getGroups()) {
            memberIdList.addAll(requestList.getMemberIdList());
        }
        if(memberIdList.size() != memberIdList.stream().distinct().count()) {
            throw new BadRequestException(ResponseMessage.MEMBER_DUPLICATE_DISCUSSION_GROUP_ASSIGNMENT);
        }
    }

    // 그룹 할당 - 그룹 별로 bulk update 진행 TODO: 현재는 그룹장을 따로 선별하지 않음, 추후 실 운영하면서 그룹장도 요청으로 받을지 고려해 볼 것
    private void assignGroupsToMembers(AssignDiscussionGroupsRequest request, Long meetingId) {
        for(int i = 0; i < request.getGroups().size(); i++) {
            List<Long> memberIds = request.getGroups().get(i).getMemberIdList();
            attendanceCommandRepository.assignDiscussionGroup(meetingId, memberIds, DiscussionGroup.values()[i]);
        }
    }

}
