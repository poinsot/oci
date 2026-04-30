package com.ociproject.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
@Schema(description = "Request payload for creating a task")
public class CreateTaskRequest {
    @NotNull private Long projectId;
    private Long sprintId;
    @NotBlank private String title;
    private String description;
    @Schema(description = "Task lifecycle stage", allowableValues = {"BACKLOG", "SPRINT", "COMPLETED"})
    private String taskStage;
    @Schema(description = "Task status", allowableValues = {"PENDING", "IN_PROGRESS", "DONE", "BLOCKED"})
    private String status;
    @Schema(description = "Task priority", allowableValues = {"LOW", "MEDIUM", "HIGH"})
    private String priority;
    @Schema(description = "Free-form task type label (e.g. Bug, Feature, Chore)")
    private String type;
    @NotNull private Long createdBy;
    private Long assignedTo;
    private LocalDate dueDate;
}
