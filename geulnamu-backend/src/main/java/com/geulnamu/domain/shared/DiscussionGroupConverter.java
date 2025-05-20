package com.geulnamu.domain.shared;

import com.geulnamu.domain.meetingAttendance.DiscussionGroup;
import jakarta.persistence.AttributeConverter;

public class DiscussionGroupConverter implements AttributeConverter<DiscussionGroup, String> {

    @Override
    public String convertToDatabaseColumn(DiscussionGroup discussionGroup) {
        return String.valueOf(discussionGroup);
    }

    @Override
    public DiscussionGroup convertToEntityAttribute(String dbData) {
        return DiscussionGroup.valueOf(dbData);
    }

}
