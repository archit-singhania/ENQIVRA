package ai.enqivra.core.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "users")
public class User {
  @Id private UUID id;

  @Column(nullable = false, unique = true)
  private String email;

  @Column(name = "password_hash", nullable = false)
  private String passwordHash;

  @Column(name = "display_name", nullable = false)
  private String displayName;

  @Column(nullable = false)
  private boolean enabled;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  protected User() {}

  public User(String email, String passwordHash, String displayName) {
    this.id = UUID.randomUUID();
    this.email = email.toLowerCase();
    this.passwordHash = passwordHash;
    this.displayName = displayName;
    this.enabled = true;
    this.createdAt = Instant.now();
  }

  public UUID getId() {
    return id;
  }

  public String getEmail() {
    return email;
  }

  public String getPasswordHash() {
    return passwordHash;
  }

  public String getDisplayName() {
    return displayName;
  }

  public boolean isEnabled() {
    return enabled;
  }
}
