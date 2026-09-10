package ai.enqivra.core.api;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.enqivra.core.security.JwtService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc(addFilters = false)
class OntologyControllerTest {
  @Autowired private MockMvc mockMvc;
  @MockitoBean private JwtService jwtService;

  @Test
  void exposesSeededPacksAndSearchableNodes() throws Exception {
    mockMvc
        .perform(get("/api/v1/ontology/packs"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[?(@.domain == 'HVAC')].nodes").value(9));

    mockMvc
        .perform(
            get("/api/v1/ontology/nodes").param("domain", "HVAC").param("kind", "EQUIPMENT_TYPE"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].code").value("hvac.split-ac"));
  }

  @Test
  void returnsConnectedDiagnosticKnowledge() throws Exception {
    mockMvc
        .perform(get("/api/v1/ontology/nodes/hvac.filter-obstruction"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.node.safetyLevel").value("YELLOW"))
        .andExpect(
            jsonPath("$.outgoing[?(@.relationship == 'VERIFIED_BY')].node.code")
                .value("hvac.inspect-filter"))
        .andExpect(
            jsonPath("$.outgoing[?(@.relationship == 'RESOLVED_BY')].node.code")
                .value("hvac.clean-filter"));
  }
}
