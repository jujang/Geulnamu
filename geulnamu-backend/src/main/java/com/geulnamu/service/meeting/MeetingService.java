package com.geulnamu.service.meeting;

import com.geulnamu.controller.meeting.dto.response.MeetingInfoResponseDTO;
import com.geulnamu.controller.meeting.dto.response.MeetingListResponseDTO;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.meeting.MeetingType;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.exception.BadRequestException;
import com.geulnamu.infrastructure.exception.ForbiddenException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.response.ResponseMessage;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.repository.meeting.MeetingDslRepository;
import com.geulnamu.repository.meeting.MeetingRepository;
import com.geulnamu.repository.member.MemberRepository;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
@AllArgsConstructor
public class MeetingService {

    private final MemberRepository memberRepository;
    private final MeetingRepository meetingRepository;
    private final MeetingDslRepository meetingDslRepository;


    @Transactional(rollbackFor = Exception.class)
    public void createMeeting(Long memberId, String meetingName, MeetingType meetingType, LocalDateTime meetingDate, String description) {
        Member member = memberRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        Meeting meeting = Meeting.createMeeting(member, meetingName, meetingType, meetingDate, description);
        meetingRepository.save(meeting);
    }

    @Transactional(readOnly = true)
    public MeetingListResponseDTO getMeetingList(PagingRequest pagingRequest) {
        Pageable pageable = pagingRequest.of();
        Page<MeetingInfoResponseDTO> meetingDslList = meetingDslRepository.findMeetings(pageable);

        PagingResponse pagingResponse = PagingResponse.from(meetingDslList);
        List<MeetingInfoResponseDTO> meetingList = meetingDslList.getContent();
        return new MeetingListResponseDTO(pagingResponse, meetingList);
    }

    @Transactional(readOnly = true)
    public MeetingListResponseDTO getMeetingListForAdmin(PagingRequest pagingRequest) {
        Pageable pageable = pagingRequest.of();
        Page<MeetingInfoResponseDTO> meetingDslList = meetingDslRepository.findMeetingsForAdmin(pageable);

        PagingResponse pagingResponse = PagingResponse.from(meetingDslList);
        List<MeetingInfoResponseDTO> meetingList = meetingDslList.getContent();
        return new MeetingListResponseDTO(pagingResponse, meetingList);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMeeting(Long meetingId, Long memberId, Role memberRole, String meetingName, MeetingType meetingType, LocalDateTime meetingDate, String description) {
        Meeting meeting = meetingRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        if(meeting.getMember().getId().equals(memberId) || memberRole.equals(Role.LEADER) || memberRole.equals(Role.VICE_LEADER) || memberRole.equals(Role.ADMIN)) {
            if(meetingName == null && meetingType == null && meetingDate == null && description == null) {
                throw new BadRequestException(ResponseMessage.NO_CHANGE_DETECTED);
            }
            if(meetingName != null) meeting.updateMeetingName(meetingName);
            if(meetingType != null) meeting.updateMeetingType(meetingType);
            if(meetingDate != null) meeting.updateMeetingDate(meetingDate);
            if(description != null) meeting.updateMeetingDescription(description);
        } else {
            throw new ForbiddenException();
        }
    }

    // 모임일 익일부터 비공개 처리 가능
    @Transactional(rollbackFor = Exception.class)
    public void makeMeetingPrivate(Long meetingId) {
        Meeting meeting = meetingRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        if(LocalDateTime.now().isAfter(meeting.getMeetingDate().plusDays(1).with(LocalTime.MIN))) {
            meeting.makeMeetingPrivate();
        } else {
            throw new BadRequestException(ResponseMessage.MEETING_PRIVACY_TIME_RESTRICTION);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void makeMeetingPublic(Long meetingId) {
        Meeting meeting = meetingRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        meeting.makeMeetingPublic();
    }

    // 모임 시작 6시간 전까지만 삭제 가능
    @Transactional(rollbackFor = Exception.class)
    public void removeMeeting(Long meetingId, Long memberId, Role memberRole) {
        Meeting meeting = meetingRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        if(meeting.getMember().getId().equals(memberId) || memberRole.equals(Role.LEADER) || memberRole.equals(Role.VICE_LEADER) || memberRole.equals(Role.ADMIN)) {
            if(LocalDateTime.now().plusHours(6).isAfter(meeting.getMeetingDate())) {
                throw new BadRequestException(ResponseMessage.MEETING_DELETION_TIME_EXPIRED);
            } else {
                meetingRepository.delete(meeting);
            }
        } else {
            throw new ForbiddenException();
        }
    }

}
