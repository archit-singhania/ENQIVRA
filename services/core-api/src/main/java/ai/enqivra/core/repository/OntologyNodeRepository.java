package ai.enqivra.core.repository;

import ai.enqivra.core.domain.OntologyNode;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OntologyNodeRepository extends JpaRepository<OntologyNode, UUID> {
  Optional<OntologyNode> findByCodeAndActiveTrue(String code);

  List<OntologyNode> findByActiveTrueOrderByDomainAscKindAscNameAsc();
}
