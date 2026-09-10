package ai.enqivra.core.security;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class JwtService {
  private final byte[] secret;
  private final long accessTokenSeconds;
  private final ObjectMapper objectMapper;

  public JwtService(
      @Value("${enqivra.security.jwt-secret}") String secret,
      @Value("${enqivra.security.access-token-minutes}") long minutes,
      ObjectMapper objectMapper) {
    if (secret.length() < 32)
      throw new IllegalStateException("JWT secret must be at least 32 characters");
    this.secret = secret.getBytes(StandardCharsets.UTF_8);
    this.accessTokenSeconds = minutes * 60;
    this.objectMapper = objectMapper;
  }

  public String create(UUID userId, String email) {
    try {
      String header = encode(objectMapper.writeValueAsBytes(Map.of("alg", "HS256", "typ", "JWT")));
      Map<String, Object> claims = new LinkedHashMap<>();
      claims.put("sub", userId.toString());
      claims.put("email", email);
      claims.put("iat", Instant.now().getEpochSecond());
      claims.put("exp", Instant.now().plusSeconds(accessTokenSeconds).getEpochSecond());
      String payload = encode(objectMapper.writeValueAsBytes(claims));
      String unsigned = header + "." + payload;
      return unsigned + "." + encode(sign(unsigned));
    } catch (Exception exception) {
      throw new IllegalStateException("Could not create access token", exception);
    }
  }

  public UUID validateAndGetSubject(String token) {
    try {
      String[] parts = token.split("\\.");
      if (parts.length != 3) throw new IllegalArgumentException("Invalid token");
      String unsigned = parts[0] + "." + parts[1];
      if (!java.security.MessageDigest.isEqual(
          sign(unsigned), Base64.getUrlDecoder().decode(parts[2])))
        throw new IllegalArgumentException("Invalid token signature");
      Map<String, Object> claims =
          objectMapper.readValue(Base64.getUrlDecoder().decode(parts[1]), new TypeReference<>() {});
      if (((Number) claims.get("exp")).longValue() <= Instant.now().getEpochSecond())
        throw new IllegalArgumentException("Token expired");
      return UUID.fromString((String) claims.get("sub"));
    } catch (IllegalArgumentException exception) {
      throw exception;
    } catch (Exception exception) {
      throw new IllegalArgumentException("Invalid token", exception);
    }
  }

  public long expiresInSeconds() {
    return accessTokenSeconds;
  }

  private String encode(byte[] bytes) {
    return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
  }

  private byte[] sign(String content) throws Exception {
    Mac mac = Mac.getInstance("HmacSHA256");
    mac.init(new SecretKeySpec(secret, "HmacSHA256"));
    return mac.doFinal(content.getBytes(StandardCharsets.UTF_8));
  }
}
