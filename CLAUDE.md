# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS SwiftUI app called "Inky" (formerly AnimatedCaligraphy/HandWriting) that creates animated handwriting videos. The app allows users to:
- Browse and explore inspirational quotes with different typography styles
- Create animated handwriting videos from text
- Save videos to photo library
- Customize text appearance (font size, colors, alignment, background images)

## Build and Development

### Building the App
```bash
# Open project in Xcode
open Inky.xcodeproj

# Build from command line (if needed)
xcodebuild -project Inky.xcodeproj -scheme Inky -configuration Debug build
```

### Key Dependencies
- Firebase (Analytics, Firestore, Auth, Storage, etc.) - for backend services and analytics
- SwiftUI - primary UI framework
- AVFoundation - for video creation and management
- Custom font: LeckerliOne-Regular.ttf

## Architecture

### Core Components
- **AnimatedCaligraphyApp.swift**: Main app entry point with Firebase configuration
- **Model**: Shared observable model that manages quotes data via `QuotesService`
- **ContentView**: Main navigation with TabView (Explore, Favorites tabs)
- **EditorView**: Core video creation interface with text customization
- **MultiImageSequence**: Handles animated text rendering frame by frame

### Key Data Models
- **Stylo**: Main text style model (text, size, colors, alignment, background image)
- **EditStylo**: Observable editing state for the editor
- **Quote**: Firebase document model for fetching quotes
- **Letter**: Individual character positioning for animation
- **VideoModel**: Manages video creation and export

### Manager Classes
- **QuotesService**: Firebase Firestore integration for quotes
- **VideoManager**: Video creation and export functionality  
- **PhotoLibraryManager**: Photo library access and saving
- **TextEditorWithCharacterPositions**: Custom text editor that tracks character positions for animation

### Directory Structure
- `AnimatedCaligraphy/`: Main source code
  - `views/`: SwiftUI views (ContentView, EditorView, Favorites, etc.)
  - `Manager/`: Business logic and utility classes
  - `Assets.xcassets/`: Large collection of background images organized by categories (numbered sequences)
  - `font/`: Custom typography assets

### Firebase Integration
- Uses Firestore collection "FirstCollection" for quotes data
- Analytics tracking for app usage
- Requires GoogleService-Info.plist configuration (archived version exists)

### Video Creation Pipeline
1. Text input via TextEditorWithCharacterPositions
2. Character position tracking for animation
3. Frame-by-frame rendering via MultiImageSequence
4. Video compilation and export via VideoManager
5. Save to photo library via PhotoLibraryManager

## Development Notes

### Custom Text Rendering
- Uses LeckerliOne-Regular font throughout
- Character-by-character position tracking for animation
- Custom text editor with reduced line spacing and disabled smart features

### Asset Organization
- Background images organized in numbered sequences (0000001-9990016, AA0001-EE0017, etc.)
- Each image has corresponding imageset in Assets.xcassets

### Network Dependency
- App checks network connectivity and shows NetworkUnavailableView when offline
- Firebase operations require network access