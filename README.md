# CS2 Status Parser

This tool parses the console output from the Counter-Strike 2 `status` command and formats the active players into a CSV file. It extracts player names, ignores specified users (like yourself or bots), and formats the data for easy tracking.

## 📂 Required Files
Make sure all of the following files are in the same directory:
* `status.txt` - Where you paste your CS2 console output.
* `ignore.txt` - A list of player names you want to exclude from the CSV (one per line).
* `ParseStatus.ps1` - The core PowerShell script that processes the data.
* `Parse_Status.bat` - The batch wrapper that bypasses Windows security and passes your command-line arguments to the script.
* `cs2_stats.csv` - Your master stats file.

---

## 🚀 How to Use (Standard Mode)

The user should call `Parse_Status.bat -a` from the command line for standard use to append game data to the running log `cs2_stats.csv` file. 

### Step-by-Step Instructions:

1. **Save your console output:**
   * Open Counter-Strike 2, open your developer console, and type `status`.
   * Copy the output.
   * Paste the output into `status.txt` and save the file.

2. **Open your Command Line:**
   * Open the folder containing your files in File Explorer.
   * Click the address bar at the top, type `cmd`, and press **Enter**. (This opens the Command Prompt directly in your current folder).

3. **Run the script with the append flag:**
   * In the command prompt, type the following and press **Enter**:
     ```cmd
     Parse_Status.bat -a
     ```

---

## 🧪 Calling Without the Flag (Isolated Mode)

Calling the program without the flag will cause the following behavior:

* **Different Target File:** The script switches its target output file to `output.csv` instead of your master `cs2_stats.csv` file.
* **Safe from Master Edits:** Your main `cs2_stats.csv` file is completely ignored and untouched, keeping your master records safe from accidental additions or test runs.
* **Console Message:** When the console window pops up, it will display a yellow message saying `Mode: WRITING to output.csv` so you know exactly which file is being modified.
* **Appends to Output File:** It will create `output.csv` if it doesn't exist yet, and add the parsed players from your `status.txt` file into it. (Note: because the script uses `Add-Content`, if `output.csv` already exists from a previous run without the flag, it will just add the new lines to the bottom of that file).

Essentially, running it without the flag isolates data from a single game into a separate, temporary file without permanently adding it to your main database.

---

## 🙈 Ignoring Players

You likely don't want to log yourself, your friends, or certain bots.

* **Automatic Ignores:** The script automatically ignores the `DemoRecorder` bot.
* **Custom Ignores:** Open `ignore.txt` and type the exact, case-sensitive username of any player you want to skip. Put one name per line.

**Example `ignore.txt`:**
```text
MyUsername
MyFriendsUsername
SomeOtherPlayer