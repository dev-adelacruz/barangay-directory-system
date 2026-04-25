# frozen_string_literal: true

class Api::V1::ActivityFeedController < Api::V1::BaseController
  FEED_LIMIT = 50

  def index
    events = []

    events += household_status_events
    events += evacuation_activations
    events += typhoon_mode_events

    sorted = events.sort_by { |e| e[:occurred_at] }.reverse.first(FEED_LIMIT)

    render json: { activities: sorted }
  end

  private

  def evacuation_activations
    scope = EvacuationEvent.order(activated_at: :desc).limit(10)
    scope = scope.for_barangay(scoped_barangay) if scoped_barangay

    scope.map do |event|
      {
        type: "evacuation_event",
        occurred_at: event.activated_at,
        description: "Evacuation protocol '#{event.name}' #{event.status}",
        barangay_name: event.barangay_name,
        changed_by: event.activated_by&.email,
        event_id: event.id
      }
    end
  end

  def household_status_events
    scope = HouseholdStatusChange.includes(household: [], user: [])
                                 .order(created_at: :desc)
                                 .limit(20)
    scope = scope.joins(:household).where(households: { barangay_name: scoped_barangay }) if scoped_barangay

    scope.map do |change|
      {
        type: "household_status_change",
        occurred_at: change.created_at,
        description: "#{change.household.household_head_name} changed from #{change.previous_status} to #{change.new_status}",
        barangay_name: change.household.barangay_name,
        changed_by: change.user&.email,
        household_id: change.household_id
      }
    end
  end

  def typhoon_mode_events # rubocop:disable Metrics/CyclomaticComplexity
    scope = TyphoonModeActivation.order(activated_at: :desc).limit(10)
    scope = scope.for_barangay(scoped_barangay) if scoped_barangay

    scope.map do |activation|
      {
        type: "typhoon_mode",
        occurred_at: activation.active? ? activation.activated_at : activation.deactivated_at,
        description: activation.active? ? "Typhoon mode activated (#{activation.typhoon_name})" : "Typhoon mode deactivated",
        barangay_name: activation.barangay_name,
        changed_by: activation.active? ? activation.activated_by&.email : activation.deactivated_by&.email,
        activation_id: activation.id
      }
    end
  end
end
