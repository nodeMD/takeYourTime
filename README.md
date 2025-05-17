# TakeYourTime

A Sinatra-based app for tracking emotions, needs, wants, and listening to podcast episodes. Features user authentication, pagination, and a modern UI with dark/light themes.

## Setup

1. **Install Ruby (3.3.8 recommended):**
   - Use [rbenv](https://github.com/rbenv/rbenv), [rvm](https://rvm.io/), or [asdf](https://asdf-vm.com/).
   - Ensure your Ruby version matches `.ruby-version`.

2. **Install dependencies:**
   ```sh
   bundle install
   ```

3. **Setup the database:**
   ```sh
   bundle exec rake db:create db:migrate
   # Optionally: bundle exec rake db:seed
   ```

4. **Run the app:**
   ```sh
   bundle exec rackup
   # or
   bundle exec ruby app.rb
   ```

5. **Access the app:**
   - Navigate to [http://localhost:9292](http://localhost:9292) or the port shown in your terminal.

## Running Specs

Run all tests/specs with:
```sh
bundle exec rspec
```

## Code Formatting

This project uses [standardrb](https://github.com/standardrb/standard) for Ruby code formatting. To check and auto-correct formatting:

```sh
bundle exec standardrb --fix
```

## Additional Commands

- **Database reset:**
  ```sh
  bundle exec rake db:reset
  ```
- **Install a new gem:**
  ```sh
  bundle add <gemname>
  bundle install
  ```

## Notes
- Podcasts and their assets are in `public/podcasts/`.
- For production deployment, review session/secret management and database configuration.
