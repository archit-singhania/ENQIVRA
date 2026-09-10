package ai.enqivra.core.repository;

import ai.enqivra.core.domain.OntologyEdge;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OntologyEdgeRepository extends JpaRepository<OntologyEdge, UUID> {
  List<OntologyEdge> findBySourceId(UUID sourceId);

  List<OntologyEdge> findByTargetId(UUID targetId);
}
