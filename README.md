# ActiveAdminDynamicForms

A Ruby on Rails gem that integrates with Active Admin to enable dynamic form creation and management.

## Project Goals

- Allow administrators to create and manage custom forms through the Active Admin interface
- Support various input types (text, dropdown, radio, checkbox, etc.)
- Associate forms with any Rails model
- Access form responses as attributes on model instances (e.g., `job.form.name`)
- Provide a clean and intuitive interface for form creation and management

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_admin_dynamic_forms'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install active_admin_dynamic_forms
```

## Usage

### Setup

After installing the gem, run the installation generator:

```bash
$ rails generate active_admin_dynamic_forms:install
```

This will:
1. Create necessary migrations
2. Add Active Admin configurations
3. Set up required models

#### Alternative Installation Methods

If you encounter issues with the Rails generator, you can use one of these alternative methods:

1. Using the Rake task:

```bash
$ rake active_admin_dynamic_forms:install
```

2. Using the standalone script:

```bash
$ ruby /path/to/active_admin_dynamic_forms/install.rb
```

3. Using the bin script:

```bash
$ /path/to/active_admin_dynamic_forms/bin/active_admin_dynamic_forms_install
```

For detailed installation instructions and troubleshooting, see the [INSTALL.md](INSTALL.md) file.

### Creating Forms

Navigate to the Forms section in your Active Admin dashboard to create and manage forms.

### Associating Forms with Models

In your model:

```ruby
class Job < ApplicationRecord
  has_dynamic_form
end
```

### Accessing Form Data

```ruby
job = Job.find(1)
job.form.field_name # Access a specific field
job.form.fields # Access all fields
```

### Using the Polymorphic Association Structure

The gem now supports a flexible polymorphic association structure that allows you to:

1. Associate any model with multiple forms without requiring a `dynamic_form_id` column
2. Manage form associations through a standardized interface
3. Display forms and responses in a consistent way across different models

#### Adding Dynamic Forms to an ActiveAdmin Resource

To add dynamic form functionality to any ActiveAdmin resource:

```ruby
ActiveAdmin.register User do
  has_dynamic_forms
end
```

This will:
- Add a "Dynamic Forms" tab to the resource
- Display associated forms on the show page
- Add routes for managing form associations
- Include form selection in the edit form

#### Manually Managing Form Associations

You can also manually manage form associations in your code:

```ruby
# Add a form to a record
user = User.find(1)
form = ActiveAdminDynamicForms::Models::DynamicForm.find(2)
user.add_form(form)

# Remove a form from a record
user.remove_form(form)

# Get all forms associated with a record
user.specific_forms # Returns array of [name, id] pairs

# Get all available forms for a record
user.available_forms # Returns array of [name, id] pairs
```

## Database Schema

The gem creates the following tables:

- `dynamic_forms`: Stores form definitions
- `dynamic_form_fields`: Stores field definitions for each form
- `dynamic_form_options`: Stores options for select, radio, and checkbox fields
- `dynamic_form_responses`: Stores form responses
- `dynamic_form_model_associations`: Stores associations between forms and model classes
- `form_record_associations`: Stores polymorphic associations between forms and specific records

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/princetechs/active_admin_dynamic_forms

## License

The gem is available as open source under the terms of the MIT License.
