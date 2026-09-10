package ai.enqivra.core.repository;

import ai.enqivra.core.domain.AssetComponent;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AssetComponentRepository extends JpaRepository<AssetComponent, UUID> {
  List<AssetComponent> findByAssetIdOrderByName(UUID assetId);
}
