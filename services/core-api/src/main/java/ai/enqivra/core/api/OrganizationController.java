package ai.enqivra.core.api;

import ai.enqivra.core.domain.Organization;
import ai.enqivra.core.domain.OrganizationInvitation;
import ai.enqivra.core.domain.OrganizationMember;
import ai.enqivra.core.domain.Role;
import ai.enqivra.core.repository.OrganizationInvitationRepository;
import ai.enqivra.core.repository.OrganizationMemberRepository;
import ai.enqivra.core.repository.OrganizationRepository;
import ai.enqivra.core.repository.UserRepository;
import ai.enqivra.core.service.AccessService;
import ai.enqivra.core.service.InvitationService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
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
  private final OrganizationInvitationRepository invitations;
  private final InvitationService invitationService;

  public OrganizationController(
      UserRepository users,
      OrganizationRepository organizations,
      OrganizationMemberRepository members,
      AccessService access,
      OrganizationInvitationRepository invitations,
      InvitationService invitationService) {
    this.users = users;
    this.organizations = organizations;
    this.members = members;
    this.access = access;
    this.invitations = invitations;
    this.invitationService = invitationService;
  }

  record Me(UUID id, String email, String displayName) {}

  record OrganizationResponse(UUID id, String name, String slug, String role) {}

  record MemberResponse(UUID userId, String email, String displayName, Role role) {}

  record AddMemberRequest(@Email String email, @NotNull Role role) {}

  record RoleRequest(@NotNull Role role) {}

  record InvitationRequest(@Email String email, @NotNull Role role) {}

  record InvitationResponse(
      UUID id, String email, Role role, String status, java.time.Instant expiresAt, String token) {}

  record AcceptInvitationRequest(@jakarta.validation.constraints.NotBlank String token) {}

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
    if (request.role() == Role.OWNER
        && access.requireMember(organizationId, userId).getRole() != Role.OWNER) {
      throw new ForbiddenException("Only an owner can grant owner role");
    }
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

  @PatchMapping("/organizations/{organizationId}/members/{memberId}")
  MemberResponse changeRole(
      @PathVariable UUID organizationId,
      @PathVariable UUID memberId,
      @AuthenticationPrincipal UUID userId,
      @Valid @RequestBody RoleRequest request) {
    access.requireAdministrator(organizationId, userId);
    if (request.role() == Role.OWNER
        && access.requireMember(organizationId, userId).getRole() != Role.OWNER) {
      throw new ForbiddenException("Only an owner can grant owner role");
    }
    OrganizationMember member =
        members
            .findByOrganizationIdAndUserId(organizationId, memberId)
            .orElseThrow(() -> new NotFoundException("Member not found"));
    if (member.getRole() == Role.OWNER
        && request.role() != Role.OWNER
        && members.countByOrganizationIdAndRole(organizationId, Role.OWNER) <= 1) {
      throw new IllegalArgumentException("Organization must retain at least one owner");
    }
    member.changeRole(request.role());
    members.save(member);
    var user = users.findById(memberId).orElseThrow();
    return new MemberResponse(
        user.getId(), user.getEmail(), user.getDisplayName(), member.getRole());
  }

  @DeleteMapping("/organizations/{organizationId}/members/{memberId}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  void removeMember(
      @PathVariable UUID organizationId,
      @PathVariable UUID memberId,
      @AuthenticationPrincipal UUID userId) {
    access.requireAdministrator(organizationId, userId);
    OrganizationMember member =
        members
            .findByOrganizationIdAndUserId(organizationId, memberId)
            .orElseThrow(() -> new NotFoundException("Member not found"));
    if (memberId.equals(userId)) throw new IllegalArgumentException("You cannot remove yourself");
    if (member.getRole() == Role.OWNER
        && members.countByOrganizationIdAndRole(organizationId, Role.OWNER) <= 1) {
      throw new IllegalArgumentException("Organization must retain at least one owner");
    }
    members.delete(member);
  }

  @GetMapping("/organizations/{organizationId}/invitations")
  List<InvitationResponse> invitations(
      @PathVariable UUID organizationId, @AuthenticationPrincipal UUID userId) {
    access.requireAdministrator(organizationId, userId);
    return invitations.findByOrganizationIdOrderByCreatedAtDesc(organizationId).stream()
        .map(i -> invitationResponse(i, null))
        .toList();
  }

  @PostMapping("/organizations/{organizationId}/invitations")
  @ResponseStatus(HttpStatus.CREATED)
  InvitationResponse invite(
      @PathVariable UUID organizationId,
      @AuthenticationPrincipal UUID userId,
      @Valid @RequestBody InvitationRequest request) {
    access.requireAdministrator(organizationId, userId);
    var created = invitationService.create(organizationId, userId, request.email(), request.role());
    return invitationResponse(created.invitation(), created.token());
  }

  @DeleteMapping("/organizations/{organizationId}/invitations/{invitationId}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  void revokeInvitation(
      @PathVariable UUID organizationId,
      @PathVariable UUID invitationId,
      @AuthenticationPrincipal UUID userId) {
    access.requireAdministrator(organizationId, userId);
    invitationService.revoke(invitationId, organizationId);
  }

  @PostMapping("/invitations/accept")
  MemberResponse acceptInvitation(
      @AuthenticationPrincipal UUID userId, @Valid @RequestBody AcceptInvitationRequest request) {
    OrganizationMember member = invitationService.accept(request.token(), userId);
    var user = users.findById(userId).orElseThrow();
    return new MemberResponse(
        user.getId(), user.getEmail(), user.getDisplayName(), member.getRole());
  }

  private InvitationResponse invitationResponse(OrganizationInvitation invitation, String token) {
    return new InvitationResponse(
        invitation.getId(),
        invitation.getEmail(),
        invitation.getRole(),
        invitation.getStatus().name(),
        invitation.getExpiresAt(),
        token);
  }
}
