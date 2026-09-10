package ai.enqivra.core;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.enqivra.core.repository.AssetRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc
class CoreApiApplicationTest {
  @Autowired private AssetRepository assets;
  @Autowired private MockMvc mockMvc;
  @Autowired private ObjectMapper objectMapper;

  @Test
  void startsWithValidatedPhaseOneSchema() {
    assertThat(assets).isNotNull();
  }

  @Test
  void completesThePhaseOneUserJourney() throws Exception {
    String response =
        mockMvc
            .perform(
                post("/api/v1/auth/register")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(
                        """
        {"email":"owner@enqivra.test","password":"strong-password","displayName":"Test Owner","organizationName":"Test Workshop"}
        """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.organization.role").value("OWNER"))
            .andReturn()
            .getResponse()
            .getContentAsString();
    String accessToken = objectMapper.readTree(response).get("accessToken").asText();
    String organizationId = objectMapper.readTree(response).get("organization").get("id").asText();
    mockMvc
        .perform(get("/api/v1/organizations").header("Authorization", "Bearer " + accessToken))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].slug").value("test-workshop"));

    String assetResponse =
        mockMvc
            .perform(
                post("/api/v1/assets")
                    .queryParam("organizationId", organizationId)
                    .header("Authorization", "Bearer " + accessToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(
                        """
        {"name":"Workshop AC","category":"HVAC","model":"Demo-1","serialNumber":"ENQ-001"}
        """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("Workshop AC"))
            .andReturn()
            .getResponse()
            .getContentAsString();
    String assetId = objectMapper.readTree(assetResponse).get("id").asText();

    String caseResponse =
        mockMvc
            .perform(
                post("/api/v1/cases")
                    .queryParam("organizationId", organizationId)
                    .header("Authorization", "Bearer " + accessToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(
                        """
        {"assetId":"%s","title":"Insufficient cooling","complaint":"The AC runs but the room remains warm."}
        """
                            .formatted(assetId)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.status").value("OPEN"))
            .andReturn()
            .getResponse()
            .getContentAsString();
    String caseId = objectMapper.readTree(caseResponse).get("id").asText();

    MockMultipartFile file =
        new MockMultipartFile("file", "filter.txt", "text/plain", "synthetic evidence".getBytes());
    mockMvc
        .perform(
            multipart("/api/v1/cases/{caseId}/evidence", caseId)
                .file(file)
                .param("evidenceType", "DOCUMENT")
                .header("Authorization", "Bearer " + accessToken))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.originalFilename").value("filter.txt"));
  }
}
