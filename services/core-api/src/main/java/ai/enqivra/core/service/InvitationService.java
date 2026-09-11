package ai.enqivra.core.service;

import ai.enqivra.core.api.NotFoundException;
import ai.enqivra.core.domain.OrganizationInvitation;
import ai.enqivra.core.domain.OrganizationMember;
import ai.enqivra.core.domain.Role;
import ai.enqivra.core.repository.OrganizationInvitationRepository;
import ai.enqivra.core.repository.OrganizationMemberRepository;
import ai.enqivra.core.repository.UserRepository;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Locale;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class InvitationService {
  public record Created(OrganizationInvitation invitation, String token) {}

  private final OrganizationInvitationRepository invitations;
  private final OrganizationMemberRepository members;
  private final UserRepository users;
  private final SecureRandom random = new SecureRandom();

  public InvitationService(
      OrganizationInvitationRepository invitations,
      OrganizationMemberRepository members,
      UserRepository users) {
    this.invitations = invitations;
    this.members = members;
    this.users = users;
  }

  @Transactional
  public Created create(UUID organizationId, UUID invitedBy, String email, Role role) {
    if (role == Role.OWNER) throw new IllegalArgumentException("Owner role cannot be invited");
    String normalized = email.trim().toLowerCase(Locale.ROOT);
    if (invitations.existsByOrganizationIdAndEmailIgnoreCaseAndStatus(
        organizationId, normalized, OrganizationInvitation.Status.PENDING)) {
      throw new IllegalArgumentException("A pending invitation already exists for this email");
    }
    users
        .findByEmailIgnoreCase(normalized)
        .ifPresent(
            user -> {
              if (members.findByOrganizationIdAndUserId(organizationId, user.getId()).isPresent())
                throw new IllegalArgumentException("User is already a member");
            });
    byte[] bytes = new byte[24];
    random.nextBytes(bytes);
    String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    OrganizationInvitation invitation =
        invitations.save(
            new OrganizationInvitation(
                organizationId,
                normalized,
                role,
                hash(token),
                invitedBy,
                Instant.now().plus(7, ChronoUnit.DAYS)));
    return new Created(invitation, token);
  }

  @Transactional
  public OrganizationMember accept(String token, UUID userId) {
    OrganizationInvitation invitation =
        invitations
            .findByTokenHash(hash(token))
            .orElseThrow(() -> new NotFoundException("Invitation not found"));
    if (invitation.getStatus() != OrganizationInvitation.Status.PENDING)
      throw new IllegalArgumentException("Invitation is no longer active");
    if (invitation.getExpiresAt().isBefore(Instant.now())) {
      invitation.expire();
      throw new IllegalArgumentException("Invitation has expired");
    }
    var user = users.findById(userId).orElseThrow(() -> new NotFoundException("User not found"));
    if (!user.getEmail().equalsIgnoreCase(invitation.getEmail()))
      throw new IllegalArgumentException("Invitation email does not match your account");
    if (members.findByOrganizationIdAndUserId(invitation.getOrganizationId(), userId).isPresent())
      throw new IllegalArgumentException("You already belong to this organization");
    OrganizationMember member =
        members.save(
            new OrganizationMember(invitation.getOrganizationId(), userId, invitation.getRole()));
    invitation.accept(userId);
    return member;
  }

  @Transactional
  public void revoke(UUID invitationId, UUID organizationId) {
    OrganizationInvitation invitation =
        invitations
            .findById(invitationId)
            .filter(i -> i.getOrganizationId().equals(organizationId))
            .orElseThrow(() -> new NotFoundException("Invitation not found"));
    if (invitation.getStatus() != OrganizationInvitation.Status.PENDING)
      throw new IllegalArgumentException("Only pending invitations can be revoked");
    invitation.revoke();
  }

  private String hash(String value) {
    try {
      return HexFormat.of()
          .formatHex(
              MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));
    } catch (Exception e) {
      throw new IllegalStateException(e);
    }
  }
}
