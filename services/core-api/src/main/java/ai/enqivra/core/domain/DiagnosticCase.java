package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "diagnostic_cases")
public class DiagnosticCase {
  @Id private UUID id;

  @Column(name = "organization_id", nullable = false)
  private UUID organizationId;

  @Column(name = "asset_id", nullable = false)
  private UUID assetId;

  @Column(name = "created_by", nullable = false)
  private UUID createdBy;

  @Column(nullable = false)
  private String title;

  @Column(nullable = false, columnDefinition = "TEXT")
  private String complaint;

  @Column(nullable = false)
  private String status;

  @Column(name = "safety_level", nullable = false)
  private String safetyLevel;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt;

  protected DiagnosticCase() {}

  public DiagnosticCase(
      UUID organizationId, UUID assetId, UUID createdBy, String title, String complaint) {
    this.id = UUID.randomUUID();
    this.organizationId = organizationId;
    this.assetId = assetId;
    this.createdBy = createdBy;
    this.title = title;
    this.complaint = complaint;
    this.status = "OPEN";
    this.safetyLevel = "GREEN";
    this.createdAt = Instant.now();
    this.updatedAt = this.createdAt;
  }

  public UUID getId() {
    return id;
  }

  public UUID getOrganizationId() {
    return organizationId;
  }

  public UUID getAssetId() {
    return assetId;
  }

  public String getTitle() {
    return title;
  }

  public String getComplaint() {
    return complaint;
  }

  public String getStatus() {
    return status;
  }

  public String getSafetyLevel() {
    return safetyLevel;
  }

  public Instant getCreatedAt() {
    return createdAt;
  }
}
