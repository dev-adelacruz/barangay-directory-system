# frozen_string_literal: true

# Seed data for Barangay Directory System
# Modeled after Virac, Catanduanes — a typhoon-prone municipality

puts "Seeding users..."

admin = User.find_or_create_by!(email: "admin@virac.gov.ph") do |u|
  u.password = "password123"
  u.role = :admin
  u.barangay_name = nil
  u.active = true
end

staff_gogon = User.find_or_create_by!(email: "staff.gogon@virac.gov.ph") do |u|
  u.password = "password123"
  u.role = :staff
  u.barangay_name = "Barangay Gogon"
  u.active = true
end

staff_salvacion = User.find_or_create_by!(email: "staff.salvacion@virac.gov.ph") do |u|
  u.password = "password123"
  u.role = :staff
  u.barangay_name = "Barangay Salvacion"
  u.active = true
end

staff_stdomingo = User.find_or_create_by!(email: "staff.santodomingo@virac.gov.ph") do |u|
  u.password = "password123"
  u.role = :staff
  u.barangay_name = "Barangay Sto. Domingo"
  u.active = true
end

drrmo = User.find_or_create_by!(email: "drrmo@catanduanes.gov.ph") do |u|
  u.password = "password123"
  u.role = :drrmo
  u.barangay_name = nil
  u.active = true
end

puts "  ✓ #{User.count} users created"
puts "    admin@virac.gov.ph / password123"
puts "    staff.gogon@virac.gov.ph / password123"
puts "    staff.salvacion@virac.gov.ph / password123"
puts "    staff.santodomingo@virac.gov.ph / password123"
puts "    drrmo@catanduanes.gov.ph / password123"

# ---------------------------------------------------------------------------
puts "\nSeeding evacuation centers..."

centers = [
  {
    name: "Virac Central Elementary School",
    barangay_name: "Barangay Gogon",
    address: "Gogon, Virac, Catanduanes",
    max_capacity: 300,
    current_occupancy: 0,
    latitude: 13.5792,
    longitude: 124.2463,
    status: :open
  },
  {
    name: "Salvacion Covered Court",
    barangay_name: "Barangay Salvacion",
    address: "Salvacion, Virac, Catanduanes",
    max_capacity: 150,
    current_occupancy: 0,
    latitude: 13.5850,
    longitude: 124.2510,
    status: :open
  },
  {
    name: "Sto. Domingo Barangay Hall",
    barangay_name: "Barangay Sto. Domingo",
    address: "Sto. Domingo, Virac, Catanduanes",
    max_capacity: 100,
    current_occupancy: 0,
    latitude: 13.5910,
    longitude: 124.2580,
    status: :open
  }
]

created_centers = centers.map do |attrs|
  EvacuationCenter.find_or_create_by!(name: attrs[:name]) do |c|
    c.assign_attributes(attrs)
  end
end

puts "  ✓ #{EvacuationCenter.count} evacuation centers created"

# ---------------------------------------------------------------------------
puts "\nSeeding risk zones..."

risk_zones = [
  {
    name: "Gogon Coastal Flood Zone",
    barangay_name: "Barangay Gogon",
    risk_level: :high,
    description: "Low-lying coastal area prone to storm surge during typhoons.",
    boundary: {
      "type" => "Polygon",
      "coordinates" => [[[124.240, 13.575], [124.248, 13.575], [124.248, 13.580], [124.240, 13.580], [124.240, 13.575]]]
    }
  },
  {
    name: "Salvacion Riverbank Zone",
    barangay_name: "Barangay Salvacion",
    risk_level: :medium,
    description: "River embankment area susceptible to flooding during heavy rain.",
    boundary: {
      "type" => "Polygon",
      "coordinates" => [[[124.248, 13.582], [124.255, 13.582], [124.255, 13.588], [124.248, 13.588], [124.248, 13.582]]]
    }
  },
  {
    name: "Sto. Domingo Upland Zone",
    barangay_name: "Barangay Sto. Domingo",
    risk_level: :low,
    description: "Elevated area with lower flood risk but possible landslide exposure.",
    boundary: {
      "type" => "Polygon",
      "coordinates" => [[[124.255, 13.589], [124.262, 13.589], [124.262, 13.595], [124.255, 13.595], [124.255, 13.589]]]
    }
  }
]

risk_zones.each do |attrs|
  RiskZone.find_or_create_by!(name: attrs[:name]) do |z|
    z.assign_attributes(attrs)
  end
end

puts "  ✓ #{RiskZone.count} risk zones created"

# ---------------------------------------------------------------------------
puts "\nSeeding households..."

gogon_households = [
  { household_head_name: "Ricardo Bautista", sitio_purok: "Purok 1", member_count: 5,
    latitude: 13.5780, longitude: 124.2441,
    has_pwd: true, evacuation_status: :at_home },
  { household_head_name: "Lorna Macaraeg", sitio_purok: "Purok 1", member_count: 3,
    latitude: 13.5785, longitude: 124.2448,
    has_elderly: true, evacuation_status: :at_home },
  { household_head_name: "Eduardo Fajardo", sitio_purok: "Purok 2", member_count: 7,
    latitude: 13.5791, longitude: 124.2455,
    has_infants: true, has_pregnant: true, evacuation_status: :evacuated },
  { household_head_name: "Maria Santos", sitio_purok: "Purok 2", member_count: 4,
    latitude: 13.5795, longitude: 124.2461,
    evacuation_status: :pre_emptively_evacuated },
  { household_head_name: "Jose dela Cruz", sitio_purok: "Purok 3", member_count: 6,
    latitude: 13.5800, longitude: 124.2467,
    has_bedridden: true, evacuation_status: :at_home }
].map do |attrs|
  Household.find_or_create_by!(household_head_name: attrs[:household_head_name],
                                barangay_name: "Barangay Gogon") do |h|
    h.assign_attributes(attrs.merge(barangay_name: "Barangay Gogon"))
  end
end

salvacion_households = [
  { household_head_name: "Carmelita Reyes", sitio_purok: "Sitio Mabini", member_count: 4,
    latitude: 13.5840, longitude: 124.2500,
    has_elderly: true, evacuation_status: :at_home },
  { household_head_name: "Danilo Villanueva", sitio_purok: "Sitio Mabini", member_count: 5,
    latitude: 13.5848, longitude: 124.2507,
    evacuation_status: :evacuated },
  { household_head_name: "Teresita Ocampo", sitio_purok: "Sitio Rizal", member_count: 3,
    latitude: 13.5855, longitude: 124.2514,
    has_pwd: true, has_infants: true, evacuation_status: :at_home }
].map do |attrs|
  Household.find_or_create_by!(household_head_name: attrs[:household_head_name],
                                barangay_name: "Barangay Salvacion") do |h|
    h.assign_attributes(attrs.merge(barangay_name: "Barangay Salvacion"))
  end
end

stdomingo_households = [
  { household_head_name: "Fernando Alcantara", sitio_purok: "Purok Silangan", member_count: 6,
    latitude: 13.5905, longitude: 124.2570,
    evacuation_status: :at_home },
  { household_head_name: "Rosario Mendoza", sitio_purok: "Purok Silangan", member_count: 4,
    latitude: 13.5912, longitude: 124.2577,
    has_pregnant: true, evacuation_status: :at_home }
].map do |attrs|
  Household.find_or_create_by!(household_head_name: attrs[:household_head_name],
                                barangay_name: "Barangay Sto. Domingo") do |h|
    h.assign_attributes(attrs.merge(barangay_name: "Barangay Sto. Domingo"))
  end
end

# Assign evacuated Gogon households to the center
evacuated = gogon_households.select(&:evacuated?)
evacuated.each { |h| h.update!(evacuation_center: created_centers[0]) }

salvacion_evacuated = salvacion_households.select(&:evacuated?)
salvacion_evacuated.each { |h| h.update!(evacuation_center: created_centers[1]) }
created_centers[0].update!(current_occupancy: evacuated.sum(&:member_count))
created_centers[1].update!(current_occupancy: salvacion_evacuated.sum(&:member_count))

puts "  ✓ #{Household.count} households created"

# ---------------------------------------------------------------------------
puts "\nSeeding residents..."

resident_data = {
  gogon_households[0] => [
    { full_name: "Ricardo Bautista Sr.", age: 52, sex: :male, relationship_to_head: "Head", special_needs_category: :no_needs },
    { full_name: "Gloria Bautista", age: 48, sex: :female, relationship_to_head: "Spouse", special_needs_category: :no_needs },
    { full_name: "Mark Bautista", age: 22, sex: :male, relationship_to_head: "Son", special_needs_category: :pwd },
    { full_name: "Ana Bautista", age: 18, sex: :female, relationship_to_head: "Daughter", special_needs_category: :no_needs },
    { full_name: "Lolo Bautista", age: 78, sex: :male, relationship_to_head: "Father", special_needs_category: :elderly }
  ],
  gogon_households[1] => [
    { full_name: "Lorna Macaraeg", age: 65, sex: :female, relationship_to_head: "Head", special_needs_category: :elderly },
    { full_name: "Ben Macaraeg", age: 38, sex: :male, relationship_to_head: "Son", special_needs_category: :no_needs },
    { full_name: "Cathy Macaraeg", age: 35, sex: :female, relationship_to_head: "Daughter-in-law", special_needs_category: :no_needs }
  ],
  gogon_households[2] => [
    { full_name: "Eduardo Fajardo", age: 44, sex: :male, relationship_to_head: "Head", special_needs_category: :no_needs },
    { full_name: "Nena Fajardo", age: 40, sex: :female, relationship_to_head: "Spouse", special_needs_category: :pregnant },
    { full_name: "Pedro Fajardo", age: 1, sex: :male, relationship_to_head: "Son", special_needs_category: :infant },
    { full_name: "Sofia Fajardo", age: 8, sex: :female, relationship_to_head: "Daughter", special_needs_category: :no_needs },
    { full_name: "Carlos Fajardo", age: 12, sex: :male, relationship_to_head: "Son", special_needs_category: :no_needs },
    { full_name: "Luisa Fajardo", age: 70, sex: :female, relationship_to_head: "Mother", special_needs_category: :elderly },
    { full_name: "Ramon Fajardo", age: 72, sex: :male, relationship_to_head: "Father", special_needs_category: :elderly }
  ],
  gogon_households[4] => [
    { full_name: "Jose dela Cruz", age: 55, sex: :male, relationship_to_head: "Head", special_needs_category: :no_needs },
    { full_name: "Elena dela Cruz", age: 82, sex: :female, relationship_to_head: "Mother", special_needs_category: :bedridden }
  ],
  salvacion_households[0] => [
    { full_name: "Carmelita Reyes", age: 60, sex: :female, relationship_to_head: "Head", special_needs_category: :elderly },
    { full_name: "Bobby Reyes", age: 35, sex: :male, relationship_to_head: "Son", special_needs_category: :no_needs },
    { full_name: "Tina Reyes", age: 32, sex: :female, relationship_to_head: "Daughter-in-law", special_needs_category: :no_needs },
    { full_name: "Baby Reyes", age: 2, sex: :female, relationship_to_head: "Granddaughter", special_needs_category: :infant }
  ],
  salvacion_households[2] => [
    { full_name: "Teresita Ocampo", age: 45, sex: :female, relationship_to_head: "Head", special_needs_category: :no_needs },
    { full_name: "Greg Ocampo", age: 48, sex: :male, relationship_to_head: "Spouse", special_needs_category: :pwd },
    { full_name: "Nico Ocampo", age: 1, sex: :male, relationship_to_head: "Son", special_needs_category: :infant }
  ],
  stdomingo_households[0] => [
    { full_name: "Fernando Alcantara", age: 40, sex: :male, relationship_to_head: "Head", special_needs_category: :no_needs },
    { full_name: "Maricel Alcantara", age: 38, sex: :female, relationship_to_head: "Spouse", special_needs_category: :no_needs },
    { full_name: "Jun Alcantara", age: 16, sex: :male, relationship_to_head: "Son", special_needs_category: :no_needs },
    { full_name: "Bella Alcantara", age: 13, sex: :female, relationship_to_head: "Daughter", special_needs_category: :no_needs }
  ],
  stdomingo_households[1] => [
    { full_name: "Rosario Mendoza", age: 29, sex: :female, relationship_to_head: "Head", special_needs_category: :pregnant },
    { full_name: "Arnel Mendoza", age: 31, sex: :male, relationship_to_head: "Spouse", special_needs_category: :no_needs }
  ]
}

resident_data.each do |household, residents|
  residents.each do |attrs|
    Resident.find_or_create_by!(full_name: attrs[:full_name], household: household) do |r|
      r.assign_attributes(attrs)
    end
  end
end

puts "  ✓ #{Resident.count} residents created"

# ---------------------------------------------------------------------------
puts "\nSeeding evacuation event history..."

unless EvacuationEvent.exists?
  past_event = EvacuationEvent.create!(
    name: "Typhoon Rolly Response",
    barangay_name: "Barangay Gogon",
    scope: :barangay_wide,
    status: :resolved,
    typhoon_name: "Typhoon Rolly",
    households_affected: 12,
    residents_affected: 48,
    activated_by: admin,
    activated_at: 3.months.ago,
    resolved_by: admin,
    resolved_at: 3.months.ago + 4.days,
    notes: "All households accounted for. Returned home after flooding subsided."
  )

  EvacuationEvent.create!(
    name: "Tropical Storm Ambo Response",
    barangay_name: "Barangay Salvacion",
    scope: :barangay_wide,
    status: :resolved,
    typhoon_name: "Tropical Storm Ambo",
    households_affected: 7,
    residents_affected: 28,
    activated_by: staff_salvacion,
    activated_at: 6.months.ago,
    resolved_by: staff_salvacion,
    resolved_at: 6.months.ago + 2.days,
    notes: "Pre-emptive evacuation successful. No casualties."
  )

  puts "  ✓ #{EvacuationEvent.count} past evacuation events created"
end

# ---------------------------------------------------------------------------
puts "\nSeeding household status changes..."

if HouseholdStatusChange.count == 0
  evacuated_hh = gogon_households[2]
  HouseholdStatusChange.create!(
    household: evacuated_hh,
    user: staff_gogon,
    previous_status: :at_home,
    new_status: :evacuated,
    created_at: 1.hour.ago
  )

  preemptive_hh = gogon_households[3]
  HouseholdStatusChange.create!(
    household: preemptive_hh,
    user: staff_gogon,
    previous_status: :at_home,
    new_status: :pre_emptively_evacuated,
    created_at: 2.hours.ago
  )

  salvacion_ev = salvacion_households[1]
  HouseholdStatusChange.create!(
    household: salvacion_ev,
    user: staff_salvacion,
    previous_status: :at_home,
    new_status: :evacuated,
    created_at: 90.minutes.ago
  )

  puts "  ✓ #{HouseholdStatusChange.count} status changes logged"
end

# ---------------------------------------------------------------------------
puts "\n✅ Seed complete!"
puts "\nTest credentials:"
puts "  Admin:    admin@virac.gov.ph        / password123"
puts "  Staff:    staff.gogon@virac.gov.ph  / password123  (Barangay Gogon)"
puts "  Staff:    staff.salvacion@virac.gov.ph / password123  (Barangay Salvacion)"
puts "  DRRMO:    drrmo@catanduanes.gov.ph  / password123"
puts "\nData summary:"
puts "  #{User.count} users | #{Household.count} households | #{Resident.count} residents"
puts "  #{EvacuationCenter.count} evacuation centers | #{RiskZone.count} risk zones"
puts "  #{EvacuationEvent.count} past events | #{HouseholdStatusChange.count} status changes"
