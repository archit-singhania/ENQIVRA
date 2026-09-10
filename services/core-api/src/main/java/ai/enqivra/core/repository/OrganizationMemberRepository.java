package ai.enqivra.core.repository;

import ai.enqivra.core.domain.OrganizationMember;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrganizationMemberRepository
    extends JpaRepository<OrganizationMember, OrganizationMember.Key> {
  List<OrganizationMember> findByUserId(UUID userId);

  List<OrganizationMember> findByOrganizationId(UUID organizationId);

  Optional<OrganizationMember> findByOrganizationIdAndUserId(UUID organizationId, UUID userId);
}
