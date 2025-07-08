package com.geulnamu.repository.voc;

import com.geulnamu.domain.voc.VoC;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VoCCommandRepository extends JpaRepository<VoC, Long> {
}
