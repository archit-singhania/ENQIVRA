package ai.enqivra.core.service;

import ai.enqivra.core.domain.Organization;
import ai.enqivra.core.domain.OrganizationMember;
import ai.enqivra.core.domain.RefreshToken;
import ai.enqivra.core.domain.Role;
import ai.enqivra.core.domain.User;
import ai.enqivra.core.repository.OrganizationMemberRepository;
import ai.enqivra.core.repository.OrganizationRepository;
import ai.enqivra.core.repository.RefreshTokenRepository;
import ai.enqivra.core.repository.UserRepository;
import ai.enqivra.core.security.JwtService;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Locale;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {
  public record Tokens(
      String accessToken,
      String refreshToken,
      long expiresIn,
      UserView user,
      OrganizationView organization) {}

  public record UserView(UUID id, String email, String displayName) {
    static UserView from(User u) {
      return new UserView(u.getId(), u.getEmail(), u.getDisplayName());
    }
  }

  public record OrganizationView(UUID id, String name, String slug, Role role) {}

  private final UserRepository users;
  private final OrganizationRepository organizations;
  private final OrganizationMemberRepository members;
  private final RefreshTokenRepository refreshTokens;
  private final PasswordEncoder passwords;
  private final JwtService jwt;
  private final long refreshDays;
  private final SecureRandom random = new SecureRandom();

  public AuthService(
      UserRepository users,
      OrganizationRepository organizations,
      OrganizationMemberRepository members,
      RefreshTokenRepository refreshTokens,
      PasswordEncoder passwords,
      JwtService jwt,
      @Value("${enqivra.security.refresh-token-days}") long refreshDays) {
    this.users = users;
    this.organizations = organizations;
    this.members = members;
    this.refreshTokens = refreshTokens;
    this.passwords = passwords;
    this.jwt = jwt;
    this.refreshDays = refreshDays;
  }

  @Transactional
  public Tokens register(
      String email, String password, String displayName, String organizationName) {
    if (users.findByEmailIgnoreCase(email).isPresent())
      throw new IllegalArgumentException("Email is already registered");
    User user = users.save(new User(email.trim(), passwords.encode(password), displayName.trim()));
    String base =
        organizationName
            .toLowerCase(Locale.ROOT)
            .replaceAll("[^a-z0-9]+", "-")
            .replaceAll("(^-|-$)", "");
    String slug = base.isBlank() ? "organization" : base;
    if (organizations.existsBySlug(slug)) slug += "-" + user.getId().toString().substring(0, 8);
    Organization org = organizations.save(new Organization(organizationName.trim(), slug));
    members.save(new OrganizationMember(org.getId(), user.getId(), Role.OWNER));
    return issue(user, org, Role.OWNER);
  }

  @Transactional
  public Tokens login(String email, String password) {
    User user =
        users
            .findByEmailIgnoreCase(email)
            .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));
    if (!user.isEnabled() || !passwords.matches(password, user.getPasswordHash()))
      throw new IllegalArgumentException("Invalid email or password");
    OrganizationMember member =
        members.findByUserId(user.getId()).stream()
            .findFirst()
            .orElseThrow(() -> new IllegalArgumentException("User has no organization"));
    Organization org = organizations.findById(member.getOrganizationId()).orElseThrow();
    return issue(user, org, member.getRole());
  }

  @Transactional
  public Tokens refresh(String rawToken) {
    RefreshToken stored =
        refreshTokens
            .findByTokenHash(hash(rawToken))
            .orElseThrow(() -> new IllegalArgumentException("Invalid refresh token"));
    if (stored.getRevokedAt() != null || stored.getExpiresAt().isBefore(Instant.now()))
      throw new IllegalArgumentException("Refresh token expired or revoked");
    stored.revoke();
    User user = users.findById(stored.getUserId()).orElseThrow();
    OrganizationMember member =
        members.findByUserId(user.getId()).stream().findFirst().orElseThrow();
    Organization org = organizations.findById(member.getOrganizationId()).orElseThrow();
    return issue(user, org, member.getRole());
  }

  private Tokens issue(User user, Organization org, Role role) {
    byte[] bytes = new byte[48];
    random.nextBytes(bytes);
    String raw = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    refreshTokens.save(
        new RefreshToken(
            user.getId(), hash(raw), Instant.now().plus(refreshDays, ChronoUnit.DAYS)));
    return new Tokens(
        jwt.create(user.getId(), user.getEmail()),
        raw,
        jwt.expiresInSeconds(),
        UserView.from(user),
        new OrganizationView(org.getId(), org.getName(), org.getSlug(), role));
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
