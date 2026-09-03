# IT Job Search App 🚀

A comprehensive, full-stack mobile application designed to connect IT professionals with their next career opportunities. This project features a robust Flutter frontend and a scalable NestJS backend, showcasing modern development practices, real-time communication, and responsive UI design.

## 🌟 Features

*   **User Authentication & Authorization**: Secure login and registration using JWT.
*   **Job Discovery & Search**: Browse and filter IT job postings efficiently.
*   **Real-time Interactions**: Live chat and instant updates powered by Socket.IO.
*   **Push Notifications**: Timely alerts for job applications and messages via OneSignal.
*   **Resume/CV Management**: Upload, view (built-in PDF viewer), and manage CVs seamlessly with Supabase storage integration.
*   **Data Visualization**: Interactive charts and analytics using Syncfusion.
*   **Background Processing**: Robust background job handling using BullMQ and Redis for tasks like email notifications.

## 🛠️ Technology Stack

### Frontend (`/ui`)
*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **State Management**: Provider
*   **Networking**: Dio
*   **Real-time**: Socket.IO Client
*   **Notifications**: OneSignal
*   **UI Components & Utilities**: Syncfusion Charts & PDF Viewer, DropdownButton2, Flutter Slidable.

### Backend (`/be`)
*   **Framework**: [NestJS](https://nestjs.com/) (Node.js/TypeScript)
*   **Database & ORM**: [Prisma](https://www.prisma.io/) (PostgreSQL)
*   **Message Queue**: BullMQ & Redis
*   **Storage & Services**: Supabase
*   **Real-time**: WebSockets (Socket.IO)
*   **Utilities**: Nodemailer, PDFKit, ExcelJS

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your local machine:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.7.0 or higher)
*   [Node.js](https://nodejs.org/) (v18 or higher)
*   [Redis](https://redis.io/) (for BullMQ background queues)
*   PostgreSQL Database

### Backend Setup (`/be`)

1. Navigate to the backend directory:
   ```bash
   cd be
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables: 
   * Create a `.env` file in the `/be` folder.
   * Add your configuration variables (e.g., `DATABASE_URL`, `REDIS_URL`, `SUPABASE_KEY`, `JWT_SECRET`).
4. Run database migrations and apply schema:
   ```bash
   npm run db:migrate
   ```
5. Start the development server:
   ```bash
   npm run start:dev
   ```

### Frontend Setup (`/ui`)

1. Navigate to the frontend directory:
   ```bash
   cd ui
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Set up environment variables:
   * Create a `.env` file in the `/ui` folder.
   * Add your API endpoints and keys (e.g., OneSignal App ID).
4. Run the app on an emulator or physical device:
   ```bash
   flutter run
   ```

## 📸 Screenshots

> **Note to developer**: Replace this section with actual screenshots of your app (e.g., Login Screen, Home/Job List, Chat Screen, Profile) to make your portfolio highly impressive to recruiters.

<p align="center">
  <img src="https://via.placeholder.com/250x500.png?text=Home+Screen" width="250" />
  <img src="https://via.placeholder.com/250x500.png?text=Job+Detail" width="250" />
  <img src="https://via.placeholder.com/250x500.png?text=Chat/Messages" width="250" />
</p>

## 💡 Architecture & Design Patterns

*   **Modular Monolith (Backend)**: The NestJS backend is structured into distinct feature modules, ensuring clear separation of concerns and maintainability.
*   **Reactive UI (Frontend)**: Utilizing Flutter's `Provider` for clean state management, keeping the UI perfectly in sync with the underlying data.
*   **Asynchronous Processing**: Heavy tasks like document generation (PDFs, Excel) and email sending are offloaded to BullMQ workers to keep the API highly responsive.

## 👨‍💻 Author

**Tuan Anh**

- 📧 Email: [nguyenbatuananh2k5@gmail.com]
- 🐙 GitHub: [@anhnbt05](https://github.com/anhnbt05)

---
