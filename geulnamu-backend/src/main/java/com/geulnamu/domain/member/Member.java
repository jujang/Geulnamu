package com.geulnamu.domain.member;

import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.meetingAttendance.MeetingAttendance;
import com.geulnamu.domain.shared.DateColumn;
import com.geulnamu.domain.shared.MemberStatus;
import com.geulnamu.domain.shared.RoleConverter;
import com.geulnamu.infrastructure.exception.ExistDataException;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;


@Getter
@Builder
@Entity(name = "members")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Member extends DateColumn {

    @Id
    @Column(name = "member_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", length = 10, nullable = false)
    private String name;

    @Column(name = "nickname", length = 20)
    private String nickname;

    @Convert(converter = RoleConverter.class)
    @Column(name = "role", length = 10, nullable = false)
    private Role role;

    @Column(name = "gender", length = 6)
    private String gender;

    @Column(name = "birth_date", length = 6)
    private String birthDate;

    @OneToMany(mappedBy = "member", fetch = FetchType.LAZY)
    private List<Meeting> meetings;

    @OneToMany(mappedBy = "member", fetch = FetchType.LAZY)
    private List<MeetingAttendance> meetingAttendances;

    @Column(name = "kakao_user_id", nullable = false, length = 50)
    private String kakaoUserId;

    @Column(name = "refresh_token")
    private String refreshToken;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;


    public void updateMemberName(String name) {
        this.name = name;
    }

    public void updateMemberRole(Role role) {
        this.role = role;
    }

    public void updateMemberBirthDate(String birthDate) {
        this.birthDate = birthDate;
    }

    public void updateMemberGender(String gender) {
        this.gender = gender;
    }

    public void updateMemberRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public void changeStatus(MemberStatus targetStatus) {
        boolean isCurrentlyActive = this.deletedAt == null;
        boolean wantToActivate = targetStatus.equals(MemberStatus.ACTIVE);

        if (isCurrentlyActive == wantToActivate) {
            throw new ExistDataException();
        }

        if (wantToActivate) {
            this.deletedAt = null;
        } else {
            this.deletedAt = LocalDateTime.now();
        }
    }
}
