//
//  README.md
//  CommitGenerator
//
//  Created by Mahdi Abbasian on 3/4/25.
//

# Commit Generator 🚀

## Overview
Commit Generator is an intelligent CLI tool that automatically generates meaningful git commit messages using AI, helping developers maintain clean and descriptive commit histories.

## Prerequisites
- Swift 5.5+
- Xcode (optional)
- OpenAI API Key

## Installation

### Option 1: Clone and Build
```bash
# Clone the repository
git clone https://github.com/yourusername/commit-generator.git
cd commit-generator

# Build the package
swift build -c release

# Install the executable
cp .build/release/commit-generator /usr/local/bin/commit-generator
```

### Option 2: Swift Package Manager
Add to your `Package.swift`:
```swift
.package(url: "https://github.com/yourusername/commit-generator", from: "1.0.0")
```

## Usage

### Set API Key
```bash
# Option 1: Environment Variable
export OPENAI_API_KEY='your-openai-api-key'

# Option 2: CLI Argument
commit-generator --api-key sk-your-openai-key
```

### Basic Usage
```bash
# In your git repository
commit-generator

# Specify a different directory
commit-generator --directory /path/to/repo
```

## Project Structure
- `Sources/CommitGenerator/`
  - `API/`: OpenAI API communication
  - `Git/`: Git repository interactions
  - `Shell/`: Command execution utilities
  - `Models/`: Data models and error definitions

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
MIT License
