package com.geulnamu.service.voc;

import com.geulnamu.domain.voc.VoC;
import com.geulnamu.domain.voc.VoCType;
import com.geulnamu.repository.voc.VoCCommandRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@AllArgsConstructor
public class VoCService {

    private final VoCCommandRepository voCCommandRepository;

    @Transactional(rollbackFor = Exception.class)
    public void reportError(Long memberId, String content) {
        VoC voC = VoC.createVoC(memberId, VoCType.ERROR_REPORT, content);
        voCCommandRepository.save(voC);
    }

    @Transactional(rollbackFor = Exception.class)
    public void requestFeature(Long memberId, String content) {
        VoC voC = VoC.createVoC(memberId, VoCType.FEATURE_REQUEST, content);
        voCCommandRepository.save(voC);
    }

}
