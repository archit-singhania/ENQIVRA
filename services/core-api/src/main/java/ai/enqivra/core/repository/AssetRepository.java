package ai.enqivra.core.repository;

import ai.enqivra.core.domain.Asset;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AssetRepository extends JpaRepository<Asset, UUID> {
  List<Asset> findByOrganizationIdOrderByName(UUID organizationId);
}
