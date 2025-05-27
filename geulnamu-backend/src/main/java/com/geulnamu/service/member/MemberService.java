package com.geulnamu.service.member;

import com.geulnamu.controller.member.dto.MemberInfoRequestDTO;
import com.geulnamu.controller.member.dto.MemberInfoResponseDTO;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.domain.shared.enums.MemberStatus;
import com.geulnamu.domain.shared.enums.TokenType;
import com.geulnamu.global.response.ResponseMessage;
import com.geulnamu.infrastructure.exception.ExistDataException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.exception.TokenException;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import com.geulnamu.repository.member.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final JwtTokenUtil jwtTokenUtil;


    @Transactional(rollbackFor = Exception.class)
    public void createMember(String kakaoMemberId) {
        Member member = createDefaultMemberInfo(kakaoMemberId);
        memberRepository.save(member);
    }

    @Transactional(readOnly = true)
    public Boolean checkMemberInfoRegister(String accessToken) {
        Long memberId = jwtTokenUtil.getMemberId(accessToken, TokenType.AccessToken);
        Member member = memberRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);
        checkRefreshTokenIsNullForAdjustRole(member); // 등급 조정(=리프레시 토큰 말소)에 의한 강제 로그아웃이 필요한지 체크
        return member.getName() != null; // true면 등록된 상태, false면 미등록 상태  // 위 구문에 의한 에러 발생 시, 재로그인 필요
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMemberInfo(String accessToken, MemberInfoRequestDTO memberInfoRequestDTO) {
        Long memberId = jwtTokenUtil.getMemberId(accessToken, TokenType.AccessToken);
        Member member = memberRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);
        member.updateMemberName(memberInfoRequestDTO.getName());
        member.updateMemberBirthDate(memberInfoRequestDTO.getBirthDate());
        member.updateMemberGender(memberInfoRequestDTO.getGender());
    }

    // 일단 여기서는 비활성화된 멤버는 조회하지 않도록 함
    @Transactional(rollbackFor = Exception.class)
    public void updateMemberRole(Long memberId, Role targetRole) {
        Member member = memberRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);
        validateRoleChange(targetRole, member);
        member.updateMemberRole(targetRole);
        member.updateMemberRefreshToken(null); // 역할에 따라서 권한이 다르기에 재접속을 강제하기 위해 리프레시 토큰 말소시킴
    }

    // TODO: 비활성화된 계정을 조회할 것인지 조회하지 않을 것인지 잘 고민해 볼 것
    @Transactional(readOnly = true)
    public MemberInfoResponseDTO findMember(Long memberId) {
        Member member = memberRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        return MemberInfoResponseDTO.of(member);
    }

    @Transactional(rollbackFor = Exception.class)
    public void changeMemberStatus(Long memberId, MemberStatus targetStatus) {
        Member member = memberRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        member.changeStatus(targetStatus);
    }


    private static Member createDefaultMemberInfo(String kakaoMemberId) {
        return Member.builder()
            .role(Role.MEMBER)
            .nickname("dummy_" + kakaoMemberId)
            .kakaoUserId(kakaoMemberId)
            .build();
    }

    private static void checkRefreshTokenIsNullForAdjustRole(Member member) {
        if(member.getRefreshToken() == null) {
            throw new TokenException(ResponseMessage.REFRESH_TOKEN_NOT_VALIDATE);
        }
    }

    private static void validateRoleChange(Role targetRole, Member member) {
        if(member.getRole() == targetRole) {
            throw new ExistDataException();
        }
    }

}
