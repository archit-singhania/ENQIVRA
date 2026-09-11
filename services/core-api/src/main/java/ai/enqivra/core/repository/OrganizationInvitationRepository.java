package ai.enqivra.core.repository;

import ai.enqivra.core.domain.OrganizationInvitation;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrganizationInvitationRepository
    extends JpaRepository<OrganizationInvitation, UUID> {
  List<OrganizationInvitation> findByOrganizationIdOrderByCreatedAtDesc(UUID organizationId);

  Optional<OrganizationInvitation> findByTokenHash(String tokenHash);

  boolean existsByOrganizationIdAndEmailIgnoreCaseAndStatus(
      UUID organizationId, String email, OrganizationInvitation.Status status);
}
