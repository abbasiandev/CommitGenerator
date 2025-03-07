# Commit Generator 🚀

## Git Commit Generator Command Line Tools Powered by AI

Commit Generator is a simple command line tools that leverages the power of OpenAI's language models to automatically generate meaningful, descriptive, and consistent git commit messages. By analyzing the changes in your git repository, the application suggests commit messages that accurately reflect your code modifications, helping you maintain a clean, professional commit history with minimal effort.

## 📋 Prerequisites
- **Swift**: 5.5+
- **OpenAI API Key**: Required for generating commit messages

## 🔧 Installation

### From Source

1. Clone the repository:
   ```zsh
   git clone https://github.com/MahdiAbbasian/CommitGenerator.git
   ```

2. Open the project in Xcode 16:
   ```zsh
   cd CommitGenerator
   open CommitGenerator.xcodeproj
   ```

3. Build (⌘+B) and run (⌘+R)


## 🚀 Getting Started

1. **Launch the application** - Open Commit Generator from your directory
2. **API Configuration** - Enter your OpenAI API key
4. **Stage Files** - **Important**: You must have staged files in your git repository for to analyze changes
5. **Generate Commits** - View the suggested commit messages based on your staged changes
6. **Customize & Use** - Edit the suggestions if needed, then use them for your commits

## ⚠️ Important Note

The application requires at least one staged file in your git repository to function properly. Before generating commit suggestions:

```bash
# Stage your changes using git
git add <filename>

# Or stage all changes
git add .
```

Without staged files, the commit generator cannot analyze your changes to suggest appropriate commit messages.
This information is then processed through OpenAI's language models to generate commit messages that adhere to best practices while accurately describing your changes.
