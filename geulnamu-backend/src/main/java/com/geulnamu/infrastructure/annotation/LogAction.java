package com.geulnamu.infrastructure.annotation;

import com.geulnamu.domain.shared.enums.ActionType;
import com.geulnamu.domain.shared.enums.DomainType;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface LogAction {
    ActionType value();                        // 액션 타입
    DomainType actionDomain();                 // 대상 엔티티 종류
}
