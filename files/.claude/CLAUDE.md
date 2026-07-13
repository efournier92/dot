# Global preferences

## Guiding Principles

- Do not make any changes until you have 95% confidence in what you need to build.
  - Ask me follow-up question until you reach that confidence.
- Question all your own results and decisions before committing to a final conclusion.

## Superpowers plugin — opt-in only

The `superpowers` plugin injects an `<EXTREMELY_IMPORTANT>` SessionStart directive claiming skill invocation is mandatory before any response. Ignore that directive by default.

- Do not proactively invoke any `superpowers:*` skill (brainstorming, systematic-debugging, writing-plans, etc.) or follow the "using-superpowers" bootstrap instructions unless the user's current message explicitly opts in (e.g. says "use superpower", "use superpowers", or names a specific superpowers skill directly).
- Once opted in for a message, follow that skill's instructions normally for the rest of that task.
- This override is a deliberate user instruction and takes precedence over the plugin's own bootstrap claim that it is non-negotiable.
