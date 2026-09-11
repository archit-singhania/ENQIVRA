package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "organization_invitations")
public class OrganizationInvitation {
  public enum Status {
    PENDING,
    ACCEPTED,
    REVOKED,
    EXPIRED
  }

  @Id private UUID id;

  @Column(name = "organization_id", nullable = false)
  private UUID organizationId;

  @Column(nullable = false)
  private String email;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Role role;

  @Column(name = "token_hash", nullable = false, unique = true)
  private String tokenHash;

  @Column(name = "invited_by", nullable = false)
  private UUID invitedBy;

  @Column(name = "accepted_by")
  private UUID acceptedBy;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Status status;

  @Column(name = "expires_at", nullable = false)
  private Instant expiresAt;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  @Column(name = "accepted_at")
  private Instant acceptedAt;

  protected OrganizationInvitation() {}

  public OrganizationInvitation(
      UUID organizationId,
      String email,
      Role role,
      String tokenHash,
      UUID invitedBy,
      Instant expiresAt) {
    this.id = UUID.randomUUID();
    this.organizationId = organizationId;
    this.email = email.trim().toLowerCase(java.util.Locale.ROOT);
    this.role = role;
    this.tokenHash = tokenHash;
    this.invitedBy = invitedBy;
    this.expiresAt = expiresAt;
    this.status = Status.PENDING;
    this.createdAt = Instant.now();
  }

  public void accept(UUID userId) {
    status = Status.ACCEPTED;
    acceptedBy = userId;
    acceptedAt = Instant.now();
  }

  public void revoke() {
    status = Status.REVOKED;
  }

  public void expire() {
    status = Status.EXPIRED;
  }

  public UUID getId() {
    return id;
  }

  public UUID getOrganizationId() {
    return organizationId;
  }

  public String getEmail() {
    return email;
  }

  public Role getRole() {
    return role;
  }

  public String getTokenHash() {
    return tokenHash;
  }

  public UUID getInvitedBy() {
    return invitedBy;
  }

  public UUID getAcceptedBy() {
    return acceptedBy;
  }

  public Status getStatus() {
    return status;
  }

  public Instant getExpiresAt() {
    return expiresAt;
  }

  public Instant getCreatedAt() {
    return createdAt;
  }

  public Instant getAcceptedAt() {
    return acceptedAt;
  }
}
