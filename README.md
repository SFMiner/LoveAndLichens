# Love & Lichens

## About the Game
Love & Lichens is an indie computer RPG that explores relationships and whimsical magical-realism adventures of students at a school of environmental science. The game is inspired by the State University of New York College of Environmental Science and Forestry and blends scientific themes with magical elements.

## Key Features
- Engaging dialog system with branching conversations
- Inventory management for collected items and specimens
- Character interactions influenced by player choices
- Exploration of a magical forest ecosystem
- Educational elements related to environmental science, mycology, and entomology

## Technical Details
- Developed using Godot 4.3
- Custom dialog system with support for branching narratives
- Dynamic inventory system

## Project Structure
```
res://
├── scenes/
│   ├── Main.tscn
│   ├── Player.tscn
│   ├── NPC.tscn
│   └── Dialog UI.tscn
├── scripts/
│   ├── Player.gd
│   ├── NPC.gd
│   ├── DialogManager.gd
│   ├── DialogUI.gd
│   └── Item.gd
├── dialogs/
│   └── sample_dialog.dialog
└── textures/
	└── inventory_slot.png
```

## Setup and Running
1. Ensure you have Godot 4.3 installed
2. Clone this repository
3. Open the project in Godot
4. Run the main scene

## Dialog System
The game features a custom dialog system that supports:
- Branching conversations
- Character-specific dialogs
- Conditional responses
- In-dialog actions

Dialog files use a custom `.dialog` format. See `dialogs/sample_dialog.dialog` for an example.

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
[Your chosen license here]

## Contact
[Your contact information or method for people to reach out with questions]
