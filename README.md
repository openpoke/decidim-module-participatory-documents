# Decidim Participatory Documents

[![[CI] Lint](https://github.com/openpoke/decidim-module-participatory-documents/actions/workflows/lint.yml/badge.svg)](https://github.com/openpoke/decidim-module-participatory-documents/actions/workflows/lint.yml)
[![[CI] Test](https://github.com/openpoke/decidim-module-participatory-documents/actions/workflows/test.yml/badge.svg)](https://github.com/openpoke/decidim-module-participatory-documents/actions/workflows/test.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/b55516d46671ac78a43f/maintainability)](https://codeclimate.com/github/openpoke/decidim-module-participatory-documents/maintainability)
[![codecov](https://codecov.io/gh/openpoke/decidim-module-participatory-documents/branch/main/graph/badge.svg?token=TMZHD2XO6U)](https://codecov.io/gh/openpoke/decidim-module-participatory-documents)
[![Gem Version](https://badge.fury.io/rb/decidim-participatory-documents.svg)](https://badge.fury.io/rb/decidim-participatory-documents)

This module allows to upload PDF (and possibilty other formats) and define areas on top of it that will become spaces for suggestions, improvements and other participative activities.

> NOTE: in development, not ready for production.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-participatory_documents', git: "https://github.com/openpoke/decidim-module-participatory-documents"
```

And then execute:

```
bundle
```

## Usage

TODO...

```ruby
# config/initializers/participatory_documents.rb

Decidim::ParticipatoryDocuments.configure do |config|
end
```

And, of course, having these values in your `config/secrets.yml` file.

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
