package com.geulnamu.service.member;

import com.geulnamu.controller.member.dto.request.MemberInfoRequest;
import com.geulnamu.controller.member.dto.request.MemberListRequest;
import com.geulnamu.controller.member.dto.response.MemberInfoResponse;
import com.geulnamu.controller.member.dto.response.MemberListResponse;
import com.geulnamu.domain.member.Gender;
import com.geulnamu.domain.shared.enums.DomainType;
import com.geulnamu.infrastructure.response.paging.PagingResponse;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.repository.member.MemberQueryRepository;
import com.geulnamu.repository.member.MemberCommandRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberQueryRepository memberQueryRepository;
    private final MemberCommandRepository memberCommandRepository;


    @Transactional(rollbackFor = Exception.class)
    public void createMember(String kakaoMemberId) {
        Member member = Member.createFromKakaoInfo(kakaoMemberId, "dummy_"+kakaoMemberId);
        memberCommandRepository.save(member);
    }

    @Transactional(readOnly = true)
    public Boolean isMemberInfoRegistered(Long memberId) {
        Member member = findMemberOrThrow(memberId);
        member.checkIfRoleWasAdjustedAndReLoginRequired(); // 등급 조정(=리프레시 토큰 말소)에 의한 강제 로그아웃이 필요한지 체크
        return member.getName() != null; // true면 등록된 상태, false면 미등록 상태  // 위 구문에 의한 에러 발생 시, 재로그인 필요
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMemberInfo(Long memberId, MemberInfoRequest request) {
        Member member = memberQueryRepository.findByIdAndDeletedAtIsNull(memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
        member.updateMemberName(request.getName());
        member.updateMemberGender(Gender.valueOf(request.getGender()));
        member.updateMemberBirthDate(request.getBirthDate());
    }

    // TODO: 비활성화된 계정을 조회할 것인지 조회하지 않을 것인지 잘 고민해 볼 것
    @Transactional(readOnly = true)
    public MemberInfoResponse findMember(Long memberId) {
        Member member = findMemberOrThrow(memberId);
        return MemberInfoResponse.of(member);
    }

    @Transactional(readOnly = true)
    public MemberListResponse getMembers(MemberListRequest request) {
        Page<MemberInfoResponse> membersDslList = memberQueryRepository.findMembersWithPaging(request);

        PagingResponse pagingResponse = PagingResponse.from(membersDslList);
        List<MemberInfoResponse> memberList = membersDslList.getContent();
        return new MemberListResponse(pagingResponse, memberList);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMemberRole(Long memberId, Role targetRole) {
        Member member = findMemberOrThrow(memberId);
        member.updateMemberRole(targetRole);
        member.updateMemberRefreshToken(null); // 역할에 따라 권한이 다르기에 재접속을 강제하기 위해 리프레시 토큰 말소시킴
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateMemberName(Long memberId, String name) {
        Member member = findMemberOrThrow(memberId);
        member.updateMemberName(name);
    }

    @Transactional(rollbackFor = Exception.class)
    public void activateMember(Long memberId) {
        Member member = findMemberOrThrow(memberId);
        member.activate();
    }

    @Transactional(rollbackFor = Exception.class)
    public void deactivateMember(Long memberId) {
        Member member = findMemberOrThrow(memberId);
        member.deactivate();
        member.updateMemberRefreshToken(null); // 비활성화 계정 강제 로그아웃을 위한 설정
    }

    private Member findMemberOrThrow(Long memberId) {
        return memberQueryRepository.findById(memberId)
            .orElseThrow(() -> new NotFoundDataException(DomainType.MEMBER.getDescription()));
    }

}
