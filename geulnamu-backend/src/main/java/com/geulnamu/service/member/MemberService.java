package com.geulnamu.service.member;

import com.geulnamu.controller.member.dto.MemberInfoResponseDTO;
import com.geulnamu.controller.member.dto.MemberCreateRequestDTO;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.member.Role;
import com.geulnamu.domain.shared.MemberStatus;
import com.geulnamu.infrastructure.exception.ExistDataException;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.repository.member.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;

    @Transactional(rollbackFor = Exception.class)
    public void createMember(MemberCreateRequestDTO memberCreateRequestDTO) {
        memberRepository.save(getMember(memberCreateRequestDTO)); // TODO: 추후 여기에 kakaoId 값을 넣는 방식으로 체크를 해줘야 될 것 같은데...;;
    }

    // TODO: 일단 여기서는 비활성화된 멤버는 조회하지 않도록 함
    @Transactional(rollbackFor = Exception.class)
    public void updateMemberRole(Long memberId, Role targetRole) {
        Member member = memberRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);
        validateRoleChange(targetRole, member);
        member.updateMemberRole(targetRole);
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


    private static Member getMember(MemberCreateRequestDTO memberCreateRequestDTO) {
        return Member.builder()
            .name(memberCreateRequestDTO.getName())
            .role(Role.MEMBER)
            .birthDate(memberCreateRequestDTO.getBirthDate())
            .gender(memberCreateRequestDTO.getGender())
            .build();
    }

    private static void validateRoleChange(Role targetRole, Member member) {
        if(member.getRole() == targetRole) {
            throw new ExistDataException();
        }
    }

}
