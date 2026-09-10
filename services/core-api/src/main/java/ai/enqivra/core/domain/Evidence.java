package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "evidence")
public class Evidence {
  @Id private UUID id;

  @Column(name = "case_id", nullable = false)
  private UUID caseId;

  @Column(name = "uploaded_by", nullable = false)
  private UUID uploadedBy;

  @Column(name = "evidence_type", nullable = false)
  private String evidenceType;

  @Column(name = "original_filename", nullable = false)
  private String originalFilename;

  @Column(name = "content_type", nullable = false)
  private String contentType;

  @Column(name = "size_bytes", nullable = false)
  private long sizeBytes;

  @Column(name = "storage_key", nullable = false, unique = true)
  private String storageKey;

  @Column(columnDefinition = "TEXT")
  private String notes;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  protected Evidence() {}

  public Evidence(
      UUID caseId,
      UUID uploadedBy,
      String evidenceType,
      String originalFilename,
      String contentType,
      long sizeBytes,
      String storageKey,
      String notes) {
    this.id = UUID.randomUUID();
    this.caseId = caseId;
    this.uploadedBy = uploadedBy;
    this.evidenceType = evidenceType;
    this.originalFilename = originalFilename;
    this.contentType = contentType;
    this.sizeBytes = sizeBytes;
    this.storageKey = storageKey;
    this.notes = notes;
    this.createdAt = Instant.now();
  }

  public UUID getId() {
    return id;
  }

  public UUID getCaseId() {
    return caseId;
  }

  public String getEvidenceType() {
    return evidenceType;
  }

  public String getOriginalFilename() {
    return originalFilename;
  }

  public String getContentType() {
    return contentType;
  }

  public long getSizeBytes() {
    return sizeBytes;
  }

  public String getNotes() {
    return notes;
  }

  public Instant getCreatedAt() {
    return createdAt;
  }
}
