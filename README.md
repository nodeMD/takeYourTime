![example workflow](https://github.com/nodeMD/takeYourTime/actions/workflows/unit-tests.yml/badge.svg)

# TakeYourTime

A Sinatra-based app with simple tools for creating checklists, tracking emotions, needs, wants and working on self esteem plus listening to podcast episodes. Features user authentication, pagination, and a modern UI with dark/light themes.

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

## Production Deployment

1. **Environment Variables**
   - Copy `.env.example` to `.env`
   - Set all required environment variables
   - Ensure `SESSION_SECRET` is a secure random value
   - Set `RACK_ENV=production`

2. **Database Configuration**
   - Ensure PostgreSQL is installed and running
   - Create the production database
   - Set up proper database user with appropriate permissions
   - Configure database connection in `.env`

3. **Security Settings**
   - Enable HTTPS (set `SSL_ENABLED=true`)
   - Configure proper session settings
   - Set up proper database connection pooling

4. **Deployment Steps**
   ```sh
   # Install dependencies
   bundle install --without development test
   
   # Create and migrate database
   bundle exec rake db:create
   bundle exec rake db:migrate
   
   # Start the application
   bundle exec puma -C config/puma.rb
   ```

5. **Security Considerations**
   - Never commit `.env` file to version control
   - Use secure session secrets
   - Enable HTTPS in production
   - Regularly rotate session secrets
   - Monitor database connection pooling

## Notes
- Podcasts and their assets are in `public/podcasts/`.
- For production deployment, review session/secret management and database configuration.
