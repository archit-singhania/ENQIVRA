package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "assets")
public class Asset {
  @Id private UUID id;

  @Column(name = "organization_id", nullable = false)
  private UUID organizationId;

  @Column(name = "manufacturer_id")
  private UUID manufacturerId;

  @Column(nullable = false)
  private String name;

  @Column(nullable = false)
  private String category;

  private String model;

  @Column(name = "serial_number")
  private String serialNumber;

  @Column(nullable = false)
  private String status;

  @Column(name = "installed_at")
  private LocalDate installedAt;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  protected Asset() {}

  public Asset(
      UUID organizationId,
      UUID manufacturerId,
      String name,
      String category,
      String model,
      String serialNumber,
      LocalDate installedAt) {
    this.id = UUID.randomUUID();
    this.organizationId = organizationId;
    this.manufacturerId = manufacturerId;
    this.name = name;
    this.category = category;
    this.model = model;
    this.serialNumber = serialNumber;
    this.installedAt = installedAt;
    this.status = "ACTIVE";
    this.createdAt = Instant.now();
  }

  public UUID getId() {
    return id;
  }

  public UUID getOrganizationId() {
    return organizationId;
  }

  public UUID getManufacturerId() {
    return manufacturerId;
  }

  public String getName() {
    return name;
  }

  public String getCategory() {
    return category;
  }

  public String getModel() {
    return model;
  }

  public String getSerialNumber() {
    return serialNumber;
  }

  public String getStatus() {
    return status;
  }

  public LocalDate getInstalledAt() {
    return installedAt;
  }
}
