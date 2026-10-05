---
layout: standalone
title: "Claude Code and Final Cut Pro"
permalink: /fcp/
---

<div class="fcp-page" markdown="1">


This page has two artifacts you can adapt for your own use of [Claude Code](https://www.anthropic.com/claude-code) with [Final Cut Pro](https://www.apple.com/final-cut-pro/) (FCP): a starting `CLAUDE.md` that introduces you and your media to Claude, and a prompt that has Claude build a skill for controlling FCP.

The skill relies mostly on the macOS Accessibility API, which lets Claude read FCP's timeline, viewer, inspector, and menus as text in about a second, and on FCPXML, FCP's interchange format, for bulk edits such as titles, freeze frames, and audio. Screenshots are a fallback. This combination is faster, cheaper, and more reliable than having Claude look at the screen and click.

## 1. A starting CLAUDE.md

`CLAUDE.md` is the file Claude Code reads at the start of every session. Put it at the root of the folder where you run Claude for video work, and replace the `<…>` placeholders.

```markdown
# Video projects with Final Cut Pro

This project is for making videos in Final Cut Pro (FCP) with Claude Code.

## About me
I'm <name>, a <profession> and hobbyist <videographer/editor>. I've used FCP since <year> (<what you've made>). Assume I know FCP basics but not FCPXML internals. Ask before anything destructive; otherwise just do it and tell me what you did.

## My setup
- Mac: <model>, <Intel / Apple Silicon>, macOS <version>; FCP <version>.
- FCP libraries (.fcpbundle) live in `<~/Movies/>`. Example: `<~/Movies/Running_2026.fcpbundle>`.
- Raw media lives in `<~/videoMedia/>`, one folder per shoot, e.g. `<~/videoMedia/Running_2026/9-14/>`. Libraries reference media in place (not copied in).
- I use a custom keyboard command set. Read my shortcuts from FCP; don't assume the defaults.
- Saved effects presets I reuse: <e.g. "Dramatic Race - Video">.

## Rules
- FCP auto-saves every edit, so there is no undo-by-not-saving. Before big changes, offer Edit › Snapshot Project. Confirm with me before deleting events, projects, or media.
- Never modify my project in place for bulk work. Export XML, generate a new version, and import it as a NEW event, so mine stays as a backup.
- Check results visually (a frame from the viewer) before telling me something is done.

## Controlling FCP
Use the `final-cut-pro` skill (`.claude/skills/final-cut-pro/SKILL.md`). It reads FCP through the macOS Accessibility API (fast, cheap text) and edits in bulk via FCPXML. Use computer-use screenshots only as a fallback. When you learn something new about FCP, add it to the skill.

## Recurring projects
<e.g. "Race videos: follow RACE_VIDEOS.md. Only the date and the race change per video.">
```

## 2. A prompt for building the skill

Paste this into Claude Code from that same folder. It encodes pitfalls that took my session hours to discover, but Claude will still need to explore and test on your Mac, because FCP versions, screen sizes, and keyboard command sets differ.

```text
I want you to control Final Cut Pro on this Mac efficiently, mostly without screenshots. Build a project skill at .claude/skills/final-cut-pro/ for that, then test it on my open project without changing my edits.

1. Check access first. Use the computer-use MCP to confirm you can see FCP, and tell me if it isn't active. Then check whether this terminal process already has macOS Accessibility permission: try a read-only osascript call to System Events listing FCP's menu bar. If permission is missing, tell me exactly which app to enable in System Settings > Privacy & Security > Accessibility, and under Screen Recording.

2. Build a small compiled CLI (<programming language>) that talks to FCP's accessibility tree directly. AppleScript is far too slow for full-tree reads. Commands:
   - tree, find (by text or role), attrs, focused, hit X Y
   - press, set (values such as inspector fields), menu "Top>Item>Sub"
   - key and type (real keyboard events), click (real mouse events)
   - shot ELEMENT file.png (captures FCP's own window, cropped to one element)
   - timeline (a table of every clip: lane, kind, start, end, duration, name)
   - playhead

3. Watch out for these known pitfalls:
   - Menu titles and enabled states read through accessibility are stale until a menu is opened, so open the menu before choosing an item.
   - Clear modifier keys on typed text, or a "w" can become Cmd-W and close a dialog.
   - Keys go to whichever FCP pane has focus, so focus the timeline or browser first.
   - Timeline items far off-screen report no timecodes until you Zoom to Fit.
   - Paths of child indices change whenever the UI changes, so prefer finding elements by text.
   - Wait for a dialog to actually appear before sending keys.

4. Map FCP's accessibility tree (timeline, viewer, inspector, browser, dialogs) and read my real keyboard shortcuts from the active command set. Write it all into SKILL.md: a command cheat sheet, golden rules, recipes, and an accessibility map.

5. For bulk edits, prefer FCPXML: export my project, transform the XML, validate it against the DTD inside FCP's app bundle, and import it as a new event. Before trusting any visual parameter (shape sizes, text positioning, colors), render a throwaway calibration project and measure the result.

6. Safety:
   - Test only with non-destructive actions: playhead moves, selection, toggles you revert.
   - Verify every action by re-reading state.
   - Confirm with me before deleting anything.
   - Never type or click while I might be using the machine without telling me.

7. Point to the skill from CLAUDE.md, and keep adding what you learn to SKILL.md as we work.
```

## What the finished skill did for me

My session used accessibility for nearly all reading and control, screenshots only to confirm permissions and occasionally to inspect a dialog, single-element captures of the viewer for visual checks, and generated FCPXML for every bulk edit. From that base, Claude and I built a pipeline for similar videos:

- whisper.cpp turns the comments I speak while recording on my iPhone into FCP markers, which Claude Code then reads.
- A script assembles a rough cut for me to trim.
- A second script adds recurring video elements and recurring flourishes.

</div>
