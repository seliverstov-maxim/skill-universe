#!/usr/bin/env python3
"""Replay the published security boundary checks against an exact Git revision."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import tarfile
import tempfile

SOURCE_REVISION = '0b0b6d1b47dc631577e6aac62d5107bc5ba248f4'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('repository', type=Path)
parser.add_argument('--revision', default=SOURCE_REVISION)
parser.add_argument('--output', type=Path)
args = parser.parse_args()
repository = args.repository.resolve()
revision = subprocess.check_output(['git', '-C', str(repository), 'rev-parse', args.revision + '^{commit}'], text=True).strip()
archive = subprocess.check_output(['git', '-C', str(repository), 'archive', revision])
results = []
transcript = []

with tempfile.TemporaryDirectory(prefix='skill-universe-security-') as temporary:
    root = Path(temporary)
    snapshot = root / 'snapshot'
    snapshot.mkdir()
    with tarfile.open(fileobj=io.BytesIO(archive)) as contents:
        contents.extractall(snapshot, filter='data')
    cli = snapshot / 'skill-universe'
    files = [cli, snapshot / 'install.sh', snapshot / 'VERSION', *sorted((snapshot / 'commands').glob('*.sh')), snapshot / 'docs/install.sh', snapshot / 'docs/index.html', snapshot / 'docs/style.css', snapshot / 'docs/icon.svg', snapshot / 'docs/sitemap.xml']
    hashes = {str(p.relative_to(snapshot)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}

    def run(command, home, check=True, extra_environment=None):
        environment = {'PATH': os.environ['PATH'], 'HOME': str(home), 'LC_ALL': 'C', 'GIT_CONFIG_NOSYSTEM': '1', 'GIT_CONFIG_GLOBAL': os.devnull, 'GIT_ALLOW_PROTOCOL': 'file', 'GIT_TERMINAL_PROMPT': '0'}
        environment.update(extra_environment or {})
        process = subprocess.run([str(x) for x in command], cwd=root, env=environment, capture_output=True, text=True)
        transcript.append({'command': [str(x).replace(str(root), '<sandbox>') for x in command], 'exit': process.returncode, 'stdout': process.stdout.replace(str(root), '<sandbox>'), 'stderr': process.stderr.replace(str(root), '<sandbox>')})
        if check and process.returncode:
            raise RuntimeError(transcript[-1])
        return process

    def invoke(home, *arguments, check=True):
        return run(['sh', cli, *arguments], home, check)

    def record(identifier, property_name, passed, evidence):
        results.append({'id': identifier, 'property': property_name, 'status': 'PASS' if passed else 'FAIL', 'evidence': evidence})

    def setup(name):
        home = root / name
        home.mkdir()
        invoke(home, 'init', '--harness=codex')
        return home

    source = root / 'source'
    (source / 'skills/demo/scripts').mkdir(parents=True)
    (source / 'rules').mkdir()
    (source / 'skills/demo/SKILL.md').write_text('# Demo\nAn inert fixture.\n')
    (source / 'skills/demo/scripts/postinstall.sh').write_text('#!/bin/sh\ntouch POSTINSTALL_EXECUTED\n')
    (source / 'rules/style.md').write_text('# Style\nUse clear names.\n')
    (source / 'rules/host.md').symlink_to('../../../../private.md')
    run(['git', 'init', '-b', 'main', source], root)
    run(['git', '-C', source, 'add', '.'], root)
    run(['git', '-C', source, '-c', 'user.name=Security replay', '-c', 'user.email=replay@example.invalid', 'commit', '-m', 'Local fixture'], root)
    url = source.as_uri()

    home = setup('literal')
    literal = 'literal-$(touch SHELL_EXECUTED)'
    result = invoke(home, 'install', url, '--skill=demo', '--alias=' + literal, check=False)
    link = home / '.agents/skills' / literal
    record('C01', 'Alias text is not evaluated as shell code', not (root / 'SHELL_EXECUTED').exists(), {'exit': result.returncode, 'literal_link_created': link.is_symlink(), 'shell_marker_created': (root / 'SHELL_EXECUTED').exists()})
    home = setup('payload')
    invoke(home, 'install', url, '--skill=demo')
    record('C02', 'Repository payload scripts are not executed during install', not (root / 'POSTINSTALL_EXECUTED').exists(), 'Fixture postinstall.sh was delivered without execution.')

    home = setup('remove-traversal')
    (home / '.agents/skills').mkdir(parents=True)
    victim = home / 'outside.txt'
    victim.write_text('Keep this user file.\n')
    result = invoke(home, 'remove', '../../outside.txt', check=False)
    record('C03', 'Remove cannot escape its installation directory', victim.exists(), {'exit': result.returncode, 'outside_file_exists': victim.exists(), 'alias_registered': False})

    home = setup('install-traversal')
    (home / '.agents').mkdir()
    invoke(home, 'install', url, '--skill=demo', '--alias=../outside', check=False)
    outside = home / '.agents/outside'
    record('C04', 'Install aliases cannot escape their installation directory', not outside.is_symlink(), {'outside_symlink_created': outside.is_symlink(), 'location': '~/.agents/outside'})

    home = setup('rename-collision')
    invoke(home, 'install', url, '--rule=style')
    victim = home / '.codex/rules/personal.md'
    original = '# Personal instructions\nKeep this text.\n'
    victim.write_text(original)
    invoke(home, 'rename', 'style', 'personal', check=False)
    record('C05', 'Rename preserves existing unmanaged destination files', not victim.is_symlink() and victim.read_text() == original, {'destination_is_symlink': victim.is_symlink(), 'original_contents_preserved': victim.read_text() == original})

    home = setup('source-symlink')
    private = home / 'private.md'
    private.write_text('LOCAL_PRIVATE_MARKER\n')
    invoke(home, 'install', url, '--rule=host', check=False)
    linked = home / '.codex/rules/host.md'
    record('C06', 'Installed repository rules resolve inside their Git checkout', not linked.exists() or linked.resolve() != private.resolve(), {'rule_resolves_to_host_file': linked.exists() and linked.resolve() == private.resolve(), 'file_content_exposed_as_rule': linked.exists() and linked.read_text() == private.read_text()})

    home = setup('managed-block')
    agents = home / '.codex/AGENTS.md'
    agents.parent.mkdir()
    agents.write_text('# Personal instructions\nKEEP_BEFORE\n')
    invoke(home, 'install', url, '--rule=style')
    invoke(home, 'install', url, '--rule=style', '--alias=second')
    agents.write_text(agents.read_text() + 'KEEP_AFTER\n')
    count = agents.read_text().count('<!-- skill-universe:rules:start -->')
    invoke(home, 'remove', 'style')
    block_retained = '<!-- skill-universe:rules:start -->' in agents.read_text()
    invoke(home, 'remove', 'second')
    text = agents.read_text()
    record('C07', 'Normal rule removal preserves personal AGENTS.md text', count == 1 and block_retained and 'KEEP_BEFORE' in text and 'KEEP_AFTER' in text and '<!-- skill-universe:rules:start -->' not in text, {'block_count': count, 'block_retained_until_last_rule': block_retained, 'personal_text_retained': 'KEEP_BEFORE' in text and 'KEEP_AFTER' in text})

    home = setup('incomplete-block')
    invoke(home, 'install', url, '--rule=style')
    agents = home / '.codex/AGENTS.md'
    agents.write_text('# Personal instructions\n<!-- skill-universe:rules:start -->\nManaged instructions\nKEEP_AFTER\n')
    invoke(home, 'remove', 'style', check=False)
    record('C08', 'An incomplete managed block does not delete following personal text', 'KEEP_AFTER' in agents.read_text(), {'personal_text_after_missing_end_marker_retained': 'KEEP_AFTER' in agents.read_text()})

    home = setup('duplicate')
    invoke(home, 'install', url, '--skill=demo')
    manifest = home / '.skill-universe/manifest.json'
    before = manifest.read_bytes()
    result = invoke(home, 'install', url, '--rule=style', '--alias=demo', check=False)
    record('C09', 'Duplicate aliases are rejected without changing the manifest', result.returncode != 0 and manifest.read_bytes() == before, {'exit': result.returncode, 'manifest_unchanged': manifest.read_bytes() == before})

    home = setup('conflict')
    invoke(home, 'install', url, '--rule=style')
    link = home / '.codex/rules/style.md'
    link.write_text('# Local edit\n')
    (source / 'rules/style.md').write_text('# Upstream edit\n')
    run(['git', '-C', source, 'add', '.'], root)
    run(['git', '-C', source, '-c', 'user.name=Security replay', '-c', 'user.email=replay@example.invalid', 'commit', '-m', 'Conflicting upstream'], root)
    manifest = home / '.skill-universe/manifest.json'
    before = manifest.read_bytes()
    result = invoke(home, 'update', 'style', check=False)
    record('C10', 'Conflicting updates preserve local edits and manifest', result.returncode != 0 and link.read_text() == '# Local edit\n' and manifest.read_bytes() == before, {'exit': result.returncode, 'local_edit_preserved': link.read_text() == '# Local edit\n', 'manifest_unchanged': manifest.read_bytes() == before})

    tool_source = root / 'tool-source'
    shutil.copytree(snapshot, tool_source)
    run(['git', 'init', '-b', 'main', tool_source], root)
    run(['git', '-C', tool_source, 'add', '.'], root)
    run(['git', '-C', tool_source, '-c', 'user.name=Security replay', '-c', 'user.email=replay@example.invalid', 'commit', '-m', 'Tool fixture'], root)
    redirect = {'GIT_CONFIG_COUNT': '1', 'GIT_CONFIG_KEY_0': 'url.' + tool_source.as_uri() + '.insteadOf', 'GIT_CONFIG_VALUE_0': 'https://github.com/seliverstov-maxim/skill-universe.git'}
    home = root / 'bootstrap'
    home.mkdir()
    run(['sh', snapshot / 'install.sh'], home, extra_environment=redirect)
    installed = home / '.local/bin/skill-universe'
    record('C13', 'Bootstrap installs the expected tool and command symlink', installed.is_symlink() and installed.resolve() == (home / '.skill-universe/tool/skill-universe').resolve(), 'Ran the actual installer with Git URL rewriting to a local copy of the reviewed source; no HTTPS request.')

    occupied = root / 'occupied-command'
    (occupied / '.local/bin').mkdir(parents=True)
    command = occupied / '.local/bin/skill-universe'
    command.write_text('KEEP_EXISTING_COMMAND\n')
    result = run(['sh', snapshot / 'install.sh'], occupied, check=False, extra_environment=redirect)
    record('C14', 'Bootstrap preserves an existing regular command file', result.returncode != 0 and command.read_text() == 'KEEP_EXISTING_COMMAND\n', {'exit': result.returncode, 'existing_file_preserved': command.read_text() == 'KEEP_EXISTING_COMMAND\n'})

    invoke(home, 'init', '--harness=codex')
    manifest = home / '.skill-universe/manifest.json'
    configuration = json.loads(manifest.read_text())
    configuration['upgrade']['url'] = tool_source.as_uri()
    manifest.write_text(json.dumps(configuration))
    (tool_source / 'VERSION').write_text('audit-fixture-next-version\n')
    run(['git', '-C', tool_source, 'add', 'VERSION'], root)
    run(['git', '-C', tool_source, '-c', 'user.name=Security replay', '-c', 'user.email=replay@example.invalid', 'commit', '-m', 'Tool update fixture'], root)
    invoke(home, 'upgrade')
    record('C15', 'Upgrade obtains the configured tool source', (home / '.skill-universe/tool/VERSION').read_text() == 'audit-fixture-next-version\n', 'Actual upgrade ran against a local Git fixture; source trust remains the user responsibility.')

    syntax = [run(['sh', '-n', p], root, check=False).returncode for p in [cli, snapshot / 'install.sh', snapshot / 'docs/install.sh', *sorted((snapshot / 'commands').glob('*.sh'))]]
    record('C11', 'All distributed shell files parse successfully', all(code == 0 for code in syntax), {'files_checked': len(syntax)})
    record('C12', 'The Pages installer matches the root installer', (snapshot / 'docs/install.sh').read_bytes() == (snapshot / 'install.sh').read_bytes(), 'Compared bytes of both distributed installer copies.')
    versions = {tool: run(command, root).stdout.strip() for tool, command in {'git':['git','--version'], 'jq':['jq','--version']}.items()}
    report = {'reviewed_commit': revision, 'platform': platform.platform(), 'python': platform.python_version(), 'tools': versions, 'source_sha256': hashes, 'checks': results, 'transcript': transcript}
    if args.output:
        args.output.write_text(json.dumps(report, indent=2) + '\n')
    for item in results:
        print(item['status'], item['id'], item['property'])
    print('Total:', len(results), 'Failed:', sum(item['status'] == 'FAIL' for item in results))
    raise SystemExit(1 if any(item['status'] == 'FAIL' for item in results) else 0)
