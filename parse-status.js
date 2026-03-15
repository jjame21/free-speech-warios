const fs = require('fs');

/**
 * Parses CS2 'status' output to CSV lines.
 * Headers: game,match,steam_id,name,on_team,slur,n-word,politics,notes
 */

function parseStatus(input) {
    // Regex identifies active players and captures the name inside single quotes
    // It skips rows marked as 'challenging' or '[NoChan]'
    const playerPattern = /\[Client\]\s+\d+\s+[\d:BOT]+\s+\d+\s+\d+\s+active\s+\d+\s+'(.*?)'/g;
    
    let match;
    while ((match = playerPattern.exec(input)) !== null) {
        const playerName = match[1];

        // Column mapping based on your CSV:
        const game = "cs2";
        const matchId = "";      // Left unfilled as requested
        const steamId = "";      // Steam ID isn't in this part of the console log
        const name = `"${playerName.replace(/"/g, '""')}"`; // Wrap in quotes for CSV safety
        
        // Construct the line with 5 trailing commas for the remaining empty fields:
        // on_team, slur, n-word, politics, notes
        console.log(`${game},${matchId},${steamId},${name},,,,,`);
    }
}

// Read from file passed as argument
const filePath = process.argv[2];

if (filePath) {
    try {
        const content = fs.readFileSync(filePath, 'utf-8');
        parseStatus(content);
    } catch (err) {
        console.error(`Error reading file: ${err.message}`);
    }
} else {
    console.error("Usage: node parse_status.js status.txt");
}