package ai.enqivra.core.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class JwtServiceTest {
  private final JwtService service =
      new JwtService("a-development-secret-that-is-long-enough", 15, new ObjectMapper());

  @Test
  void roundTripsSignedSubject() {
    UUID subject = UUID.randomUUID();
    assertThat(service.validateAndGetSubject(service.create(subject, "dev@enqivra.ai")))
        .isEqualTo(subject);
  }

  @Test
  void rejectsTamperedToken() {
    String token = service.create(UUID.randomUUID(), "dev@enqivra.ai");
    assertThatThrownBy(() -> service.validateAndGetSubject(token + "x"))
        .isInstanceOf(IllegalArgumentException.class);
  }
}
