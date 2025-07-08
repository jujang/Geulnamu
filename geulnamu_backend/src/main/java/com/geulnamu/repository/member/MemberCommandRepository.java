package com.geulnamu.repository.member;

import com.geulnamu.domain.member.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberCommandRepository extends JpaRepository<Member, Long> {

}
