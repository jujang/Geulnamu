package com.geulnamu.domain.member;

import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.domain.meetingAttendance.MeetingAttendance;
import com.geulnamu.domain.shared.*;
import com.geulnamu.domain.shared.converter.GenderConverter;
import com.geulnamu.domain.shared.enums.Gender;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.global.response.ResponseMessage;
import com.geulnamu.infrastructure.exception.ExistDataException;
import com.geulnamu.infrastructure.exception.TokenException;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;


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

    @Enumerated(EnumType.STRING)
    @Column(name = "role", length = 11, nullable = false)
    private Role role;

    @Convert(converter = GenderConverter.class)
    @Column(name = "gender", length = 6)
    private Gender gender;

    @Column(name = "birth_date")
    private LocalDate birthDate;

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


    public static Member createFromKakaoInfo(String kakaoUserId, String nickname) {
        return Member.builder()
            .role(Role.MEMBER)
            .nickname(nickname)
            .kakaoUserId(kakaoUserId)
            .build();
    }

    public void updateMemberName(String newName) {
        if(this.name != null && this.name.equals(newName)) {
            throw new ExistDataException();
        }
        this.name = newName;
    }

    public void updateMemberRole(Role newRole) {
        if(this.role.equals(newRole)) {
            throw new ExistDataException();
        }
        this.role = newRole;
        this.refreshToken = null; // 역할에 따라 권한이 다르기에 재접속을 강제하기 위해 리프레시 토큰 말소시킴
    }

    public void updateMemberBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
    }

    public void updateMemberGender(Gender gender) {
        this.gender = gender;
    }

    public void updateMemberRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public void activate() {
        if(this.deletedAt == null) {
            throw new ExistDataException();
        }
        this.deletedAt = null;
    }

    public void deactivate() {
        if(this.deletedAt != null) {
            throw new ExistDataException();
        }
        this.refreshToken = null; // 비활성화 계정 강제 로그아웃을 위한 설정
        this.deletedAt = LocalDateTime.now();
    }

    public void checkIfRoleWasAdjustedAndReLoginRequired() {
        if(this.refreshToken == null) {
            throw new TokenException(ResponseMessage.REFRESH_TOKEN_NOT_VALIDATE);
            // TODO: 프론트에서 알림과 함께, 강제 로그아웃 시킬 것
        }
    }
}
