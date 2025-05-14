# README.md

# 🧠 Flutter MCP Client

Welcome to the Flutter MCP Client — a Claude AI desktop interface built with Flutter, following Clean Architecture principles and powered by a modular monorepo using Melos. This application demonstrates the implementation of the Message Communication Protocol (MCP) for rich AI-driven interactions.

## 📹 YouTube Demo

[https://www.youtube.com/watch?v=bdy2mi7S5Nk](https://www.youtube.com/watch?v=bdy2mi7S5Nk)

## 🧰 Features

- 🖥️ Desktop-first Flutter app (Windows, macOS, Linux)
- 🧼 Clean Architecture with modular monorepo
- 📦 State management using Flutter Bloc
- 🔌 MCP client/server implementation for interacting with Claude and other LLMs
- 💬 Chat interface with real-time stream updates
- ⚙️ Add, edit, and manage MCP servers
- 🧠 Built-in AI and function-calling support
- 🎨 Custom widgets and clean UI

## 📁 Project Structure

This repository is organized using the monorepo approach with Melos:

```
apps/               # Main Flutter applications
external/           # External SDKs or libraries (e.g., LLM Kit)
packages/           # Feature-specific packages (Clean Architecture layers)

```

### Key Layers

- `flutter_mcp_entities`: Data models for AI, Chat, and MCP
- `flutter_mcp_datasources`: Local and remote data handling
- `flutter_mcp_repositories`: Repositories for dependency injection
- `flutter_mcp_usecases`: Use cases implementing core logic
- `flutter_mcp_state`: BLoC/Cubit state management
- `flutter_mcp_widgets`: Custom reusable UI components

## 🚀 Getting Started

### Prerequisites

Ensure the following tools are installed:

- Flutter SDK
- Dart SDK
- Melos (Monorepo manager):

    ```bash
    dart pub global activate melos
    
    ```


### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/flutter_mcp.git
cd flutter_mcp

# Bootstrap all packages
melos bootstrap

```

### Run the App

```bash
# Navigate to app directory
cd apps/flutter_mcp

# Launch for your platform
flutter run -d windows
flutter run -d macos
flutter run -d linux

```

## 🧪 Running Tests

```bash
melos run test

```

## 🔍 Packages Overview

Each package in `packages/` encapsulates a specific layer or feature:

| Package | Description |
| --- | --- |
| `flutter_mcp_entities` | Domain models and entities |
| `flutter_mcp_datasources` | Local persistence and data sources |
| `flutter_mcp_repositories` | Abstraction layer for domain repositories |
| `flutter_mcp_usecases` | Business logic and user interactions |
| `flutter_mcp_state` | Cubit/Bloc-based state management |
| `flutter_mcp_widgets` | Custom UI components |

## 🎨 UI & UX

- Utilizes fonts like Copernicus and StyreneB
- Responsive layouts and custom theming
- Reusable form fields, chat bubbles, connection indicators

## 📡 MCP Protocol Support

This app implements an MCP (Message Communication Protocol) client, enabling AI interactions through structured messages, tool calling, and content embedding.

Supported features include:

- Streaming chat updates
- Tool registration and invocation
- Embedded content handling (text, images, resources)
- Connection lifecycle management

## 🤝 Contributing

We welcome contributions! To get started:

```bash
melos bootstrap
melos run analyze
```

Please submit issues or pull requests on GitHub.

## 📜 License

MIT License