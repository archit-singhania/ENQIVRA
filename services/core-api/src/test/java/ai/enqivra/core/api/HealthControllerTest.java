package ai.enqivra.core.api;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.enqivra.core.security.JwtService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(HealthController.class)
@AutoConfigureMockMvc(addFilters = false)
class HealthControllerTest {
  @Autowired private MockMvc mockMvc;
  @MockitoBean private JdbcTemplate jdbcTemplate;
  @MockitoBean private JwtService jwtService;

  @Test
  void reportsServiceAndDatabaseHealth() throws Exception {
    when(jdbcTemplate.queryForObject("select 1", Integer.class)).thenReturn(1);
    mockMvc
        .perform(get("/api/v1/health"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.service").value("core-api"))
        .andExpect(jsonPath("$.database").value("ok"));
  }
}
