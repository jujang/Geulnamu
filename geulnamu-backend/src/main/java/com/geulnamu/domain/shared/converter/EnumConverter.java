package com.geulnamu.domain.shared.converter;

import jakarta.persistence.AttributeConverter;

public abstract class EnumConverter<E extends Enum<E>> implements AttributeConverter<E, String> {

    private final Class<E> enumClass;

    protected EnumConverter(Class<E> enumClass) {
        this.enumClass = enumClass;
    }

    @Override
    public String convertToDatabaseColumn(E attribute) {
        return attribute != null ? attribute.name() : null;
    }

    @Override
    public E convertToEntityAttribute(String dbData) {
        return dbData != null ? Enum.valueOf(enumClass, dbData) : null;
    }

}
