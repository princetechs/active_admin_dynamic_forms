# == Schema Information
#
# Table name: jobs
#
#  id                  :bigint           not null, primary key
#  company_info        :text
#  job_description     :text
#  location            :string(100)
#  screening_questions :jsonb
#  status              :string           default("active"), not null
#  title               :string(150)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_jobs_on_screening_questions  (screening_questions) USING gin
#  index_jobs_on_status               (status)
#
class Job < ApplicationRecord
  belongs_to :user
  
  # Add dynamic form support
  has_dynamic_form

  # Enums for status
  enum status: {
    active: 'active',
    inactive: 'inactive',
    draft: 'draft',
    archived: 'archived'
  }

  # Validations
  validates :title, presence: true, length: { maximum: 150 }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validate :validate_screening_questions_format

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :visible, -> { where(status: ['active', 'draft']) }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "location", "employment_type", "status", "created_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  private

  def validate_screening_questions_format
    return if screening_questions.blank?
    
    unless screening_questions.is_a?(Array)
      errors.add(:screening_questions, "must be an array")
      return
    end

    screening_questions.each do |question|
      unless valid_question_format?(question)
        errors.add(:screening_questions, "contains invalid question format")
        break
      end
    end
  end

  def valid_question_format?(question)
    return false unless question.is_a?(Hash)
    
    required_keys = ['question', 'type']
    return false unless required_keys.all? { |key| question.key?(key) }
    
    valid_types = ['multiple_choice', 'text', 'boolean', 'number']
    return false unless valid_types.include?(question['type'])

    # Validate multiple choice questions have options
    if question['type'] == 'multiple_choice'
      return false unless question['options'].is_a?(Array) && question['options'].any?
    end

    true
  end
end 