package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "ontology_nodes")
public class OntologyNode {
  @Id private UUID id;

  @Column(nullable = false, unique = true)
  private String code;

  @Column(nullable = false)
  private String kind;

  @Column(nullable = false)
  private String domain;

  @Column(nullable = false)
  private String name;

  @Column(nullable = false)
  private String description;

  @Column(name = "safety_level", nullable = false)
  private String safetyLevel;

  @Column(name = "parent_id")
  private UUID parentId;

  @Column(nullable = false)
  private boolean active;

  protected OntologyNode() {}

  public UUID getId() {
    return id;
  }

  public String getCode() {
    return code;
  }

  public String getKind() {
    return kind;
  }

  public String getDomain() {
    return domain;
  }

  public String getName() {
    return name;
  }

  public String getDescription() {
    return description;
  }

  public String getSafetyLevel() {
    return safetyLevel;
  }

  public UUID getParentId() {
    return parentId;
  }

  public boolean isActive() {
    return active;
  }
}
