package com.geulnamu.domain.actionHistory;

import com.geulnamu.domain.shared.DateColumn;
import com.geulnamu.domain.shared.enums.ActionStatus;
import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Builder
@Entity(name = "action_histories")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ActionHistory extends DateColumn {

    @Id
    @Column(name = "action_history_id", updatable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 요청한 액션 타입 (성공/실패 관계없이 동일)
    @Enumerated(EnumType.STRING)
    @Column(name = "action_type", nullable = false, length = 30)
    private ActionType actionType;

    // 요청 결과 (성공/실패)
    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 10, nullable = false)
    private ActionStatus status;

    // 요청을 수행한 모임원
    @Column(name = "actor_member_id")
    private Long actorMemberId;

    // 대상 도메인
    @Enumerated(EnumType.STRING)
    @Column(name = "action_domain", length = 20)
    private DomainType actionDomain;

    @Column(name = "target_id")
    private Long targetId;

    // 실제 요청 데이터 (JSON 형태)
    @Column(name = "request_data", columnDefinition = "TEXT")
    private String requestData;

    // 응답 데이터 (JSON 형태)
    @Column(name = "response_data", columnDefinition = "TEXT")
    private String responseData;

    @Enumerated(EnumType.STRING)
    @Column(name = "request_method", length = 10)
    private ApiMethod requestMethod;

    @Column(name = "request_uri", length = 500)
    private String requestUri;

    @Column(name = "processing_time_ms")
    private Long processingTimeMs;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "user_agent", length = 300)
    private String userAgent;

}
