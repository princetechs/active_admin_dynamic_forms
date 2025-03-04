// ActiveAdminDynamicForms JavaScript
//
// This file handles the dynamic behavior of form fields in the admin interface

(function($) {
  $(document).on('ready page:load turbolinks:load', function() {
    // Show/hide options based on field type
    function toggleOptionsVisibility() {
      $('.dynamic-form-field').each(function() {
        var fieldType = $(this).find('select[id$="_field_type"]').val();
        var optionsFieldset = $(this).find('fieldset.options');
        
        if (['select', 'radio', 'checkbox'].includes(fieldType)) {
          optionsFieldset.show();
        } else {
          optionsFieldset.hide();
        }
      });
    }
    
    // Initial setup
    toggleOptionsVisibility();
    
    // When field type changes
    $(document).on('change', 'select[id$="_field_type"]', function() {
      toggleOptionsVisibility();
    });
    
    // When a new field is added
    $(document).on('has_many_add:after', function() {
      toggleOptionsVisibility();
    });
  });
})(jQuery); 