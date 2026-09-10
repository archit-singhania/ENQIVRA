package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "manufacturers")
public class Manufacturer {
  @Id private UUID id;

  @Column(name = "organization_id", nullable = false)
  private UUID organizationId;

  @Column(nullable = false)
  private String name;

  private String website;

  protected Manufacturer() {}

  public Manufacturer(UUID organizationId, String name, String website) {
    this.id = UUID.randomUUID();
    this.organizationId = organizationId;
    this.name = name;
    this.website = website;
  }

  public UUID getId() {
    return id;
  }

  public UUID getOrganizationId() {
    return organizationId;
  }

  public String getName() {
    return name;
  }

  public String getWebsite() {
    return website;
  }
}
