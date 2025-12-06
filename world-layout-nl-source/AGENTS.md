# Agent Entry Point

Agents operating in this directory MUST:

1. Read **world-layout.txt**.
2. Follow the instructions in the header of world-layout.txt exactly.
3. Interpret human prompts ONLY according to the rules specified there.
4. Write changes ONLY to world-layout.txt.
5. Do NOT create, modify, or rely on any other files.

The layout file defines:
- the allowed tags,
- the meaning of phenomena and dimensionalities,
- how human inputs are transcribed,
- and how the world description is updated.

Agents have no additional responsibilities outside what is stated inside
world-layout.txt.

End.
