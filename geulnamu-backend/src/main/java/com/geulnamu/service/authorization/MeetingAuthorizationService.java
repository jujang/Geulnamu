package com.geulnamu.service.authorization;

import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.exception.ForbiddenException;
import org.springframework.stereotype.Component;

@Component
public class MeetingAuthorizationService {

    public void validateModificationBy(Meeting meeting, Member member) {
        if(!canModifyMeeting(meeting, member)) {
            throw new ForbiddenException();
        }
    }

    public void validateDeletionBy(Meeting meeting, Member member) {
        if(!canDeleteMeeting(meeting, member)) {
            throw new ForbiddenException();
        }
    }

    public boolean canModifyMeeting(Meeting meeting, Member member) {
        return meeting.getMember().equals(member) || hasAdminPrivileges(member);
    }

    public boolean canDeleteMeeting(Meeting meeting, Member member) {
        return meeting.getMember().equals(member) || hasAdminPrivileges(member);
    }

    public boolean hasAdminPrivileges(Member member) {
        return member.getRole() == Role.ADMIN ||
            member.getRole() == Role.LEADER ||
            member.getRole() == Role.VICE_LEADER;
    }

}
