package com.geulnamu.service.auth;

import com.geulnamu.controller.auth.dto.response.LoginResponseDTO;
import com.geulnamu.domain.member.Member;
import com.geulnamu.domain.shared.TokenPair;
import com.geulnamu.domain.shared.TokenReissueResult;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.domain.shared.enums.TokenType;
import com.geulnamu.global.response.ResponseMessage;
import com.geulnamu.infrastructure.exception.NotFoundDataException;
import com.geulnamu.infrastructure.exception.TokenException;
import com.geulnamu.infrastructure.util.JwtTokenUtil;
import com.geulnamu.repository.member.MemberRepository;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;

@Slf4j
@Component
@RequiredArgsConstructor
public class LoginFacade {

    private final KakaoOAuthService kakaoOAuthService;
    private final AuthTokenService authTokenService;
    private final MemberRepository memberRepository;
    private final JwtTokenUtil jwtTokenUtil;

    /**
     * 카카오 로그인 전체 플로우
     */
    @Transactional(rollbackFor = Exception.class)
    public LoginResponseDTO loginWithKakao(String authorizationCode, HttpServletResponse response) {
        // 1.OAuth 처리
        Map<String, Object> userInfo = kakaoOAuthService.getKakaoUserInfoAndLogout(authorizationCode);

        // 2.회원 처리
        MemberResult memberResult = findOrCreateMember(userInfo);
        Member member = memberResult.getMember();
        boolean isNewMember = memberResult.isNewMember();

        // 3. 토큰 생성 + 쿠키 설정
        TokenPair tokenPair = authTokenService.createTokensAndSetCookie(
            member.getId(), member.getRole(), response);

        // 4. 회원의 리프레시 토큰 업데이트(DB)
        member.updateMemberRefreshToken(tokenPair.refreshToken());

        return LoginResponseDTO.of(tokenPair.accessToken(), isNewMember);
    }

    /**
     * 토큰 재발급 플로우
     */
    @Transactional(rollbackFor = Exception.class)
    public String reissueAccessToken(String refreshToken, HttpServletResponse response) {
        // 1. 리프레시 토큰 검증
        if(!authTokenService.validateRefreshToken(refreshToken)) {
            throw new TokenException(ResponseMessage.REFRESH_TOKEN_NOT_VALIDATE);
        }

        // 2. 토큰에서 회원 정보 추출
        Long memberId = jwtTokenUtil.getMemberId(refreshToken, TokenType.RefreshToken);
        Member member = memberRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);
        Role role = jwtTokenUtil.getRole(refreshToken, TokenType.RefreshToken);

        // 3. 토큰 재발급 (리프레시 토큰 재발급 여부 확인 함께 진행)
        TokenReissueResult tokenReissueResult = authTokenService.reissueAccessToken(
            refreshToken, memberId, role, response);

        // 4. DB의 리프레시 토큰 업데이트 (갱신된 경우에만)
        if(!tokenReissueResult.refreshToken().equals(refreshToken)) {
            member.updateMemberRefreshToken(tokenReissueResult.refreshToken());
        }

        return tokenReissueResult.accessToken();
    }

    /**
     * 로그아웃 플로우
     */
    @Transactional(rollbackFor = Exception.class)
    public void logout(String accessToken, HttpServletResponse response) {
        // 1. 액세스 토큰에서 회원 정보 추출
        Long memberId = jwtTokenUtil.getMemberId(accessToken, TokenType.AccessToken);
        Member member = memberRepository.findById(memberId).orElseThrow(NotFoundDataException::new);

        // 2. DB 에서 리프레시 토큰 삭제
        member.updateMemberRefreshToken(null);

        // 3. 쿠키에서 리프레시 토큰 삭제
        authTokenService.clearRefreshTokenCookie(response);
        log.info("사용자 로그아웃 완료: memberId={}", memberId);
    }

    /**
     * 임시 로그인 메서드 (TODO: 운영 시 삭제)
     */
    @Transactional(rollbackFor = Exception.class)
    public LoginResponseDTO loginForDevelopment(Long memberId, HttpServletResponse response) {
        Member member = memberRepository.findByIdAndDeletedAtIsNull(memberId).orElseThrow(NotFoundDataException::new);

        TokenPair tokenPair = authTokenService.createTokensAndSetCookie(
            member.getId(), member.getRole(), response);

        member.updateMemberRefreshToken(tokenPair.refreshToken());

        return LoginResponseDTO.of(tokenPair.accessToken(), false);
    }


    /**
     * 회원 찾기 또는 생성하는 private 메서드
     */
    private MemberResult findOrCreateMember(Map<String, Object> userInfo) {
        String kakaoUserId = userInfo.get("id").toString();
        System.out.println("kakaoUserId: " + kakaoUserId);
        Optional<Member> memberOptional = memberRepository.findByKakaoUserId(kakaoUserId);

        if(memberOptional.isEmpty()) {
            log.info("신규 회원 생성: kakaoUserId={}", kakaoUserId);
            String nickname = Member.extractNickName(userInfo);
            Member newMember = Member.createFromKakaoInfo(kakaoUserId, nickname);
            Member savedMember = memberRepository.save(newMember);
            return new MemberResult(savedMember, true);
        } else {
            log.info("기존 회원 로그인: kakaoUserId={}", kakaoUserId);
            return new MemberResult(memberOptional.get(), false);
        }
    }

    /**
     * 회원 조회/생성 결과를 담는 내부 클래스
     */
    @Getter
    @AllArgsConstructor
    private static class MemberResult {
        private final Member member;
        private final boolean isNewMember;
    }
}
