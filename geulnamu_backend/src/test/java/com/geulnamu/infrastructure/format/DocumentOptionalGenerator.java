package com.geulnamu.infrastructure.format;

import org.springframework.restdocs.snippet.Attributes;

import static org.springframework.restdocs.snippet.Attributes.key;

public class DocumentOptionalGenerator {

    public static Attributes.Attribute setAttributes(String value) {
        return key("format").value(value);
    }

}
