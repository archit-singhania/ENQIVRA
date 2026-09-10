package ai.enqivra.core.api;

import ai.enqivra.core.domain.OntologyEdge;
import ai.enqivra.core.domain.OntologyNode;
import ai.enqivra.core.repository.OntologyEdgeRepository;
import ai.enqivra.core.repository.OntologyNodeRepository;
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/ontology")
public class OntologyController {
  private final OntologyNodeRepository nodes;
  private final OntologyEdgeRepository edges;

  public OntologyController(OntologyNodeRepository nodes, OntologyEdgeRepository edges) {
    this.nodes = nodes;
    this.edges = edges;
  }

  public record PackResponse(String domain, long nodes, long relationships) {}

  public record RelationResponse(String relationship, BigDecimal weight, OntologyNode node) {}

  public record NodeDetailResponse(
      OntologyNode node, List<RelationResponse> outgoing, List<RelationResponse> incoming) {}

  @GetMapping("/packs")
  List<PackResponse> packs() {
    List<OntologyNode> allNodes = nodes.findByActiveTrueOrderByDomainAscKindAscNameAsc();
    Map<UUID, String> domains =
        allNodes.stream().collect(Collectors.toMap(OntologyNode::getId, OntologyNode::getDomain));
    return allNodes.stream()
        .map(OntologyNode::getDomain)
        .distinct()
        .sorted()
        .map(
            domain -> {
              long nodeCount = allNodes.stream().filter(n -> n.getDomain().equals(domain)).count();
              long edgeCount =
                  edges.findAll().stream()
                      .filter(e -> domain.equals(domains.get(e.getSourceId())))
                      .count();
              return new PackResponse(domain, nodeCount, edgeCount);
            })
        .toList();
  }

  @GetMapping("/nodes")
  List<OntologyNode> search(
      @RequestParam(required = false) String domain,
      @RequestParam(required = false) String kind,
      @RequestParam(required = false) String q) {
    String query = q == null ? "" : q.trim().toLowerCase(Locale.ROOT);
    return nodes.findByActiveTrueOrderByDomainAscKindAscNameAsc().stream()
        .filter(n -> domain == null || n.getDomain().equalsIgnoreCase(domain))
        .filter(n -> kind == null || n.getKind().equalsIgnoreCase(kind))
        .filter(
            n ->
                query.isEmpty()
                    || n.getName().toLowerCase(Locale.ROOT).contains(query)
                    || n.getDescription().toLowerCase(Locale.ROOT).contains(query)
                    || n.getCode().toLowerCase(Locale.ROOT).contains(query))
        .toList();
  }

  @GetMapping("/nodes/{code}")
  NodeDetailResponse detail(@PathVariable String code) {
    OntologyNode node =
        nodes
            .findByCodeAndActiveTrue(code)
            .orElseThrow(() -> new NotFoundException("Ontology node not found"));
    Map<UUID, OntologyNode> byId =
        nodes
            .findAllById(
                java.util.stream.Stream.concat(
                        edges.findBySourceId(node.getId()).stream().map(OntologyEdge::getTargetId),
                        edges.findByTargetId(node.getId()).stream().map(OntologyEdge::getSourceId))
                    .toList())
            .stream()
            .collect(Collectors.toMap(OntologyNode::getId, Function.identity()));
    List<RelationResponse> outgoing =
        edges.findBySourceId(node.getId()).stream()
            .map(
                e ->
                    new RelationResponse(
                        e.getRelationship(), e.getWeight(), byId.get(e.getTargetId())))
            .sorted(Comparator.comparing(r -> r.node().getName()))
            .toList();
    List<RelationResponse> incoming =
        edges.findByTargetId(node.getId()).stream()
            .map(
                e ->
                    new RelationResponse(
                        e.getRelationship(), e.getWeight(), byId.get(e.getSourceId())))
            .sorted(Comparator.comparing(r -> r.node().getName()))
            .toList();
    return new NodeDetailResponse(node, outgoing, incoming);
  }
}
