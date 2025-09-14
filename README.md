# CBT Question Generator

A Ruby on Rails application that generates Computer-Based Test (CBT) questions from PDF documents using OpenAI's GPT-3.5.

## Features

- Upload PDF documents
- Store files in Cloudinary
- Generate 50 multiple-choice questions with 4 options each
- Generate 5 theory questions
- Clean dashboard to view all uploads
- View questions by upload with separate sections for objective and theory questions

## Prerequisites

### For macOS:
1. Install Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

2. Install Ruby using rbenv:
    ```bash
    brew install rbenv ruby-build
    rbenv init
    rbenv install 3.2.2
    rbenv global 3.2.2
    ```

3. Install PostgreSQL:
    ```bash
      brew install postgresql
      brew services start postgresql
    ```

4. Install Node.js:
    ```bash
    brew install node
    ```
5. Install Rails:
    ```bash
    gem install rails
    ```

### For Windows:
- Install Ruby using RubyInstaller: https://rubyinstaller.org/
- Install PostgreSQL: https://www.postgresql.org/download/windows/
- Install Node.js: https://nodejs.org/
- Install Rails

## Setup Instructions

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/cbt_question_generator.git
    cd cbt_question_generator
    ```
2. Install dependencies:
    ```bash
    bundle install
    ```

3. Set up the database:
    ```bash
      rails db:create
      rails db:migrate
    ```
4. Set up environment variables:
    Create a `.env` file in the root directory and add the following variables:
    ```env
    CLOUDINARY_CLOUD_NAME=your_cloud_name
    CLOUDINARY_API_KEY=your_api_key
    CLOUDINARY_API_SECRET=your_api_secret
    OPENAI_API_KEY=your_openai_api_key
    ```

5. Start Redis (required for Sidekiq):
    ```bash
      brew install redis
      brew services start redis

      # Windows
      # Download and install Redis from https://github.com/microsoftarchive/redis/releases
    ```

6. Start Sidekiq in a separate terminal:
    ```bash
    bundle exec sidekiq
    ```

7. Start the Rails server:
    ```bash
    rails server
    ```

8. Open your browser and navigate to `http://localhost:3000`

## Usage

1. Click on "New Upload" to upload a PDF document
2. Provide a name for the document and select the PDF file
3. Submit the form - the file will be uploaded to Cloudinary
4. The system will process the PDF and generate questions in the background
5. View the generated questions by clicking on "View Questions" from the dashboard

## API Keys

- Cloudinary: Sign up at https://cloudinary.com/ for free cloud storage
- OpenAI: Sign up at https://openai.com/ and generate an API key

## Deployment

For production deployment, consider using:
- Heroku
- Render
- DigitalOcean App Platform
Make sure to set the environment variables in your production environment.

## Contributing

- Fork the repository
- Create a feature branch
- Make your changes
- Add tests if applicable
- Submit a pull request

## License

This project is licensed under the MIT License.
