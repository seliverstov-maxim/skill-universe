# Repeatable manual verification

This directory contains disposable fixtures and manual scenarios, not an automatically passing test suite. Record actual results, exit codes and filesystem effects. A scenario not run is **Not checked**, not Passed. Dependencies: Docker for development; the installed CLI still needs only its documented Unix tools.

Review source first. Freeze a committed revision and create a read-only snapshot, without your Git credentials, home directory or ignored local files:

```sh
SKILL_UNIVERSE_VERIFY_DIR=$(mktemp -d)
mkdir "$SKILL_UNIVERSE_VERIFY_DIR/source" "$SKILL_UNIVERSE_VERIFY_DIR/evidence"
git rev-parse HEAD > "$SKILL_UNIVERSE_VERIFY_DIR/evidence/source-commit.txt"
git archive HEAD > "$SKILL_UNIVERSE_VERIFY_DIR/source.tar"
tar -xf "$SKILL_UNIVERSE_VERIFY_DIR/source.tar" -C "$SKILL_UNIVERSE_VERIFY_DIR/source"
docker build -t skill-universe-verification "$SKILL_UNIVERSE_VERIFY_DIR/source/verification"
docker run --rm -it --network none --read-only --tmpfs /tmp --tmpfs /work:exec,mode=1777 \
  --mount type=bind,source="$SKILL_UNIVERSE_VERIFY_DIR/source",target=/source,readonly \
  --mount type=bind,source="$SKILL_UNIVERSE_VERIFY_DIR/evidence",target=/evidence \
  skill-universe-verification
```

The container image is pinned, but package repository updates can change dependency versions. Record Git/jq/shell versions and the built image ID. The network is available only while building dependencies; the scenario container has no network, host home, Docker socket or credentials. Source is read-only; only evidence is mounted writable. Do not interpret this isolation as proof that no outbound network operation was attempted. Live website/download verification is a separate read-only HTTP/Git check outside this container.

Inside the container, run `sh /source/verification/setup.sh`, then work through [the scenarios](scenarios.md) and record each observation in `/evidence`. Fixtures stay in `/work` and disappear when the container exits. Keep the state and harness environment overrides shown in the Dockerfile; do not replace the host's HOME. You can choose another evidence directory through `SKILL_UNIVERSE_VERIFY_DIR` when preparing a new snapshot.

Check the host before/after if you claim host-file preservation; a read-only container mount alone is a boundary, not an observed audit of every host file. Do not upload private repositories, real credentials, internal conversation or machine paths into public reports.
