package com.geulnamu.domain.voc;

import com.geulnamu.domain.shared.DateColumn;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Builder
@Entity(name = "voc")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class VoC extends DateColumn {

    @Id
    @Column(name = "voc_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "member_id", nullable = false)
    private Long memberId;

    @Enumerated(EnumType.STRING)
    @Column(name = "voc_type", length = 15, nullable = false)
    private VoCType voCType;

    @Column(name = "content", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "issue_status", length = 12, nullable = false)
    private IssueStatus issueStatus;

    @Column(name = "admin_comment", length = 255)
    private String adminComment;


    public static VoC createVoC(Long memberId, VoCType voCType, String content) {
        return VoC.builder()
            .memberId(memberId)
            .voCType(voCType)
            .content(content)
            .issueStatus(IssueStatus.PENDING)
            .build();
    }
}
