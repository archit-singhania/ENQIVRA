package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.util.UUID;

@Entity
@Table(name = "organization_members")
@IdClass(OrganizationMember.Key.class)
public class OrganizationMember {
  @Id
  @Column(name = "organization_id")
  private UUID organizationId;

  @Id
  @Column(name = "user_id")
  private UUID userId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Role role;

  protected OrganizationMember() {}

  public OrganizationMember(UUID organizationId, UUID userId, Role role) {
    this.organizationId = organizationId;
    this.userId = userId;
    this.role = role;
  }

  public UUID getOrganizationId() {
    return organizationId;
  }

  public UUID getUserId() {
    return userId;
  }

  public Role getRole() {
    return role;
  }

  public record Key(UUID organizationId, UUID userId) implements Serializable {}
}
