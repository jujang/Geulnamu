package com.geulnamu.infrastructure.annotation;

import com.geulnamu.domain.shared.enums.Level;

import java.lang.annotation.*;

@Documented
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface AccessLevel {

    Level value() default Level.MEMBER;

}
