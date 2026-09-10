package ai.enqivra.core.api;

import ai.enqivra.core.domain.Organization;
import ai.enqivra.core.domain.OrganizationMember;
import ai.enqivra.core.domain.Role;
import ai.enqivra.core.repository.OrganizationMemberRepository;
import ai.enqivra.core.repository.OrganizationRepository;
import ai.enqivra.core.repository.UserRepository;
import ai.enqivra.core.service.AccessService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class OrganizationController {
  private final UserRepository users;
  private final OrganizationRepository organizations;
  private final OrganizationMemberRepository members;
  private final AccessService access;

  public OrganizationController(
      UserRepository users,
      OrganizationRepository organizations,
      OrganizationMemberRepository members,
      AccessService access) {
    this.users = users;
    this.organizations = organizations;
    this.members = members;
    this.access = access;
  }

  record Me(UUID id, String email, String displayName) {}

  record OrganizationResponse(UUID id, String name, String slug, String role) {}

  record MemberResponse(UUID userId, String email, String displayName, Role role) {}

  record AddMemberRequest(@Email String email, @NotNull Role role) {}

  @GetMapping("/me")
  Me me(@AuthenticationPrincipal UUID userId) {
    var u = users.findById(userId).orElseThrow(() -> new NotFoundException("User not found"));
    return new Me(u.getId(), u.getEmail(), u.getDisplayName());
  }

  @GetMapping("/organizations")
  List<OrganizationResponse> organizations(@AuthenticationPrincipal UUID userId) {
    return members.findByUserId(userId).stream()
        .map(
            m -> {
              Organization o = organizations.findById(m.getOrganizationId()).orElseThrow();
              return new OrganizationResponse(
                  o.getId(), o.getName(), o.getSlug(), m.getRole().name());
            })
        .toList();
  }

  @GetMapping("/organizations/{organizationId}/members")
  List<MemberResponse> members(
      @PathVariable UUID organizationId, @AuthenticationPrincipal UUID userId) {
    access.requireMember(organizationId, userId);
    return members.findByOrganizationId(organizationId).stream()
        .map(
            member -> {
              var user = users.findById(member.getUserId()).orElseThrow();
              return new MemberResponse(
                  user.getId(), user.getEmail(), user.getDisplayName(), member.getRole());
            })
        .toList();
  }

  @PostMapping("/organizations/{organizationId}/members")
  @ResponseStatus(HttpStatus.CREATED)
  MemberResponse addMember(
      @PathVariable UUID organizationId,
      @AuthenticationPrincipal UUID userId,
      @Valid @RequestBody AddMemberRequest request) {
    access.requireAdministrator(organizationId, userId);
    var invited =
        users
            .findByEmailIgnoreCase(request.email())
            .orElseThrow(() -> new NotFoundException("Registered user not found"));
    if (members.findByOrganizationIdAndUserId(organizationId, invited.getId()).isPresent()) {
      throw new IllegalArgumentException("User is already a member");
    }
    members.save(new OrganizationMember(organizationId, invited.getId(), request.role()));
    return new MemberResponse(
        invited.getId(), invited.getEmail(), invited.getDisplayName(), request.role());
  }
}
