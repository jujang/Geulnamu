package com.geulnamu.domain.shared.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DomainType {
    LOGIN("login"),
    MEMBER("member"),
    MEETING("meeting"),
    ATTENDANCE("attendance"),
    BOOK_QUESTION("bookQuestion"),
    VOC("voc"),
    ACTION_HISTORY("actionHistory"),
    FCM("fcm"),
    FCM_TFM("fcmTokenForMeeting");

    private final String description;
}
