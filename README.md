# 🧩 SokoRun

**SokoRun** is an AI-powered Sokoban puzzle game developed as part of the *Artificial Intelligence Mini Project* at **Universitas Gadjah Mada**.  
In this game, players must push boxes to their goal positions while avoiding an enemy entity that intelligently **chases and blocks their path**.  
The enemy uses the **A\*** algorithm to pursue the player dynamically, while a **Breadth-First Search (BFS)** system provides hints to find the **nearest reachable box**, helping players plan efficient routes.  
Built with **Godot Engine (GDScript)**, SokoRun blends puzzle-solving and pathfinding AI, demonstrating how classic algorithms like A\* and BFS can create engaging real-time gameplay experiences.

---

## 🎮 Game Overview

### 🧠 Core AI Implementations
- **A\* Algorithm (Enemy AI):**  
  The enemy continuously scans the grid using A\* pathfinding to detect and chase the player efficiently, updating its route as the player moves or obstacles appear.

- **BFS Algorithm (Hint System):**  
  The player can trigger a BFS-based hint that highlights the nearest box they can reach, aiding in strategic puzzle-solving under time pressure.

---

## ⚙️ Features
- 🧩 Classic **Sokoban mechanics**: push boxes to goal tiles.
- 👾 **Chase mode**: an AI entity follows the player intelligently.
- 💡 **Hint system**: visualize reachable boxes using BFS.
- 🌐 **Grid-based environment** with A\* pathfinding.
- 🎓 Created for **AI learning and experimentation** at UGM.

---

## 🏗️ Tech Stack
| Component | Description |
|------------|--------------|
| **Engine** | Godot Engine 4.5.1 |
| **Language** | GDScript |
| **AI Algorithms** | A\* Pathfinding, BFS Search |
| **Project Type** | Academic / AI Demonstration |
| **Institution** | Universitas Gadjah Mada |

---

## 🚀 How to Play
1. **Move:** Use `WASD` or arrow keys to move the player.  
2. **Objective:** Push all boxes onto the goal tiles to complete the level.  
3. **Avoid:** The enemy entity will chase you — don’t let it catch you!  
4. **Hint:** Press the hint key (or button) to see which box is closest and accessible.  
5. **Win:** All boxes must be placed correctly before being caught!

---

## 🧩 Folder Structure
SokoRun/
├── scenes/ # Godot scene files (.tscn)
├── scripts/ # GDScript files for player, enemy, logic
├── ai/ # A* and BFS algorithm scripts
├── assets/ # Sprites, textures, sounds
├── docs/ # Reports or presentation materials
├── project.godot # Main Godot project file
├── README.md
├── LICENSE
└── .gitignore


---

## 🧑‍💻 Developers

**SokoRun** was developed collaboratively as part of the *Artificial Intelligence Mini Project (2025)* at **Universitas Gadjah Mada (UGM)**.

### 👥 Team Members
- **Excel Fathan Breviano** – Game Logic & AI Implementation (A* & BFS)
- **Muhammad Athallah Yakarazi** – Game Logic & AI Implementation (A* & BFS)
- **Hafizh Abel Kautsar** – Game Design & Visual Assets  
- **Muhamad Harfi Ibadurahman** – Sound Design & Audio Integration    
- **M Rafi Praditya Suryapraja** – Testing & Optimization  

> Bachelor of Computer Science, Universitas Gadjah Mada (UGM)


---

## 📜 License
This project is licensed under the **MIT License**.  
You are free to **use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies** of this software, provided that proper credit is given to the original author.  
For more details, see the full text in the [LICENSE](LICENSE) file.


