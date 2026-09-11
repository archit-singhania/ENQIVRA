package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "asset_components")
public class AssetComponent {
  @Id private UUID id;

  @Column(name = "asset_id", nullable = false)
  private UUID assetId;

  @Column(nullable = false)
  private String name;

  @Column(name = "component_type", nullable = false)
  private String componentType;

  private String model;

  @Column(name = "serial_number")
  private String serialNumber;

  @Column(name = "parent_component_id")
  private UUID parentComponentId;

  @Column(name = "ontology_type_id")
  private UUID ontologyTypeId;

  protected AssetComponent() {}

  public AssetComponent(
      UUID assetId,
      String name,
      String componentType,
      String model,
      String serialNumber,
      UUID parentComponentId,
      UUID ontologyTypeId) {
    this.id = UUID.randomUUID();
    this.assetId = assetId;
    this.name = name;
    this.componentType = componentType;
    this.model = model;
    this.serialNumber = serialNumber;
    this.parentComponentId = parentComponentId;
    this.ontologyTypeId = ontologyTypeId;
  }

  public UUID getId() {
    return id;
  }

  public UUID getAssetId() {
    return assetId;
  }

  public String getName() {
    return name;
  }

  public String getComponentType() {
    return componentType;
  }

  public String getModel() {
    return model;
  }

  public String getSerialNumber() {
    return serialNumber;
  }

  public UUID getParentComponentId() {
    return parentComponentId;
  }

  public UUID getOntologyTypeId() {
    return ontologyTypeId;
  }
}
