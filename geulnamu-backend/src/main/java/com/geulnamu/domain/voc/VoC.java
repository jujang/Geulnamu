package com.geulnamu.domain.voc;

import com.geulnamu.domain.shared.converter.VoCTypeConverter;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Getter
@Builder
@Entity(name = "voc")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class VoC {

    @Id
    @Column(name = "voc_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "member_id", nullable = false)
    private Long memberId;

    @Convert(converter = VoCTypeConverter.class)
    @Column(name = "voc_type", length = 15, nullable = false)
    private VoCType voCType;

    @Column(name = "content", nullable = false)
    private String content;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;


    public static VoC createVoC(Long memberId, VoCType voCType, String content) {
        return VoC.builder()
            .memberId(memberId)
            .voCType(voCType)
            .content(content)
            .build();
    }
}
