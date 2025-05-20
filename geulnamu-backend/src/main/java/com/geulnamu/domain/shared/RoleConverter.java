package com.geulnamu.domain.shared;

import com.geulnamu.domain.member.Role;
import jakarta.persistence.AttributeConverter;

public class RoleConverter implements AttributeConverter<Role, String> {

    @Override
    public String convertToDatabaseColumn(Role role) {
        return String.valueOf(role);
    }

    @Override
    public Role convertToEntityAttribute(String dbData) {
        return Role.valueOf(dbData);
    }

}