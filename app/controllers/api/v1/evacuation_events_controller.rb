# frozen_string_literal: true

# rubocop:disable Layout/OrderedMethods
class Api::V1::EvacuationEventsController < Api::V1::BaseController
  before_action :authorize_write!, only: %i[create resolve]
  before_action :set_event, only: %i[show resolve]

  def index
    events = apply_filters(base_scope.order(activated_at: :desc))
                .page(params[:page]).per(params[:per_page] || 25)
    render json: {
      evacuation_events: EvacuationEventBlueprint.render_as_hash(events),
      meta: pagination_meta(events)
    }
  end

  def show
    render json: { evacuation_event: EvacuationEventBlueprint.render_as_hash(@event) }
  end

  def create
    event = EvacuationEvent.new(event_params)
    event.activated_by = current_user
    event.activated_at = Time.current
    event.scope = params.dig(:evacuation_event, :scope) == "municipality_wide" ? :municipality_wide : :barangay_wide

    if event.save
      render json: { evacuation_event: EvacuationEventBlueprint.render_as_hash(event) }, status: :created
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def resolve
    if @event.resolved?
      return render json: { error: "Event is already resolved." }, status: :unprocessable_entity
    end

    @event.resolve!(current_user, notes: params[:notes])
    render json: { evacuation_event: EvacuationEventBlueprint.render_as_hash(@event) }
  end

  private

  def apply_filters(scope)
    scope = scope.for_barangay(params[:barangay_name]) if params[:barangay_name].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope
  end

  def base_scope
    scoped_barangay ? EvacuationEvent.for_barangay(scoped_barangay) : EvacuationEvent.all
  end

  def event_params
    params.require(:evacuation_event).permit(:name, :barangay_name, :notes)
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_count: collection.total_count,
      total_pages: collection.total_pages
    }
  end

  def set_event
    @event = base_scope.find(params[:id])
  end
end
# rubocop:enable Layout/OrderedMethods
