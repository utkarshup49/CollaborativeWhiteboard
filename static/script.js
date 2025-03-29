const CONTRACT_ADDRESS = '0x975c000ebcdb5a73388cacefe72422372ba57945d8b61ed5dad63aeaf894f68c';

async function connectWallet() {
    if (window.aptos) {
        try {
            const account = await window.aptos.connect();
            if (account && account.address) {
                alert(`Connected to Petra Wallet!\nAddress: ${account.address}`);
                document.getElementById('wallet-address').innerText = `Wallet Address: ${account.address}`;
                localStorage.setItem('wallet_address', account.address);
            } else {
                alert('Failed to retrieve account details.');
            }
        } catch (error) {
            alert(`Failed to connect wallet: ${error.message}`);
            console.error('Wallet Connection Error:', error);
        }
    } else {
        alert('Petra Wallet not detected. Please install it from the Chrome Web Store.');
    }
}

async function updateWhiteboard() {
    const content = document.getElementById('whiteboard').value.trim();

    if (!window.aptos) {
        alert('Please connect your Petra Wallet first.');
        return;
    }

    const walletAddress = localStorage.getItem('wallet_address');
    if (!walletAddress) {
        alert('Wallet not connected. Please connect first.');
        return;
    }

    try {
        const payload = {
            type: 'entry_function_payload',
            function: `${CONTRACT_ADDRESS}::CollaborativeWhiteboard::update_content`,
            type_arguments: [],
            arguments: [
                walletAddress,  // ✅ Now passing the walletAddress correctly as `updater`
                Array.from(new TextEncoder().encode(content))
            ]
        };

        const response = await window.aptos.signAndSubmitTransaction(payload);
        console.log('Transaction Response:', response);

        if (response && response.hash) {
            await fetch('/transaction_status', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ tx_hash: response.hash })
            });

            alert(`Whiteboard updated successfully! Transaction hash: ${response.hash}`);
        } else {
            alert('Transaction submission failed. Please try again.');
        }
    } catch (error) {
        console.error('Transaction Error:', error);

        const errorMessage = typeof error.message === 'string'
            ? error.message
            : JSON.stringify(error);

        if (errorMessage.includes('Simulation error')) {
            alert('Simulation error: Check your content for invalid characters or ensure your wallet has sufficient funds.');
        } else if (errorMessage.includes('User rejected')) {
            alert('Transaction rejected. Please approve the transaction in Petra Wallet.');
        } else {
            alert(`Failed to update whiteboard: ${errorMessage}`);
        }
    }
}
