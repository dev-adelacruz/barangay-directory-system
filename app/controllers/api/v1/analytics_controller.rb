# frozen_string_literal: true

class Api::V1::AnalyticsController < Api::V1::BaseController
  def index
    render json: {
      analytics: {
        evacuation_frequency:,
        average_response_time_hours: average_response_time,
        special_needs_breakdown:,
        evacuation_status_breakdown:,
        monthly_evacuation_counts:
      }
    }
  end

  private

  def average_response_time
    events = scoped_events.where.not(resolved_at: nil)
    return nil if events.empty?

    total_seconds = events.sum { |e| (e.resolved_at - e.activated_at).to_f }
    (total_seconds / events.count / 3600).round(2)
  end

  def evacuation_frequency
    scoped_events
      .group(:barangay_name)
      .count
      .map { |barangay, count| { barangay_name: barangay, evacuation_count: count } }
      .sort_by { |r| -r[:evacuation_count] }
  end

  def evacuation_status_breakdown
    Household.evacuation_statuses.keys.index_with do |status|
      scoped_households.where(evacuation_status: status).count
    end
  end

  def monthly_evacuation_counts
    scoped_events
      .where("activated_at >= ?", 12.months.ago)
      .group_by { |e| e.activated_at.strftime("%Y-%m") }
      .transform_values(&:count)
      .then do |counts|
        12.times.map do |i|
          month = i.months.ago.strftime("%Y-%m")
          { month:, count: counts[month] || 0 }
        end.reverse
      end
  end

  def scoped_events
    scope = EvacuationEvent.resolved_events
    scoped_barangay ? scope.for_barangay(scoped_barangay) : scope
  end

  def scoped_households
    scope = Household.active
    scoped_barangay ? scope.for_barangay(scoped_barangay) : scope
  end

  def scoped_residents
    scope = Resident.active
    scoped_barangay ? scope.for_barangay(scoped_barangay) : scope
  end

  def special_needs_breakdown
    Resident.special_needs_categories.keys.each_with_object({}) do |category, hash|
      scope = scoped_residents.where(special_needs_category: category)
      hash[category] = scope.count
    end
  end
end
