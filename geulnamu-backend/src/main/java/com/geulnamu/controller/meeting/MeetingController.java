package com.geulnamu.controller.meeting;

import com.geulnamu.controller.meeting.dto.request.MeetingCreateRequestDTO;
import com.geulnamu.controller.meeting.dto.request.MeetingUpdateRequestDTO;
import com.geulnamu.controller.meeting.dto.response.MeetingListResponseDTO;
import com.geulnamu.domain.shared.enums.Level;
import com.geulnamu.domain.shared.enums.Role;
import com.geulnamu.infrastructure.annotation.AccessLevel;
import com.geulnamu.infrastructure.annotation.AuthMemberId;
import com.geulnamu.infrastructure.annotation.AuthRole;
import com.geulnamu.infrastructure.response.BaseResponse;
import com.geulnamu.infrastructure.response.paging.PagingRequest;
import com.geulnamu.service.meeting.MeetingService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/meeting")
public class MeetingController {

    private final MeetingService meetingService;

    // TODO: 해당 요청은 이력이 남아야 될 것 같은데...
    @AccessLevel(Level.STAFF)
    @PostMapping(name = "모임 생성")
    public BaseResponse<Void> createMeeting(@AuthMemberId Long memberId, @Valid @RequestBody MeetingCreateRequestDTO requestDTO) {
        meetingService.createMeeting(memberId, requestDTO.getMeetingName(), requestDTO.getMeetingType(),
            requestDTO.getMeetingDate(), requestDTO.getDescription());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.MEMBER)
    @GetMapping(value = "/list", name = "모임 목록 조회")
    public BaseResponse<MeetingListResponseDTO> getMeetingList(@Valid PagingRequest pagingRequest) {
        MeetingListResponseDTO meetingListResponseDTO = meetingService.getMeetingList(pagingRequest);
        return BaseResponse.ofSuccess(meetingListResponseDTO);
    }

    @AccessLevel(Level.ADMIN)
    @GetMapping(value = "/list/admin", name = "모임 목록 조회(관리자용)")
    public BaseResponse<MeetingListResponseDTO> getMeetingListForAdminLevel(@Valid PagingRequest pagingRequest) {
        MeetingListResponseDTO meetingListResponseDTO = meetingService.getMeetingListForAdmin(pagingRequest);
        return BaseResponse.ofSuccess(meetingListResponseDTO);
    }

    // TODO: 나중에는 수정 이력이 남아야 될 것 같은데...
    @AccessLevel(Level.STAFF)
    @PatchMapping(value = "/{meetingId}", name = "모임 수정")
    public BaseResponse<Void> updateMeeting(@PathVariable @Min(value = 1) Long meetingId, @AuthMemberId Long memberId,
                                            @AuthRole Role role, @Valid @RequestBody MeetingUpdateRequestDTO requestDTO) {
        meetingService.updateMeeting(meetingId, memberId, role, requestDTO.getMeetingName(), requestDTO.getMeetingType(),
            requestDTO.getMeetingDate(), requestDTO.getDescription());
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{meetingId}/private", name = "지난 모임 비공개 처리 - 모임 익일부터 처리 가능")
    public BaseResponse<Void> makeMeetingPrivate(@PathVariable @Min(value = 1) Long meetingId) {
        meetingService.makeMeetingPrivate(meetingId);
        return BaseResponse.ofSuccess();
    }

    @AccessLevel(Level.ADMIN)
    @PatchMapping(value = "/{meetingId}/public", name = "비공개 모임 공개 처리")
    public BaseResponse<Void> makeMeetingPublic(@PathVariable @Min(value = 1) Long meetingId) {
        meetingService.makeMeetingPublic(meetingId);
        return BaseResponse.ofSuccess();
    }

    // TODO: 삭제 이력도 남아야 될 것 같은데...
    @AccessLevel(Level.STAFF)
    @DeleteMapping(value = "/{meetingId}", name = "개설한 모임 삭제 - 모임 시작 6시간 전까지만 가능")
    public BaseResponse<Void> removeMeeting(@PathVariable @Min(value = 1) Long meetingId, @AuthMemberId Long memberId, @AuthRole Role role) {
        meetingService.removeMeeting(meetingId, memberId, role);
        return BaseResponse.ofSuccess();
    }

}
