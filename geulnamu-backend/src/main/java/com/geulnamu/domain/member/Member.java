package com.geulnamu.domain.member;

import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.meetingAttendance.MeetingAttendance;
import com.geulnamu.domain.shared.DateColumn;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;


@Getter
@Entity(name = "members")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Member extends DateColumn {

    @Id
    @Column(name = "member_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", length = 10)
    private String name;

    @Column(name = "role", length = 10)
    private Role role;

    @Column(name = "gender", length = 6)
    private Gender gender;

    @Column(name = "birth_date", length = 6)
    private String birthDate;

    @OneToMany(mappedBy = "member", fetch = FetchType.LAZY)
    private List<Meeting> meetings;

    @OneToMany(mappedBy = "member", fetch = FetchType.LAZY)
    private List<MeetingAttendance> meetingAttendances;

    @Column(name = "kakao_oauth_code", /*nullable = false,*/ length = 50)
    private String kakaoOAuthCode;

    @Column(name = "refresh_token")
    private String refreshToken;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}
