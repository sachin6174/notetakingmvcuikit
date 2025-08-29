//
//  ViewController.swift
//  notetakingmvcuikit
//
//  MAIN VIEW CONTROLLER - MVC Architecture Entry Point
//
//  This demonstrates how to set up the initial MVC structure
//  and launch the notes app with proper architecture
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - MVC Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBeautifulWelcomeScreen()
    }
    
    // MARK: - UI Setup
    private func setupBeautifulWelcomeScreen() {
        // Add beautiful gradient background
        DispatchQueue.main.async {
            self.view.addGradientBackground(
                colors: [
                    DesignSystem.Colors.gradientStart,
                    DesignSystem.Colors.gradientEnd
                ],
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 1, y: 1)
            )
        }
        
        // Find and style the Get Started button
        if let button = view.subviews.first(where: { $0 is UIButton }) as? UIButton {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                button.applyPrimaryStyle()
                button.bounceIn()
            }
        }
        
        // Add entrance animations to all elements
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.animateWelcomeElements()
        }
    }
    
    private func animateWelcomeElements() {
        // Animate stack view elements
        if let stackView = view.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            for (index, subview) in stackView.arrangedSubviews.enumerated() {
                subview.slideInFromBottom(delay: Double(index) * 0.1)
            }
        }
    }
    
    // MARK: - User Actions
    @IBAction func getStartedTapped(_ sender: UIButton) {
        // Add button press animation
        sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = .identity
        }) { _ in
            self.setupMVCArchitecture()
        }
    }
    
    // MARK: - MVC Architecture Setup
    private func setupMVCArchitecture() {
        // This method demonstrates how to properly initialize MVC components
        
        // 1. Create the main notes list view controller from storyboard (VIEW)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let notesListVC = storyboard.instantiateViewController(withIdentifier: "NotesListViewController") as? NotesListViewController else {
            print("❌ Failed to load NotesListViewController from storyboard")
            return
        }
        
        // 2. Embed in navigation controller for proper navigation flow
        let navigationController = UINavigationController(rootViewController: notesListVC)
        
        // 3. Present the MVC-structured interface
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true) {
            print("🚀 MVC Notes App launched successfully!")
            self.printMVCExplanation()
        }
    }
    
    // MARK: - Educational Content
    private func printMVCExplanation() {
        print("""
        
        📚 MVC ARCHITECTURE EXPLANATION:
        ================================
        
        🏗️ MODEL (Note.swift, NoteDataManager):
        - Manages all data and business logic
        - Defines what a Note IS (properties, structure)
        - Handles CRUD operations (Create, Read, Update, Delete)
        - Independent of UI - doesn't know about views
        
        👀 VIEW (NotesListViewController, NoteDetailViewController):
        - Handles all user interface elements
        - Displays data to the user
        - Captures user interactions (taps, text input)
        - "Dumb" - contains no business logic
        - Communicates with Controller, never directly with Model
        
        🎮 CONTROLLER (NotesController):
        - Acts as mediator between Model and View
        - Processes user actions from View
        - Fetches/modifies data through Model
        - Updates View when data changes
        - Contains application logic and flow control
        
        🔄 COMMUNICATION FLOW:
        User Action → View → Controller → Model → Controller → View → UI Update
        
        ✅ BENEFITS OF MVC:
        - Separation of concerns
        - Easier testing and maintenance
        - Reusable components
        - Clear responsibilities
        - Scalable architecture
        
        """)
    }
}

