package ai.enqivra.core.api;

import ai.enqivra.core.domain.Asset;
import ai.enqivra.core.domain.DiagnosticCase;
import ai.enqivra.core.domain.Evidence;
import ai.enqivra.core.repository.AssetRepository;
import ai.enqivra.core.repository.DiagnosticCaseRepository;
import ai.enqivra.core.repository.EvidenceRepository;
import ai.enqivra.core.service.AccessService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1")
public class CaseController {
  private static final Set<String> TYPES =
      Set.of("IMAGE", "AUDIO", "VIDEO", "DOCUMENT", "TELEMETRY", "OBSERVATION");
  private final DiagnosticCaseRepository cases;
  private final EvidenceRepository evidence;
  private final AssetRepository assets;
  private final AccessService access;
  private final Path storage;

  public CaseController(
      DiagnosticCaseRepository cases,
      EvidenceRepository evidence,
      AssetRepository assets,
      AccessService access,
      @Value("${enqivra.storage.evidence-directory}") String storage) {
    this.cases = cases;
    this.evidence = evidence;
    this.assets = assets;
    this.access = access;
    this.storage = Path.of(storage).toAbsolutePath().normalize();
  }

  public record CaseRequest(
      UUID assetId,
      @NotBlank @Size(max = 200) String title,
      @NotBlank @Size(max = 5000) String complaint) {}

  @GetMapping("/cases")
  List<DiagnosticCase> list(
      @RequestParam UUID organizationId, @AuthenticationPrincipal UUID userId) {
    access.requireMember(organizationId, userId);
    return cases.findByOrganizationIdOrderByCreatedAtDesc(organizationId);
  }

  @PostMapping("/cases")
  @ResponseStatus(HttpStatus.CREATED)
  DiagnosticCase create(
      @RequestParam UUID organizationId,
      @AuthenticationPrincipal UUID userId,
      @Valid @RequestBody CaseRequest r) {
    access.requireEditor(organizationId, userId);
    Asset asset =
        assets
            .findById(r.assetId())
            .filter(a -> a.getOrganizationId().equals(organizationId))
            .orElseThrow(
                () -> new IllegalArgumentException("Asset does not belong to organization"));
    return cases.save(
        new DiagnosticCase(organizationId, asset.getId(), userId, r.title(), r.complaint()));
  }

  @GetMapping("/cases/{caseId}/evidence")
  List<Evidence> evidence(@PathVariable UUID caseId, @AuthenticationPrincipal UUID userId) {
    DiagnosticCase c = ownedCase(caseId, userId);
    return evidence.findByCaseIdOrderByCreatedAt(c.getId());
  }

  @PostMapping(value = "/cases/{caseId}/evidence", consumes = "multipart/form-data")
  @ResponseStatus(HttpStatus.CREATED)
  Evidence upload(
      @PathVariable UUID caseId,
      @AuthenticationPrincipal UUID userId,
      @RequestPart MultipartFile file,
      @RequestParam String evidenceType,
      @RequestParam(required = false) String notes)
      throws IOException {
    DiagnosticCase c = ownedCase(caseId, userId);
    access.requireEditor(c.getOrganizationId(), userId);
    String type = evidenceType.toUpperCase();
    if (!TYPES.contains(type)) throw new IllegalArgumentException("Unsupported evidence type");
    if (file.isEmpty()) throw new IllegalArgumentException("Evidence file is empty");
    String original =
        file.getOriginalFilename() == null
            ? "evidence"
            : Path.of(file.getOriginalFilename()).getFileName().toString();
    String key = c.getOrganizationId() + "/" + caseId + "/" + UUID.randomUUID();
    Path target = storage.resolve(key).normalize();
    if (!target.startsWith(storage)) throw new IllegalArgumentException("Invalid storage path");
    Files.createDirectories(target.getParent());
    Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
    return evidence.save(
        new Evidence(
            caseId,
            userId,
            type,
            original,
            file.getContentType() == null ? "application/octet-stream" : file.getContentType(),
            file.getSize(),
            key,
            notes));
  }

  private DiagnosticCase ownedCase(UUID id, UUID userId) {
    DiagnosticCase c =
        cases.findById(id).orElseThrow(() -> new NotFoundException("Diagnostic case not found"));
    access.requireMember(c.getOrganizationId(), userId);
    return c;
  }
}
