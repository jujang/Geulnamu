package com.geulnamu.service.attendance;

import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.member.Member;
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

@Service
@AllArgsConstructor
public class AttendanceService {

    private final MemberQueryRepository memberQueryRepository;
    private final MeetingQueryRepository meetingQueryRepository;
    private final AttendanceCommandRepository attendanceCommandRepository;
    private final AttendanceQueryRepository attendanceQueryRepository;


    // TODO: 추후 lock을 걸지 고민해 볼 것
    @Transactional(rollbackFor = Exception.class)
    public Long createAttendance(Long meetingId, Long memberId) {
        Meeting meeting = meetingQueryRepository.findById(meetingId).orElseThrow(NotFoundDataException::new);
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);

        meeting.checkTimeCanAttendMeeting();
        // 동일한 모임원이 해당 모임에 출석한 이력이 있는지 확인
        if(attendanceQueryRepository.findByMeetingIdAndMemberId(meetingId, memberId).isPresent()) {
            throw new BadRequestException(ResponseMessage.ATTENDANCE_DUPLICATE_ISSUE);
        }

        Attendance attendance = Attendance.createAttendance(meeting, member);
        attendanceCommandRepository.save(attendance);
        return attendance.getId();
    }

    @Transactional(rollbackFor = Exception.class)
    public void writeNote(Long attendanceId, Long memberId, String note) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId).orElseThrow(NotFoundDataException::new);
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);

        // 처리 가능한지 체크
        attendance.checkRequestedMemberAndAttendanceMember(member);

        attendance.updateNote(note);
    }

    @Transactional(rollbackFor = Exception.class)
    public void notWantDiscussion(Long attendanceId, Long memberId) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId).orElseThrow(NotFoundDataException::new);
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);

        // 처리 가능한지 체크
        attendance.checkRequestedMemberAndAttendanceMember(member);
        attendance.checkSettingDiscussionTime();
        attendance.getMeeting().checkTimeCanSwitchAboutDiscussionAttendance();

        attendance.updateNotWantDiscussion();
    }

    @Transactional(rollbackFor = Exception.class)
    public void wantDiscussion(Long attendanceId, Long memberId) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId).orElseThrow(NotFoundDataException::new);
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);

        // 처리 가능한지 체크
        attendance.checkRequestedMemberAndAttendanceMember(member);
        attendance.checkSettingDiscussionTime();
        attendance.getMeeting().checkTimeCanSwitchAboutDiscussionAttendance();

        attendance.updateWantDiscussion();
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteAttendance(Long attendanceId) {
        Attendance attendance = attendanceQueryRepository.findById(attendanceId).orElseThrow(NotFoundDataException::new);
        attendanceQueryRepository.delete(attendance);
    }

}
