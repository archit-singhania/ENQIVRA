CREATE TABLE ontology_nodes (
    id UUID PRIMARY KEY,
    code VARCHAR(120) NOT NULL UNIQUE,
    kind VARCHAR(40) NOT NULL CHECK (kind IN ('EQUIPMENT_TYPE', 'SYSTEM', 'SUBSYSTEM', 'ASSEMBLY', 'COMPONENT_TYPE', 'FUNCTION', 'FAILURE_MODE', 'SYMPTOM', 'DIAGNOSTIC_TEST', 'RESOLUTION', 'SAFETY_RULE')),
    domain VARCHAR(40) NOT NULL CHECK (domain IN ('COMMON', 'HVAC', 'AUTOMOTIVE', 'APPLIANCES')),
    name VARCHAR(160) NOT NULL,
    description TEXT NOT NULL,
    safety_level VARCHAR(20) NOT NULL DEFAULT 'GREEN' CHECK (safety_level IN ('GREEN', 'YELLOW', 'ORANGE', 'RED')),
    parent_id UUID REFERENCES ontology_nodes(id) ON DELETE SET NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX idx_ontology_nodes_domain_kind ON ontology_nodes(domain, kind);
CREATE INDEX idx_ontology_nodes_parent ON ontology_nodes(parent_id);

CREATE TABLE ontology_edges (
    id UUID PRIMARY KEY,
    source_id UUID NOT NULL REFERENCES ontology_nodes(id) ON DELETE CASCADE,
    target_id UUID NOT NULL REFERENCES ontology_nodes(id) ON DELETE CASCADE,
    relationship VARCHAR(40) NOT NULL CHECK (relationship IN ('HAS_PART', 'PERFORMS', 'HAS_FAILURE_MODE', 'PRESENTS_AS', 'VERIFIED_BY', 'RESOLVED_BY', 'GOVERNED_BY')),
    weight DECIMAL(5,4),
    UNIQUE (source_id, target_id, relationship)
);
CREATE INDEX idx_ontology_edges_source ON ontology_edges(source_id);
CREATE INDEX idx_ontology_edges_target ON ontology_edges(target_id);

ALTER TABLE assets ADD COLUMN ontology_type_id UUID REFERENCES ontology_nodes(id) ON DELETE SET NULL;
ALTER TABLE asset_components ADD COLUMN ontology_type_id UUID REFERENCES ontology_nodes(id) ON DELETE SET NULL;

INSERT INTO ontology_nodes (id, code, kind, domain, name, description, safety_level, parent_id) VALUES
('00000000-0000-0000-0000-000000000001','common.electric-motor','COMPONENT_TYPE','COMMON','Electric motor','Converts electrical energy into rotational mechanical energy.','YELLOW',NULL),
('00000000-0000-0000-0000-000000000002','common.compressor','COMPONENT_TYPE','COMMON','Compressor','Raises the pressure of a working fluid.','ORANGE',NULL),
('00000000-0000-0000-0000-000000000003','common.reduced-output','SYMPTOM','COMMON','Reduced output','The system operates but delivers less than its expected output.','GREEN',NULL),
('00000000-0000-0000-0000-000000000004','common.abnormal-noise','SYMPTOM','COMMON','Abnormal noise','Unexpected humming, rattling, grinding, or knocking.','YELLOW',NULL),
('00000000-0000-0000-0000-000000000005','common.overheating','FAILURE_MODE','COMMON','Overheating','Operating temperature exceeds the normal safe range.','ORANGE',NULL),
('00000000-0000-0000-0000-000000000006','common.visual-inspection','DIAGNOSTIC_TEST','COMMON','Power-off visual inspection','Disconnect power and inspect for obstruction, damage, looseness, or contamination.','YELLOW',NULL),
('00000000-0000-0000-0000-000000000007','common.professional-electrical','SAFETY_RULE','COMMON','Professional electrical isolation','Live panels, exposed conductors, and high-voltage components require a qualified professional.','RED',NULL),
('00000000-0000-0000-0000-000000000008','common.clean-airflow','RESOLUTION','COMMON','Restore airflow','Safely remove accessible dust or obstruction according to manufacturer guidance.','YELLOW',NULL),

('10000000-0000-0000-0000-000000000001','hvac.split-ac','EQUIPMENT_TYPE','HVAC','Split air conditioner','Indoor and outdoor units connected by a refrigeration circuit.','YELLOW',NULL),
('10000000-0000-0000-0000-000000000002','hvac.refrigeration-system','SYSTEM','HVAC','Refrigeration system','Moves heat using refrigerant evaporation and condensation.','ORANGE','10000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000003','hvac.airflow-system','SYSTEM','HVAC','Airflow system','Moves conditioned air across heat exchangers and into the room.','YELLOW','10000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000004','hvac.air-filter','COMPONENT_TYPE','HVAC','Air filter','Captures airborne particles before air reaches the evaporator.','GREEN','10000000-0000-0000-0000-000000000003'),
('10000000-0000-0000-0000-000000000005','hvac.filter-obstruction','FAILURE_MODE','HVAC','Filter obstruction','Accumulated debris restricts airflow through the indoor unit.','YELLOW','10000000-0000-0000-0000-000000000004'),
('10000000-0000-0000-0000-000000000006','hvac.insufficient-cooling','SYMPTOM','HVAC','Insufficient cooling','Supply air or room cooling is below expectation.','GREEN','10000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000007','hvac.inspect-filter','DIAGNOSTIC_TEST','HVAC','Inspect indoor filter','Power off the unit, remove the user-serviceable filter, and check for visible blockage.','YELLOW','10000000-0000-0000-0000-000000000004'),
('10000000-0000-0000-0000-000000000008','hvac.clean-filter','RESOLUTION','HVAC','Clean or replace filter','Clean or replace the filter exactly as specified by the manufacturer.','YELLOW','10000000-0000-0000-0000-000000000004'),
('10000000-0000-0000-0000-000000000009','hvac.refrigerant-safety','SAFETY_RULE','HVAC','Sealed refrigerant circuit','Do not open refrigerant lines; leak and pressure work requires a certified HVAC technician.','RED','10000000-0000-0000-0000-000000000002'),

('20000000-0000-0000-0000-000000000001','automotive.passenger-car','EQUIPMENT_TYPE','AUTOMOTIVE','Passenger car','Road vehicle represented as interoperable mechanical, electrical, and control systems.','YELLOW',NULL),
('20000000-0000-0000-0000-000000000002','automotive.engine-management','SYSTEM','AUTOMOTIVE','Engine management','Coordinates combustion using sensors, actuators, fuel, ignition, and software.','ORANGE','20000000-0000-0000-0000-000000000001'),
('20000000-0000-0000-0000-000000000003','automotive.ignition-system','SUBSYSTEM','AUTOMOTIVE','Ignition system','Produces correctly timed ignition for combustion.','ORANGE','20000000-0000-0000-0000-000000000002'),
('20000000-0000-0000-0000-000000000004','automotive.spark-plug','COMPONENT_TYPE','AUTOMOTIVE','Spark plug','Creates the ignition spark inside a petrol engine cylinder.','ORANGE','20000000-0000-0000-0000-000000000003'),
('20000000-0000-0000-0000-000000000005','automotive.misfire','FAILURE_MODE','AUTOMOTIVE','Combustion misfire','One or more cylinders fail to combust normally.','ORANGE','20000000-0000-0000-0000-000000000002'),
('20000000-0000-0000-0000-000000000006','automotive.jerking','SYMPTOM','AUTOMOTIVE','Jerking during acceleration','Intermittent loss of smooth power while accelerating.','ORANGE','20000000-0000-0000-0000-000000000001'),
('20000000-0000-0000-0000-000000000007','automotive.read-obd','DIAGNOSTIC_TEST','AUTOMOTIVE','Read stored OBD-II codes','With the vehicle safely parked, read diagnostic trouble codes using a compatible scanner.','YELLOW','20000000-0000-0000-0000-000000000002'),
('20000000-0000-0000-0000-000000000008','automotive.roadside-safety','SAFETY_RULE','AUTOMOTIVE','Stop unsafe driving','Stop driving and seek professional help for severe power loss, smoke, fuel smell, braking, or steering faults.','RED','20000000-0000-0000-0000-000000000001'),

('30000000-0000-0000-0000-000000000001','appliances.refrigerator','EQUIPMENT_TYPE','APPLIANCES','Refrigerator','Insulated appliance that uses a refrigeration cycle to preserve food.','YELLOW',NULL),
('30000000-0000-0000-0000-000000000002','appliances.cooling-system','SYSTEM','APPLIANCES','Cooling system','Refrigeration and airflow components responsible for removing cabinet heat.','ORANGE','30000000-0000-0000-0000-000000000001'),
('30000000-0000-0000-0000-000000000003','appliances.door-gasket','COMPONENT_TYPE','APPLIANCES','Door gasket','Flexible seal limiting warm air infiltration around the door.','GREEN','30000000-0000-0000-0000-000000000001'),
('30000000-0000-0000-0000-000000000004','appliances.warm-cabinet','SYMPTOM','APPLIANCES','Cabinet not cold enough','Stored-food compartment remains warmer than its configured temperature.','YELLOW','30000000-0000-0000-0000-000000000001'),
('30000000-0000-0000-0000-000000000005','appliances.gasket-leak','FAILURE_MODE','APPLIANCES','Door seal leakage','A damaged, dirty, or misaligned gasket admits warm moist air.','GREEN','30000000-0000-0000-0000-000000000003'),
('30000000-0000-0000-0000-000000000006','appliances.paper-seal-test','DIAGNOSTIC_TEST','APPLIANCES','Paper door-seal test','Close the door on paper at several points and check for consistent resistance.','GREEN','30000000-0000-0000-0000-000000000003'),
('30000000-0000-0000-0000-000000000007','appliances.clean-gasket','RESOLUTION','APPLIANCES','Clean and reseat gasket','Clean the gasket and contact surface, then verify that the door closes evenly.','GREEN','30000000-0000-0000-0000-000000000003');

INSERT INTO ontology_edges (id, source_id, target_id, relationship, weight) VALUES
('90000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000005','HAS_FAILURE_MODE',NULL),
('90000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000004','PRESENTS_AS',0.7000),
('90000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002','HAS_PART',NULL),
('90000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000003','HAS_PART',NULL),
('90000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000005','HAS_FAILURE_MODE',NULL),
('90000000-0000-0000-0000-000000000006','10000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000006','PRESENTS_AS',0.8500),
('90000000-0000-0000-0000-000000000007','10000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000007','VERIFIED_BY',NULL),
('90000000-0000-0000-0000-000000000008','10000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000008','RESOLVED_BY',NULL),
('90000000-0000-0000-0000-000000000009','10000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000009','GOVERNED_BY',NULL),
('90000000-0000-0000-0000-000000000010','20000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000002','HAS_PART',NULL),
('90000000-0000-0000-0000-000000000011','20000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000005','HAS_FAILURE_MODE',NULL),
('90000000-0000-0000-0000-000000000012','20000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000006','PRESENTS_AS',0.7200),
('90000000-0000-0000-0000-000000000013','20000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000007','VERIFIED_BY',NULL),
('90000000-0000-0000-0000-000000000014','20000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000008','GOVERNED_BY',NULL),
('90000000-0000-0000-0000-000000000015','30000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002','HAS_PART',NULL),
('90000000-0000-0000-0000-000000000016','30000000-0000-0000-0000-000000000003','30000000-0000-0000-0000-000000000005','HAS_FAILURE_MODE',NULL),
('90000000-0000-0000-0000-000000000017','30000000-0000-0000-0000-000000000005','30000000-0000-0000-0000-000000000004','PRESENTS_AS',0.6500),
('90000000-0000-0000-0000-000000000018','30000000-0000-0000-0000-000000000005','30000000-0000-0000-0000-000000000006','VERIFIED_BY',NULL),
('90000000-0000-0000-0000-000000000019','30000000-0000-0000-0000-000000000005','30000000-0000-0000-0000-000000000007','RESOLVED_BY',NULL);
