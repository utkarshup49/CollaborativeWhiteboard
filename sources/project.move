module MyModule::CollaborativeWhiteboard {

    use aptos_framework::event;
    use aptos_framework::signer;
    use std::vector;


    #[event] 
    struct Whiteboard has store, key, drop {
        content: vector<u8>,
    }

    #[event] 
    struct WhiteboardV2 has store, key, drop {
        content: vector<u8>,
        owner: address  // Added for ownership verification
    }

    /// Initialize the original whiteboard with content
    public entry fun initialize(owner: &signer, initial_content: vector<u8>) {
        let whiteboard = Whiteboard {
            content: initial_content,
        };
        move_to(owner, whiteboard);
    }

    /// Migrate old Whiteboard data to the new WhiteboardV2 structure
    public entry fun migrate_to_v2(owner: &signer) acquires Whiteboard {
        let old_whiteboard = borrow_global<Whiteboard>(signer::address_of(owner));
        let new_whiteboard = WhiteboardV2 {
            content: old_whiteboard.content,
            owner: signer::address_of(owner)
        };
        move_to(owner, new_whiteboard);
    }

    /// Update content in the new WhiteboardV2 structure
    public entry fun update_content(_updater: &signer, owner_address: address, new_content: vector<u8>) acquires WhiteboardV2 {
        let whiteboard = borrow_global_mut<WhiteboardV2>(owner_address);
        assert!(signer::address_of(_updater) == whiteboard.owner, 1001);
        assert!(vector::length(&new_content) <= 1024, 1002); // Limit content size for safety
        whiteboard.content = new_content;

        let updated_whiteboard = WhiteboardV2 {
            content: whiteboard.content,
            owner: whiteboard.owner
        };
        event::emit<WhiteboardV2>(updated_whiteboard);
    }
}
