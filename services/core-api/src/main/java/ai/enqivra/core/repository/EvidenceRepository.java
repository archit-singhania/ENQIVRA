package ai.enqivra.core.repository;

import ai.enqivra.core.domain.Evidence;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EvidenceRepository extends JpaRepository<Evidence, UUID> {
  List<Evidence> findByCaseIdOrderByCreatedAt(UUID caseId);
}
