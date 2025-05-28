# Decidim Participatory Documents

[![[CI] Lint](https://github.com/openpoke/decidim-module-participatory-documents/actions/workflows/lint.yml/badge.svg)](https://github.com/openpoke/decidim-module-participatory-documents/actions/workflows/lint.yml)
[![[CI] Test](https://github.com/openpoke/decidim-module-participatory-documents/actions/workflows/test.yml/badge.svg)](https://github.com/openpoke/decidim-module-participatory-documents/actions/workflows/test.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/b55516d46671ac78a43f/maintainability)](https://codeclimate.com/github/openpoke/decidim-module-participatory-documents/maintainability)
[![codecov](https://codecov.io/gh/openpoke/decidim-module-participatory-documents/branch/main/graph/badge.svg?token=TMZHD2XO6U)](https://codecov.io/gh/openpoke/decidim-module-participatory-documents)
[![Gem Version](https://badge.fury.io/rb/decidim-participatory_documents.svg)](https://badge.fury.io/rb/decidim-participatory_documents)

This module allows to upload PDF (and possibilty other formats) and define areas on top of it that will become spaces for suggestions, improvements and other participative activities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-participatory_documents
```

Or, if you want to stay up to date with the latest changes use this line instead:


```ruby
gem 'decidim-participatory_documents', git: "https://github.com/openpoke/decidim-module-participatory-documents"
```

And then execute:

```
bundle
bin/rails decidim:upgrade
bundle exec rails db:migrate
```

> **NOTE**
> Under the hood, these operation are run to install the needed database migrations and the PDF.js library:
>
> ```
> bundle
> bundle exec rails decidim_participatory_documents:install:migrations
> bundle exec rails decidim_participatory_documents:install_pdf_js
> ```
>
> Note that the PDF.js library is installed in the `public/pdfjs` (this might change in the future). Take it into account when deploying the application.

Depending on your Decidim version, you can choose the corresponding version to ensure compatibility:

| Version | Compatible Decidim versions |
|---------|-----------------------------|
| 0.2.x   | 0.27.x                      |
| 0.3.x   | 0.28.x                      |


## Usage

This module adds a new component to Decidim called `Participatory Documents` that allows to upload PDFs and define areas on top of it that will become spaces for suggestions or comments.

The administrator must upload a PDF file and then define areas on top of it by drawing polygons. 
Each area will become a new zone that will allow users to create suggestions.

## Configuration

By default, the module is configured to read the configuration from ENV variables.

Currently, the following ENV variables are supported:

| ENV variable | Description | Default value |
| ------------ | ----------- |-------|
| MAX_EXPORT_TEXT_LENGTH | If a positive number, it will truncate the exported suggestions before sending them by email | `0` |
| MIN_SUGGESTION_LENGTH | Minimum characters in a suggestion to be valid (this setting can be configured in each component as well by the admins) | `5` |
| MAX_SUGGESTION_LENGTH | Maximum characters in a suggestion to be valid (this setting can be configured in each component as well by the admins) | `1000` |

It is also possible to configure the module using the `decidim-participatory_documents` initializer:

```ruby
Decidim::ParticipatoryDocuments.configure do |config|
  config.max_export_text_length = 0
  config.min_suggestion_length = 5
  config.max_suggestion_length = 1000
end
```

## Antivirus compatibility

This module has a builtin compatibility with https://github.com/mainio/decidim-module-antivirus to scan the uploaded documents (it is also possible to directly use the gem https://github.com/mainio/ratonvirus if configuring it in a initializer).

If the antivirus is not installed, the module will still work but the documents will not be scanned.

> Note: this module only checks for the existence of the class `AntivirusValidator` so it is possible to use any other antivirus validator as well (a custom one for instance).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/openpoke/decidim-module-participatory-documents.

### Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby and PostgreSQL)
- Clone this repository

Decidim's main repository also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

Then to test how the module works in Decidim, start the development server:

```bash
$ cd development_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rails s
```

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

#### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

[Rubocop](https://rubocop.readthedocs.io/) linter is used for the Ruby language.

You can run the code styling checks by running the following commands from the
console:

```
$ bundle exec rubocop
```

To ease up following the style guide, you should install the plugin to your
favorite editor, such as:

- Atom - [linter-rubocop](https://atom.io/packages/linter-rubocop)
- Sublime Text - [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
- Visual Studio Code - [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)

### Testing

To run the tests run the following in the gem development path:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

### Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
$ SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/project/decidim-participatory-documents

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
