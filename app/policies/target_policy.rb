class TargetPolicy < ApplicationPolicy
  def show?
    current_founder.present? && current_founder.course == record.course
  end

  def details_v2?
    # PupilFirst does not have any targets.
    return false unless record.present? && record.course.school == current_school

    founder = user.founders.joins(:course).where(courses: { id: record.course }).first

    # Current user must have a founder profile in the course
    return false if founder.blank?

    # Dropped out students cannot access student overlay.
    !founder.exited?
  end

  def prerequisite_targets?
    current_founder.present?
  end

  alias startup_feedback? prerequisite_targets?
  alias details? prerequisite_targets?

  def auto_verify?
    prerequisite_targets? &&
      record.evaluation_criteria.blank? &&
      current_founder.startup.level.course == record.course &&
      current_founder.timeline_events.where(target: record).empty?
  end
end
