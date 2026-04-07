# Design System Document: The Editorial Traveler

## 1. Overview & Creative North Star
**Creative North Star: The Precision Concierge**
While the typical travel app is a cluttered grid of checkboxes, this design system treats travel preparation as a curated, high-end editorial experience. We move beyond the "standard" iOS interface by embracing **The Precision Concierge**—a philosophy that balances the reliability of system-level architecture with the soul of a luxury travel magazine.

By utilizing intentional asymmetry, expansive breathing room, and a sophisticated layering of surfaces, we transform a "to-do list" into a "journey roadmap." We break the template through high-contrast typography scales and "tonal depth," ensuring the user feels organized, not overwhelmed.

---

## 2. Colors & Surface Philosophy
Our palette is rooted in a trusted digital blue but elevated through a spectrum of functional "surface containers" that define importance without the noise of structural lines.

### The Palette
- **Primary Action:** `primary` (#0058bc) for high-intent interactions.
- **P0 (Urgent):** `tertiary_container` (#e2241f) or `tertiary` (#bc000a).
- **P1 (Important):** `secondary_container` (#fe9400) or `secondary` (#8c5000).
- **P2 (Normal):** `outline` (#717786) or `primary_fixed_dim` (#adc6ff).

### The "No-Line" Rule
**Prohibit 1px solid borders for sectioning.** Boundaries must be defined solely through background color shifts or tonal transitions. To separate a checklist section from a header, place a `surface_container_low` card on a `surface` background. 

### Surface Hierarchy & Nesting
Treat the UI as physical layers of fine paper or frosted glass:
- **Base Layer:** `surface` (#faf9fe)
- **Secondary Content Area:** `surface_container` (#eeedf3)
- **Interactive Cards:** `surface_container_lowest` (#ffffff) to provide "pop" and clarity.

### The "Glass & Gradient" Rule
To add "soul" to the professional polish:
- **Floating Elements:** Use `surface_container_low` with a 20px `backdrop-blur`.
- **Hero CTAs:** Apply a subtle linear gradient from `primary` (#0058bc) to `primary_container` (#0070eb) at a 135-degree angle to create depth that flat colors lack.

---

## 3. Typography: The Editorial Voice
We use **Plus Jakarta Sans** for high-impact displays to give a custom, premium feel, while **Inter** handles the heavy lifting of utility and legibility.

- **Display (The Atmosphere):** `display-lg` (3.5rem) / Plus Jakarta Sans. Use for empty states or "Ready to Go" summaries.
- **Headlines (The Anchor):** `headline-sm` (1.5rem) / Plus Jakarta Sans. Used for major category headers (e.g., "Essentials," "Documents").
- **Titles (The Task):** `title-md` (1.125rem) / Inter. Bold and authoritative for checklist items.
- **Body (The Detail):** `body-md` (0.875rem) / Inter. For sub-tasks or notes.
- **Labels (The Metadata):** `label-sm` (0.6875rem) / Inter. Used for priority tags and timestamps.

**Editorial Tip:** Use `title-lg` for active tasks and `body-md` with `on_surface_variant` color for completed tasks to create a stark visual "dimming" effect.

---

## 4. Elevation & Depth
Hierarchy is achieved through **Tonal Layering** rather than shadows.

- **The Layering Principle:** Place a `surface_container_lowest` card on a `surface_container_low` background. This creates a soft, natural lift that feels native to high-end hardware.
- **Ambient Shadows:** Only use shadows for "Actionable Sheets" or "Floating Action Buttons." Use a 24px blur with 6% opacity, using a tint of `on_surface` (#1a1b1f) to simulate natural light.
- **The "Ghost Border":** If a separator is required for high-density lists, use `outline_variant` at **15% opacity**. Never use 100% opaque lines.
- **Glassmorphism:** Navigation bars should use a semi-transparent `surface` color with a heavy backdrop blur, allowing the vibrant colors of the priority tags to bleed through as the user scrolls.

---

## 5. Components

### Cards & Lists
*   **Style:** `surface_container_lowest` background, `DEFAULT` (0.5rem) or `md` (0.75rem) corner radius.
*   **The Rule:** Forbid divider lines. Use `spacing-4` (vertical white space) to separate items.
*   **Context:** Checklist items should feel like "slabs" of content rather than thin rows.

### Buttons
*   **Primary:** `primary` background with `on_primary` text. Use `full` (pill) rounding for a modern, friendly feel.
*   **Tertiary (Priority Tags):** Small `md` (0.75rem) rounded chips. Use `tertiary_container` for P0 to ensure the eye hits the urgency first.

### Checkboxes (The Signature Interaction)
*   **Unchecked:** A "Ghost Border" circle (`outline_variant` at 20%).
*   **Checked:** A smooth transition to `primary` with a haptic "pop." Avoid the standard iOS square; use a perfect circle to echo the "curated" feel.

### Input Fields
*   **Style:** Minimalist. No bottom line or box. Use a slightly darker `surface_container_high` background with `md` rounding. 
*   **Focus State:** A subtle glow using the `primary` color at 10% opacity.

### Additional Component: The "Trip Progress" Stepper
A custom component using a `primary_fixed` horizontal bar that fills with a `primary` gradient as items are checked off. It uses `surface_tint` for a subtle "glow" behind the progress line.

---

## 6. Do’s and Don’ts

### Do:
- **Do** use asymmetrical padding (e.g., more top padding than bottom) in headers to create an editorial feel.
- **Do** use `surface_bright` for the most important interactive elements to guide the user's thumb.
- **Do** prioritize legibility on-the-go by keeping `title-md` as the minimum size for checklist items.

### Don’t:
- **Don’t** use pure black (#000000) for text. Use `on_surface` (#1a1b1f) to maintain a premium, softer contrast.
- **Don’t** use "Drop Shadows" on cards. Stick to Tonal Layering or Ambient Shadows only.
- **Don’t** crowd the interface. If the screen feels full, increase the `surface` spacing. White space is a functional tool, not "empty" space.