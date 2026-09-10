package ai.enqivra.core.api;

import ai.enqivra.core.service.AuthService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
  private final AuthService auth;

  public AuthController(AuthService auth) {
    this.auth = auth;
  }

  public record RegisterRequest(
      @Email @NotBlank String email,
      @Size(min = 10, max = 128) String password,
      @NotBlank @Size(max = 120) String displayName,
      @NotBlank @Size(max = 160) String organizationName) {}

  public record LoginRequest(@Email @NotBlank String email, @NotBlank String password) {}

  public record RefreshRequest(@NotBlank String refreshToken) {}

  @PostMapping("/register")
  @ResponseStatus(HttpStatus.CREATED)
  AuthService.Tokens register(@Valid @RequestBody RegisterRequest r) {
    return auth.register(r.email(), r.password(), r.displayName(), r.organizationName());
  }

  @PostMapping("/login")
  AuthService.Tokens login(@Valid @RequestBody LoginRequest r) {
    return auth.login(r.email(), r.password());
  }

  @PostMapping("/refresh")
  AuthService.Tokens refresh(@Valid @RequestBody RefreshRequest r) {
    return auth.refresh(r.refreshToken());
  }
}
