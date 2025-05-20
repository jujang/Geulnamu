package com.geulnamu.domain.shared;

import com.geulnamu.domain.meeting.MeetingType;
import jakarta.persistence.AttributeConverter;

public class MeetingTypeConverter implements AttributeConverter<MeetingType, String> {

    @Override
    public String convertToDatabaseColumn(MeetingType meetingType) {
        return String.valueOf(meetingType);
    }

    @Override
    public MeetingType convertToEntityAttribute(String dbData) {
        return MeetingType.valueOf(dbData);
    }

}
