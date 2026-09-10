package ai.enqivra.core.repository;

import ai.enqivra.core.domain.DiagnosticCase;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DiagnosticCaseRepository extends JpaRepository<DiagnosticCase, UUID> {
  List<DiagnosticCase> findByOrganizationIdOrderByCreatedAtDesc(UUID organizationId);
}
