package com.geulnamu.repository.voc;

import com.geulnamu.domain.voc.VoC;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VoCQueryRepository extends JpaRepository<VoC, Long>, VoCQueryRepositoryCustom {
}
