# 🎨 Fan Page Gallery

A carousel-style gallery walk viewer for e3python student submissions.

## About This Project

This is an interactive gallery viewer that displays student work from GitHub Classroom assignments. Select a module, then navigate through student submissions one at a time using the carousel controls.

### The Raw HTML Challenge

You might notice that the student projects in this gallery look... simple. There are no colors, no fancy layouts, and no photos. **This is by design.**

Before an architect picks the paint color, they must pour the concrete foundation. In this unit, students were challenged to build "Fan Pages" using strictly **Semantic HTML**. They were forbidden from using CSS styles to ensure they mastered the hierarchy of information first.

### Engineering Constraints

Every page in this gallery was built under strict conditions:

- **🚫 No CSS Allowed** - Students could not use colors, fonts, or alignment tools
- **🚫 No Image Files** - Creative text placeholders indicate where media belongs
- **✅ Semantic Tags Only** - Code is readable by machines and humans
- **✅ Code Hygiene** - Every section documented with HTML comments

### The Toolbox

Students built these experiences using only these 4 foundational elements:
- `<h1>` Headers
- `<p>` Paragraphs
- `<ul>` Lists
- `<!-- -->` Comments

---

## Features

- 📚 **Module Selection** - Choose between Mod 2, Mod 3, or Mod 5
- ⏪ **Carousel Navigation** - Browse through student submissions with prev/next buttons
- ⌨️ **Keyboard Controls** - Use arrow keys (← →) to navigate
- 🔄 **Auto-Discovery** - Automatically finds all student repos for the selected module
- 📊 **Position Counter** - See which submission you're viewing (e.g., "3 of 12")

## Usage

1. Open the gallery at [e3python.github.io/fan-page-gallery](https://e3python.github.io/fan-page-gallery)
2. Select a module from the dropdown
3. Use the navigation buttons or arrow keys to browse student work
4. Each student's `index.html` is displayed in an iframe

## Modules

- **Mod 2** - Assignment ID: 933724
- **Mod 3** - Assignment ID: 933725
- **Mod 5** - Assignment ID: 933728

## How It Works

The gallery automatically discovers student repositories by:
1. Querying the GitHub API for repos in the e3python organization
2. Filtering by module prefix (e.g., `mod2-*`, `mod3-*`, `mod5-*`)
3. Fetching the `index.html` from each repo's `main` branch
4. Displaying them in an iframe carousel

## Built With

- Vanilla JavaScript (no dependencies)
- GitHub API
- GitHub Pages

---

**Intro to Computer Science • Unit 2: HTML & The Internet**  
*"Structure before Style"*
