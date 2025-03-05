# Installing ActiveAdminDynamicForms

There are several ways to install and set up ActiveAdminDynamicForms in your Rails application:

## Option 1: Using the Rails Generator (Recommended)

If the Rails generator is properly registered, you can run:

```bash
rails generate active_admin_dynamic_forms:install
```

This will:
- Create the necessary migrations
- Create an initializer
- Create an admin resource
- Mount the engine in your routes
- Add the necessary assets to your manifest

## Option 2: Using the Rake Task

If the Rails generator is not working, you can use the rake task:

```bash
rake active_admin_dynamic_forms:install
```

## Option 3: Using the Standalone Script

If neither of the above options work, you can use the standalone script:

```bash
ruby /path/to/active_admin_dynamic_forms/install.rb
```

## Option 4: Using the Bin Script

You can also use the bin script:

```bash
/path/to/active_admin_dynamic_forms/bin/active_admin_dynamic_forms_install
```

## Option 5: Using the Install Script

If you're having issues with the generator not being found, you can use the install script to create a symlink to the generator files in your Rails application:

```bash
/path/to/active_admin_dynamic_forms/bin/install_in_rails_app
```

This will prompt you for the path to your Rails application directory and create a symlink to the generator files.

## Option 6: Manual Symlink Creation

You can also manually create a symlink to the generator files in your Rails application:

```bash
mkdir -p /path/to/rails/app/lib/generators
ln -sf /path/to/active_admin_dynamic_forms/lib/generators/active_admin_dynamic_forms /path/to/rails/app/lib/generators/
```

Then you can run the generator as usual:

```bash
rails generate active_admin_dynamic_forms:install
```

## Manual Installation

If none of the above options work, you can manually install the gem:

1. Create the migrations:
   - Copy the migration files from `lib/generators/active_admin_dynamic_forms/install/templates/create_active_admin_dynamic_forms_tables.rb` and `lib/generators/active_admin_dynamic_forms/install/templates/add_model_class_to_dynamic_forms.rb` to your `db/migrate` directory.
   - Run `rails db:migrate` to create the necessary tables.

2. Create an initializer:
   - Copy the initializer file from `lib/generators/active_admin_dynamic_forms/install/templates/initializer.rb` to your `config/initializers/active_admin_dynamic_forms.rb` file.

3. Create an admin resource:
   - Copy the admin resource file from `lib/generators/active_admin_dynamic_forms/install/templates/dynamic_form.rb` to your `app/admin/dynamic_form.rb` file.

4. Mount the engine in your routes:
   - Add `mount ActiveAdminDynamicForms::Engine => '/active_admin_dynamic_forms'` to your `config/routes.rb` file.

5. Add the necessary assets to your manifest:
   - Add `//= link active_admin_dynamic_forms/admin.css` and `//= link active_admin_dynamic_forms/admin.js` to your `app/assets/config/manifest.js` file.

## Troubleshooting

If you're having issues with the installation, you can run:

```bash
rake active_admin_dynamic_forms:check_generator
```

This will check if the generator is properly registered and can be found. 