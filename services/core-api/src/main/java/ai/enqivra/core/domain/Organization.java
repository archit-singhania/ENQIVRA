package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "organizations")
public class Organization {
  @Id private UUID id;

  @Column(nullable = false)
  private String name;

  @Column(nullable = false, unique = true)
  private String slug;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  protected Organization() {}

  public Organization(String name, String slug) {
    this.id = UUID.randomUUID();
    this.name = name;
    this.slug = slug;
    this.createdAt = Instant.now();
  }

  public UUID getId() {
    return id;
  }

  public String getName() {
    return name;
  }

  public String getSlug() {
    return slug;
  }
}
