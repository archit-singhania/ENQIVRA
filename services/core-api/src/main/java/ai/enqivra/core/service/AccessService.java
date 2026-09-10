package ai.enqivra.core.service;

import ai.enqivra.core.api.ForbiddenException;
import ai.enqivra.core.domain.OrganizationMember;
import ai.enqivra.core.domain.Role;
import ai.enqivra.core.repository.OrganizationMemberRepository;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class AccessService {
  private final OrganizationMemberRepository members;

  public AccessService(OrganizationMemberRepository members) {
    this.members = members;
  }

  public OrganizationMember requireMember(UUID organizationId, UUID userId) {
    return members
        .findByOrganizationIdAndUserId(organizationId, userId)
        .orElseThrow(() -> new ForbiddenException("You do not belong to this organization"));
  }

  public OrganizationMember requireEditor(UUID organizationId, UUID userId) {
    OrganizationMember member = requireMember(organizationId, userId);
    if (member.getRole() == Role.VIEWER)
      throw new ForbiddenException("Viewer role cannot modify organization data");
    return member;
  }

  public OrganizationMember requireAdministrator(UUID organizationId, UUID userId) {
    OrganizationMember member = requireMember(organizationId, userId);
    if (member.getRole() != Role.OWNER && member.getRole() != Role.ADMIN) {
      throw new ForbiddenException("Owner or admin role is required");
    }
    return member;
  }
}
