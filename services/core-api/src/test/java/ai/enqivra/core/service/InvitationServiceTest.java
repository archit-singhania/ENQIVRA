package ai.enqivra.core.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ai.enqivra.core.domain.Organization;
import ai.enqivra.core.domain.OrganizationMember;
import ai.enqivra.core.domain.Role;
import ai.enqivra.core.domain.User;
import ai.enqivra.core.repository.OrganizationMemberRepository;
import ai.enqivra.core.repository.OrganizationRepository;
import ai.enqivra.core.repository.UserRepository;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class InvitationServiceTest {
  private final String suffix = UUID.randomUUID().toString();
  @Autowired private InvitationService invitations;
  @Autowired private UserRepository users;
  @Autowired private OrganizationRepository organizations;
  @Autowired private OrganizationMemberRepository members;

  @Test
  void invitedAccountCanJoinAnAdditionalOrganization() {
    User owner = users.save(new User("owner-test@enqivra.local", "hash", "Owner"));
    User technician = users.save(new User("tech-test@enqivra.local", "hash", "Technician"));
    Organization organization =
        organizations.save(new Organization("Test Workshop", "test-workshop-" + suffix));
    members.save(new OrganizationMember(organization.getId(), owner.getId(), Role.OWNER));

    var created =
        invitations.create(
            organization.getId(), owner.getId(), technician.getEmail(), Role.TECHNICIAN);
    OrganizationMember accepted = invitations.accept(created.token(), technician.getId());

    assertThat(accepted.getOrganizationId()).isEqualTo(organization.getId());
    assertThat(accepted.getRole()).isEqualTo(Role.TECHNICIAN);
    assertThat(members.findByUserId(technician.getId())).hasSize(1);
  }

  @Test
  void invitationCannotBeAcceptedByDifferentEmail() {
    User owner = users.save(new User("owner-two@enqivra.local", "hash", "Owner"));
    User intended = users.save(new User("intended@enqivra.local", "hash", "Intended"));
    User other = users.save(new User("other@enqivra.local", "hash", "Other"));
    Organization organization =
        organizations.save(new Organization("Second Workshop", "second-workshop-" + suffix));
    members.save(new OrganizationMember(organization.getId(), owner.getId(), Role.OWNER));

    var created =
        invitations.create(organization.getId(), owner.getId(), intended.getEmail(), Role.VIEWER);

    assertThatThrownBy(() -> invitations.accept(created.token(), other.getId()))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessage("Invitation email does not match your account");
  }

  @Test
  void ownerRoleCannotBeGrantedThroughInvitation() {
    User owner = users.save(new User("owner-three@enqivra.local", "hash", "Owner"));
    Organization organization =
        organizations.save(new Organization("Third Workshop", "third-workshop-" + suffix));

    assertThatThrownBy(
            () ->
                invitations.create(
                    organization.getId(), owner.getId(), "new-owner@enqivra.local", Role.OWNER))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessage("Owner role cannot be invited");
  }
}
