package com.geulnamu.controller.voc.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.geulnamu.domain.voc.IssueStatus;
import com.geulnamu.domain.voc.VoCType;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class VoCViewResponse {

    private Long vocId;
    private Long memberId;
    private VoCType voCType;
    private String content;
    private IssueStatus issueStatus;
    private String adminComment;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime createdAt;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy.MM.dd HH:mm")
    private LocalDateTime lastModifiedAt;

}
