package ai.enqivra.core.api;

import java.time.Instant;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/health")
public class HealthController {
  private final JdbcTemplate jdbcTemplate;

  public HealthController(JdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  @GetMapping
  public ResponseEntity<Map<String, Object>> health() {
    Integer database = jdbcTemplate.queryForObject("select 1", Integer.class);
    return ResponseEntity.ok(
        Map.of(
            "service",
            "core-api",
            "status",
            "ok",
            "database",
            database == 1 ? "ok" : "error",
            "timestamp",
            Instant.now().toString()));
  }
}
