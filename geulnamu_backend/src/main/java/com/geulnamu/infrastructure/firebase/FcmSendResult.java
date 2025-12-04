package com.geulnamu.infrastructure.firebase;

public record FcmSendResult(int successCount, int failureCount) {
    public boolean isAllSuccess() {
        return failureCount == 0;
    }
    public boolean isAllFailed() {
        return successCount == 0;
    }
}
