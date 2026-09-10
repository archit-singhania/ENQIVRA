package ai.enqivra.core.repository;

import ai.enqivra.core.domain.Manufacturer;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ManufacturerRepository extends JpaRepository<Manufacturer, UUID> {
  List<Manufacturer> findByOrganizationIdOrderByName(UUID organizationId);
}
