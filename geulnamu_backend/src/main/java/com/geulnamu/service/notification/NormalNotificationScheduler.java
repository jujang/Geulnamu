package com.geulnamu.service.notification;

import com.geulnamu.domain.attendance.Attendance;
import com.geulnamu.domain.attendance.DiscussionGroup;
import com.geulnamu.domain.meeting.Meeting;
import com.geulnamu.repository.attendance.AttendanceQueryRepository;
import com.geulnamu.infrastructure.firebase.FcmPushSender;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class NormalNotificationScheduler {

    private final AttendanceQueryRepository attendanceQueryRepository;
    private final FcmPushSender fcmPushSender;


    // 토론 시작 시간에 해당 모임에 참여한 (토론을 희망하는) 인원들의 조를 APP PUSH 하기
    @Transactional(readOnly = true)
    @Scheduled(cron = "0 0/5 * * * *") // 초 분 시 일 월 요일
    public void discussionGroupNotification() {
        // 현재 시간에 토론 참여하는 참석자 명단 조회
        LocalDateTime now = LocalDateTime.now().withSecond(0).withNano(0);
        List<Attendance> wantDiscussionAttendances = attendanceQueryRepository.findAllForDiscussionNotification(now);

        // 토론 참여 명단 (모임별로) 그룹화
        Map<Meeting, Map<DiscussionGroup, List<Attendance>>> groupedData = wantDiscussionAttendances.stream()
            .collect(Collectors.groupingBy(
                Attendance::getMeeting,
                Collectors.groupingBy(Attendance::getDiscussionGroup)
            ));

        for(Map.Entry<Meeting, Map<DiscussionGroup, List<Attendance>>> meetingEntry : groupedData.entrySet()) {
            Meeting meeting = meetingEntry.getKey();
            for(Map.Entry<DiscussionGroup, List<Attendance>> groupEntry : meetingEntry.getValue().entrySet()) {
                List<Attendance> groupMembers = groupEntry.getValue();

                String title = meeting.getAlarmMessage();

                String body = groupMembers.stream()
                    .map(attendance -> attendance.getMember().getName())
                    .collect(Collectors.joining(", "));

                // 모임 참여 페이지
                Map<String, String> data = Map.of(
                    "type", "DISCUSSION_GROUP",
                    "meetingId", meeting.getId().toString()
                );

                // PUSH 하기
                List<String> tokens = groupMembers.stream()
                    .map(Attendance::getFcmToken)
                    .filter(token -> !token.isBlank())
                    .toList();

                if(!tokens.isEmpty()) {
                    fcmPushSender.sendToMultiple(tokens, title, body, data);
                }
            }
        }
        log.info("토론 알림 발송 완료: 시간 - {} , {}명", now, wantDiscussionAttendances.size());
        // TODO: 누구(+FCM token값)한테, 어떤 알림 보냈는지를 모아서, slack 메세지로 남기고 싶은데 가능하려나
    }

}
