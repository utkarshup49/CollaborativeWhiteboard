module MyModule::CollaborativeWhiteboard {

    use aptos_framework::event;

    #[event] // Added event attribute for proper event emission
    struct Whiteboard has store, key, drop {
        content: vector<u8>, // The whiteboard content stored as bytes (could be JSON, text, etc.)
    }

    /// Function to initialize the whiteboard with default content.
    public fun initialize(owner: &signer, initial_content: vector<u8>) {
        let whiteboard = Whiteboard {
            content: initial_content,
        };
        move_to(owner, whiteboard);
    }

    /// Function to update the whiteboard content collaboratively.
    public fun update_content(_updater: &signer, owner_address: address, new_content: vector<u8>) acquires Whiteboard {
        let whiteboard = borrow_global_mut<Whiteboard>(owner_address);
        whiteboard.content = new_content;

        // Emit an event with the updated content
        let updated_whiteboard = Whiteboard {
            content: whiteboard.content
        };
        event::emit<Whiteboard>(updated_whiteboard);
    }
}
