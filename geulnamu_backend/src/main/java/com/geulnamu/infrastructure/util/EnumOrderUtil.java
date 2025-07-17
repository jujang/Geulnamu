package com.geulnamu.infrastructure.util;

import com.querydsl.core.types.OrderSpecifier;
import com.querydsl.core.types.dsl.EnumPath;
import com.querydsl.core.types.dsl.Expressions;

public class EnumOrderUtil {

    public static <T extends Enum<T>> OrderSpecifier<Integer> createEnumOrder(
        EnumPath<T> enumPath, Class<T> enumClass, boolean isAsc) {

        var caseBuilder = Expressions.cases();
        T[] enumValues = enumClass.getEnumConstants();

        var result = caseBuilder.when(enumPath.eq(enumValues[0]))
            .then(isAsc ? 1 : enumValues.length);

        for(int i = 0; i < enumValues.length; i++) {
            int orderValue = isAsc ? (i + 1) : (enumValues.length - i);
            result = result.when(enumPath.eq(enumValues[i])).then(orderValue);
        }

        return result.otherwise(isAsc ? 99 : 0).asc();
    }

}
