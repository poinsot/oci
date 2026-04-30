package com.ociproject.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDate;

@Data
@Schema(description = "Request payload for updating a task")
public class UpdateTaskRequest {
    private String title;
    private String description;
    private Long sprintId;
    @Schema(description = "Task lifecycle stage", allowableValues = {"BACKLOG", "SPRINT", "COMPLETED"})
    private String taskStage;
    @Schema(description = "Task status", allowableValues = {"PENDING", "IN_PROGRESS", "DONE", "BLOCKED"})
    private String status;
    @Schema(description = "Task priority", allowableValues = {"LOW", "MEDIUM", "HIGH"})
    private String priority;
    @Schema(description = "Free-form task type label (e.g. Bug, Feature, Chore)")
    private String type;
    private Long assignedTo;
    private LocalDate dueDate;
}
