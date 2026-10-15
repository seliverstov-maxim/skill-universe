FROM ubuntu:24.04@sha256:534baea6a22c03a63003dbc8dbe78fe34bc0d7e595d9a9dc9834884ff530eb55
RUN apt-get update && apt-get install -y --no-install-recommends git jq ca-certificates mawk && rm -rf /var/lib/apt/lists/*
ENV SKILL_UNIVERSE_HOME=/work/state \
    CODEX_HOME=/work/codex \
    SKILL_UNIVERSE_CODEX_SKILLS_DIR=/work/codex/skills \
    SKILL_UNIVERSE_CODEX_RULES_DIR=/work/codex/rules \
    SKILL_UNIVERSE_CLAUDE_SKILLS_DIR=/work/claude/skills \
    SKILL_UNIVERSE_CLAUDE_RULES_DIR=/work/claude/rules
WORKDIR /work
CMD ["sh"]
