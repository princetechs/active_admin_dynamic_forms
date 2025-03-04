require 'spec_helper'

RSpec.describe ActiveAdminDynamicForms::Concerns::HasDynamicForm do
  let(:test_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'test_models'
      has_dynamic_form
    end
  end

  describe 'when included in a class' do
    it 'adds a has_one association for dynamic_form_response' do
      association = test_class.reflect_on_association(:dynamic_form_response)
      expect(association.macro).to eq :has_one
    end

    it 'adds a belongs_to association for dynamic_form' do
      association = test_class.reflect_on_association(:dynamic_form)
      expect(association.macro).to eq :belongs_to
    end

    it 'adds a form method' do
      expect(test_class.instance_methods).to include(:form)
    end

    it 'adds a form_data method' do
      expect(test_class.instance_methods).to include(:form_data)
    end

    it 'adds a form_data= method' do
      expect(test_class.instance_methods).to include(:form_data=)
    end

    it 'adds an after_save callback' do
      callbacks = test_class._save_callbacks.select { |cb| cb.kind == :after }
      expect(callbacks.map(&:filter)).to include(:create_or_update_form_response)
    end
  end

  let(:dynamic_form) { ActiveAdminDynamicForms::Models::DynamicForm.create!(name: "Test Form #{rand(1000)}", description: 'Test Description') }
  let(:test_instance) { test_class.create! }

  describe '#form' do
    it 'returns the dynamic_form_response' do
      response = ActiveAdminDynamicForms::Models::DynamicFormResponse.create!(
        dynamic_form_id: dynamic_form.id,
        record_id: test_instance.id,
        record_type: test_instance.class.name,
        data: { 'test_field' => 'test_value' }
      )
      expect(test_instance.form).to eq(response)
    end
  end

  describe '#create_or_update_form_response' do
    context 'when dynamic_form is present' do
      before do
        test_instance.dynamic_form_id = dynamic_form.id
        test_instance.save!
      end

      context 'when dynamic_form_response exists' do
        let!(:existing_response) do
          ActiveAdminDynamicForms::Models::DynamicFormResponse.create!(
            dynamic_form_id: dynamic_form.id,
            record_id: test_instance.id,
            record_type: test_instance.class.name,
            data: { 'test_field' => 'old_value' }
          )
        end

        it 'updates the existing response' do
          test_instance.save!
          existing_response.reload
          expect(existing_response.form).to eq(dynamic_form)
        end
      end

      context 'when dynamic_form_response does not exist' do
        it 'creates a new response' do
          expect { test_instance.save! }.to change {
            ActiveAdminDynamicForms::Models::DynamicFormResponse.count
          }.by(1)
          expect(test_instance.dynamic_form_response.form).to eq(dynamic_form)
        end
      end
    end

    context 'when dynamic_form is not present' do
      it 'does nothing' do
        expect { test_instance.save! }.not_to change {
          ActiveAdminDynamicForms::Models::DynamicFormResponse.count
        }
      end
    end
  end
end