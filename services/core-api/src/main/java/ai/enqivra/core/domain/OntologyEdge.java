package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "ontology_edges")
public class OntologyEdge {
  @Id private UUID id;

  @Column(name = "source_id", nullable = false)
  private UUID sourceId;

  @Column(name = "target_id", nullable = false)
  private UUID targetId;

  @Column(nullable = false)
  private String relationship;

  private BigDecimal weight;

  protected OntologyEdge() {}

  public UUID getId() {
    return id;
  }

  public UUID getSourceId() {
    return sourceId;
  }

  public UUID getTargetId() {
    return targetId;
  }

  public String getRelationship() {
    return relationship;
  }

  public BigDecimal getWeight() {
    return weight;
  }
}
