# frozen_string_literal: true

class Api::V1::DashboardController < Api::V1::BaseController
  def summary # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    households = scoped_households.active
    residents = scoped_residents.active

    evacuated_households = households.where(evacuation_status: :evacuated)
    pre_emptive_households = households.where(evacuation_status: :pre_emptively_evacuated)
    unaccounted_households = households.where(evacuation_status: :unaccounted)
    high_risk_residents = residents.with_special_needs

    centers = scoped_centers
    open_centers = centers.available

    render json: {
      summary: {
        total_households: households.count,
        total_residents: residents.count,
        evacuated_households: evacuated_households.count,
        pre_emptively_evacuated_households: pre_emptive_households.count,
        unaccounted_households: unaccounted_households.count,
        high_risk_residents: high_risk_residents.count,
        open_evacuation_centers: open_centers.count,
        total_evacuation_centers: centers.count,
        total_evacuated_residents: residents.with_evacuation_status(:evacuated).count,
        typhoon_mode_active: typhoon_active?
      }
    }
  end

  private

  def scoped_centers
    scoped_barangay ? EvacuationCenter.for_barangay(scoped_barangay) : EvacuationCenter.all
  end

  def scoped_households
    scoped_barangay ? Household.for_barangay(scoped_barangay) : Household.all
  end

  def scoped_residents
    scoped_barangay ? Resident.for_barangay(scoped_barangay) : Resident.all
  end

  def typhoon_active?
    scope = TyphoonModeActivation.active
    if scoped_barangay
      scope.for_barangay(scoped_barangay).exists? || scope.municipality_wide.exists?
    else
      scope.exists?
    end
  end
end
