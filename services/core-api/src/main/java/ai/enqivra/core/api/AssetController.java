package ai.enqivra.core.api;

import ai.enqivra.core.domain.Asset;
import ai.enqivra.core.domain.AssetComponent;
import ai.enqivra.core.domain.Manufacturer;
import ai.enqivra.core.domain.OntologyNode;
import ai.enqivra.core.repository.AssetComponentRepository;
import ai.enqivra.core.repository.AssetRepository;
import ai.enqivra.core.repository.ManufacturerRepository;
import ai.enqivra.core.repository.OntologyNodeRepository;
import ai.enqivra.core.service.AccessService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class AssetController {
  private final AssetRepository assets;
  private final AssetComponentRepository components;
  private final ManufacturerRepository manufacturers;
  private final AccessService access;
  private final OntologyNodeRepository ontologyNodes;

  public AssetController(
      AssetRepository assets,
      AssetComponentRepository components,
      ManufacturerRepository manufacturers,
      AccessService access,
      OntologyNodeRepository ontologyNodes) {
    this.assets = assets;
    this.components = components;
    this.manufacturers = manufacturers;
    this.access = access;
    this.ontologyNodes = ontologyNodes;
  }

  public record AssetRequest(
      @NotBlank @Size(max = 160) String name,
      @NotBlank @Size(max = 100) String category,
      UUID manufacturerId,
      @Size(max = 160) String model,
      @Size(max = 160) String serialNumber,
      LocalDate installedAt,
      @Size(max = 120) String ontologyCode) {}

  public record ManufacturerRequest(
      @NotBlank @Size(max = 160) String name, @Size(max = 500) String website) {}

  public record ComponentRequest(
      @NotBlank @Size(max = 160) String name,
      @NotBlank @Size(max = 100) String componentType,
      @Size(max = 160) String model,
      @Size(max = 160) String serialNumber,
      UUID parentComponentId,
      @Size(max = 120) String ontologyCode) {}

  @GetMapping("/assets")
  List<Asset> list(@RequestParam UUID organizationId, @AuthenticationPrincipal UUID userId) {
    access.requireMember(organizationId, userId);
    return assets.findByOrganizationIdOrderByName(organizationId);
  }

  @PostMapping("/assets")
  @ResponseStatus(HttpStatus.CREATED)
  Asset create(
      @RequestParam UUID organizationId,
      @AuthenticationPrincipal UUID userId,
      @Valid @RequestBody AssetRequest r) {
    access.requireEditor(organizationId, userId);
    if (r.manufacturerId() != null
        && manufacturers
            .findById(r.manufacturerId())
            .filter(m -> m.getOrganizationId().equals(organizationId))
            .isEmpty())
      throw new IllegalArgumentException("Manufacturer does not belong to organization");
    OntologyNode ontologyType = null;
    if (r.ontologyCode() != null && !r.ontologyCode().isBlank()) {
      ontologyType =
          ontologyNodes
              .findByCodeAndActiveTrue(r.ontologyCode())
              .filter(n -> n.getKind().equals("EQUIPMENT_TYPE"))
              .orElseThrow(() -> new IllegalArgumentException("Unknown equipment ontology type"));
    }
    return assets.save(
        new Asset(
            organizationId,
            r.manufacturerId(),
            r.name(),
            r.category(),
            r.model(),
            r.serialNumber(),
            r.installedAt(),
            ontologyType == null ? null : ontologyType.getId()));
  }

  @GetMapping("/manufacturers")
  List<Manufacturer> manufacturers(
      @RequestParam UUID organizationId, @AuthenticationPrincipal UUID userId) {
    access.requireMember(organizationId, userId);
    return manufacturers.findByOrganizationIdOrderByName(organizationId);
  }

  @PostMapping("/manufacturers")
  @ResponseStatus(HttpStatus.CREATED)
  Manufacturer createManufacturer(
      @RequestParam UUID organizationId,
      @AuthenticationPrincipal UUID userId,
      @Valid @RequestBody ManufacturerRequest r) {
    access.requireEditor(organizationId, userId);
    return manufacturers.save(new Manufacturer(organizationId, r.name(), r.website()));
  }

  @GetMapping("/assets/{assetId}/components")
  List<AssetComponent> components(
      @PathVariable UUID assetId, @AuthenticationPrincipal UUID userId) {
    Asset asset = ownedAsset(assetId, userId);
    return components.findByAssetIdOrderByName(asset.getId());
  }

  @PostMapping("/assets/{assetId}/components")
  @ResponseStatus(HttpStatus.CREATED)
  AssetComponent createComponent(
      @PathVariable UUID assetId,
      @AuthenticationPrincipal UUID userId,
      @Valid @RequestBody ComponentRequest r) {
    Asset asset = ownedAsset(assetId, userId);
    access.requireEditor(asset.getOrganizationId(), userId);
    if (r.parentComponentId() != null
        && components
            .findById(r.parentComponentId())
            .filter(c -> c.getAssetId().equals(assetId))
            .isEmpty())
      throw new IllegalArgumentException("Parent component does not belong to asset");
    OntologyNode ontologyType = null;
    if (r.ontologyCode() != null && !r.ontologyCode().isBlank()) {
      ontologyType =
          ontologyNodes
              .findByCodeAndActiveTrue(r.ontologyCode())
              .filter(n -> n.getKind().equals("COMPONENT_TYPE"))
              .orElseThrow(() -> new IllegalArgumentException("Unknown component ontology type"));
    }
    return components.save(
        new AssetComponent(
            assetId,
            r.name(),
            r.componentType(),
            r.model(),
            r.serialNumber(),
            r.parentComponentId(),
            ontologyType == null ? null : ontologyType.getId()));
  }

  private Asset ownedAsset(UUID id, UUID userId) {
    Asset asset = assets.findById(id).orElseThrow(() -> new NotFoundException("Asset not found"));
    access.requireMember(asset.getOrganizationId(), userId);
    return asset;
  }
}
