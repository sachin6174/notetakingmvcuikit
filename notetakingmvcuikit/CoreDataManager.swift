//
//  CoreDataManager.swift
//  notetakingmvcuikit
//
//  CORE DATA MODEL LAYER - MVC Architecture with Persistence
//
//  This demonstrates how the MODEL layer in MVC can use Core Data
//  for persistent storage while maintaining proper architecture.
//  The Model layer handles all data operations and business logic,
//  completely independent of the View and Controller layers.
//

import Foundation
import CoreData
import UIKit

// MARK: - Core Data Manager (Enhanced Model Layer)
class CoreDataManager {
    
    // MARK: - Singleton Pattern
    static let shared = CoreDataManager()
    private init() {
        setupSampleDataIfNeeded()
    }
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "notetakingmvcuikit")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("❌ Core Data error: \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data loaded successfully")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("💾 Core Data saved successfully")
            } catch {
                let nsError = error as NSError
                print("❌ Core Data save error: \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD Operations (Model Layer Business Logic)
    
    /// CREATE: Add a new note to Core Data
    func createNote(title: String, content: String, category: String = "General") -> NoteEntity {
        let note = NoteEntity(context: context)
        note.id = UUID()
        note.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        note.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        note.category = category
        note.createdAt = Date()
        note.updatedAt = Date()
        note.isFavorite = false
        note.colorHex = generateRandomNoteColor()
        
        saveContext()
        
        print("📝 Created new note: '\(note.title ?? "Untitled")' with ID: \(note.id?.uuidString ?? "unknown")")
        return note
    }
    
    /// READ: Get all notes from Core Data
    func getAllNotes() -> [NoteEntity] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        // Sort by updated date (most recent first)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let notes = try context.fetch(request)
            print("📊 Fetched \(notes.count) notes from Core Data")
            return notes
        } catch {
            print("❌ Failed to fetch notes: \(error)")
            return []
        }
    }
    
    /// READ: Get notes by category
    func getNotes(byCategory category: String) -> [NoteEntity] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch notes by category: \(error)")
            return []
        }
    }
    
    /// READ: Search notes by title or content
    func searchNotes(query: String) -> [NoteEntity] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        let contentPredicate = NSPredicate(format: "content CONTAINS[cd] %@", query)
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
        
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to search notes: \(error)")
            return []
        }
    }
    
    /// READ: Get favorite notes
    func getFavoriteNotes() -> [NoteEntity] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch favorite notes: \(error)")
            return []
        }
    }
    
    /// UPDATE: Modify an existing note
    func updateNote(_ note: NoteEntity, title: String, content: String, category: String? = nil) -> Bool {
        note.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        note.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        note.updatedAt = Date()
        
        if let category = category {
            note.category = category
        }
        
        saveContext()
        
        print("✏️ Updated note: '\(note.title ?? "Untitled")' with ID: \(note.id?.uuidString ?? "unknown")")
        return true
    }
    
    /// UPDATE: Toggle favorite status
    func toggleFavorite(_ note: NoteEntity) {
        note.isFavorite.toggle()
        note.updatedAt = Date()
        saveContext()
        
        let status = note.isFavorite ? "added to" : "removed from"
        print("⭐ Note '\(note.title ?? "Untitled")' \(status) favorites")
    }
    
    /// DELETE: Remove a note from Core Data
    func deleteNote(_ note: NoteEntity) -> Bool {
        let title = note.title ?? "Untitled"
        context.delete(note)
        saveContext()
        
        print("🗑️ Deleted note: '\(title)'")
        return true
    }
    
    /// DELETE: Remove all notes (for testing purposes)
    func deleteAllNotes() {
        let request: NSFetchRequest<NSFetchRequestResult> = NoteEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
            print("🗑️ All notes deleted")
        } catch {
            print("❌ Failed to delete all notes: \(error)")
        }
    }
    
    // MARK: - Business Logic Helper Methods
    
    /// Generate a random color for notes
    private func generateRandomNoteColor() -> String {
        let colors = [
            "#FF6B6B", // Red
            "#4ECDC4", // Teal  
            "#45B7D1", // Blue
            "#96CEB4", // Green
            "#FFEAA7", // Yellow
            "#DDA0DD", // Plum
            "#F8C471", // Orange
            "#85C1E9", // Light Blue
            "#F1948A", // Light Red
            "#82E0AA"  // Light Green
        ]
        return colors.randomElement() ?? "#4ECDC4"
    }
    
    /// Get statistics about notes
    func getNoteStatistics() -> (total: Int, favorites: Int, categories: [String: Int]) {
        let allNotes = getAllNotes()
        let favoriteCount = allNotes.filter { $0.isFavorite }.count
        
        var categoryStats: [String: Int] = [:]
        for note in allNotes {
            let category = note.category ?? "General"
            categoryStats[category, default: 0] += 1
        }
        
        return (total: allNotes.count, favorites: favoriteCount, categories: categoryStats)
    }
    
    // MARK: - Sample Data
    private func setupSampleDataIfNeeded() {
        // Check if we already have notes
        let existingNotes = getAllNotes()
        if !existingNotes.isEmpty {
            return // Already have data
        }
        
        // Create sample notes to demonstrate the app
        let sampleNotes = [
            (
                title: "Welcome to Beautiful MVC Notes! 🎉",
                content: """
                Welcome to your beautiful notes app built with MVC architecture!
                
                🏗️ MODEL: Handles data with Core Data
                👀 VIEW: Beautiful, modern interface  
                🎮 CONTROLLER: Coordinates everything
                
                Key Features:
                • Create and edit notes
                • Categories and favorites
                • Search functionality
                • Beautiful design system
                • Persistent storage with Core Data
                
                Swipe left on any note to delete it!
                """,
                category: "Welcome"
            ),
            (
                title: "Understanding MVC Architecture 📚",
                content: """
                MVC (Model-View-Controller) is a fundamental design pattern:
                
                MODEL 🏗️
                • Manages data and business logic
                • In our app: Core Data entities and managers
                • Independent of UI
                
                VIEW 👀  
                • User interface components
                • Displays data and captures input
                • Storyboards, View Controllers, UI elements
                
                CONTROLLER 🎮
                • Mediates between Model and View
                • Handles user actions and app logic
                • Coordinates data flow
                
                This separation makes code more maintainable, testable, and scalable!
                """,
                category: "Education"
            ),
            (
                title: "Core Data Integration 💾",
                content: """
                This app demonstrates how to integrate Core Data into MVC:
                
                • NoteEntity: Core Data managed object (MODEL)
                • CoreDataManager: Handles persistence (MODEL)
                • View Controllers: Display data (VIEW)
                • NotesController: Coordinates operations (CONTROLLER)
                
                Benefits:
                ✅ Data persists between app launches
                ✅ Efficient querying and sorting
                ✅ Relationships between entities
                ✅ Migration support for updates
                
                All data operations go through the Model layer!
                """,
                category: "Technical"
            ),
            (
                title: "Design System Features 🎨",
                content: """
                Beautiful design elements include:
                
                🎨 Modern Design System
                • Custom color palette
                • Consistent typography
                • Spacing and layout guidelines
                
                ✨ Animations & Interactions  
                • Smooth transitions
                • Bounce animations
                • Button press feedback
                
                🎭 Visual Polish
                • Card-based layouts
                • Subtle shadows
                • Gradient backgrounds
                • Modern typography
                
                All styling is centralized in DesignSystem.swift!
                """,
                category: "Design"
            )
        ]
        
        // Create the sample notes
        for (title, content, category) in sampleNotes {
            _ = createNote(title: title, content: content, category: category)
        }
        
        print("🌟 Created sample notes for beautiful MVC demonstration")
    }
}