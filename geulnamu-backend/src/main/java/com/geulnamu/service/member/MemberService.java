package com.geulnamu.service.member;

import com.geulnamu.controller.member.dto.response.MemberInfoResponseDTO;
import com.geulnamu.controller.member.dto.response.MemberListResponseDTO;
import com.geulnamu.domain.member.Gender;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.repository.member.MemberQueryRepository;
import com.geulnamu.repository.member.MemberCommandRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberCommandRepository memberCommandRepository;
    private final MemberQueryRepository memberQueryRepository;


    @Transactional(rollbackFor = Exception.class)
    public void createMember(String kakaoMemberId) {
        Member member = Member.createFromKakaoInfo(kakaoMemberId, "dummy_"+kakaoMemberId);
        memberCommandRepository.save(member);
    }

    @Transactional(readOnly = true)
    public Boolean isMemberInfoRegistered(Long memberId) {
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        member.checkIfRoleWasAdjustedAndReLoginRequired(); // 등급 조정(=리프레시 토큰 말소)에 의한 강제 로그아웃이 필요한지 체크
        return member.getName() != null; // true면 등록된 상태, false면 미등록 상태  // 위 구문에 의한 에러 발생 시, 재로그인 필요
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMemberInfo(Long memberId, String targetName, String targetGender, LocalDate targetBirthDate) {
        Member member = memberQueryRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);
        member.updateMemberName(targetName);
        member.updateMemberGender(Gender.valueOf(targetGender));
        member.updateMemberBirthDate(targetBirthDate);
    }

    // TODO: 비활성화된 계정을 조회할 것인지 조회하지 않을 것인지 잘 고민해 볼 것
    @Transactional(readOnly = true)
    public MemberInfoResponseDTO findMember(Long memberId) {
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        return MemberInfoResponseDTO.of(member);
    }

    @Transactional(readOnly = true)
    public MemberListResponseDTO getMembers(PagingRequest pagingRequest) {
        Pageable pageable = pagingRequest.of();
        Page<MemberInfoResponseDTO> membersDslList = memberQueryRepository.findMembersWithPaging(pageable);

        PagingResponse pagingResponse = PagingResponse.from(membersDslList);
        List<MemberInfoResponseDTO> memberList = membersDslList.getContent();
        return new MemberListResponseDTO(pagingResponse, memberList);
    }

    // 일단 여기서는 비활성화된 멤버는 조회하지 않도록 함
    @Transactional(rollbackFor = Exception.class)
    public void updateMemberRole(Long memberId, Role targetRole) {
        Member member = memberQueryRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);
        member.updateMemberRole(targetRole);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMemberName(Long memberId, String name) {
        Member member = memberQueryRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);
        member.updateMemberName(name);
    }

    @Transactional(rollbackFor = Exception.class)
    public void activateMember(Long memberId) {
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        member.activate();
    }

    @Transactional(rollbackFor = Exception.class)
    public void deactivateMember(Long memberId) {
        Member member = memberQueryRepository.findById(memberId).orElseThrow(NotFoundDataException::new);
        member.deactivate();
    }

}
