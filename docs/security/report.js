// Render repository result data as text; no remote scripts or HTML injection.
const methods = {
  'SU-SEC-1': ['security-report.json', 'methodology.md', 'Security audit'],
  'SU-DECL-1': ['declared-behavior-report.json', 'declared-behavior-methodology.md', 'Declared behavior audit']
};
function element(tag, text, className) {
  const node = document.createElement(tag);
  if (text !== undefined) node.textContent = String(text);
  if (className) node.className = className;
  return node;
}
function safeLink(text, href) {
  const url = new URL(href, location.href);
  if (url.protocol !== 'https:' && url.origin !== location.origin) return element('span', text);
  const node = element('a', text);
  node.href = url.href;
  return node;
}
function status(value) {
  const names = {passed:'Passed', failed:'Failed', passing:'Passing', failing:'Failing', incomplete:'Incomplete', 'not-checked':'Not checked', 'not-applicable':'Not applicable'};
  return element('span', names[value] || 'Unknown', `status ${Object.hasOwn(names, value) ? value : 'incomplete'}`);
}
async function load() {
  const method = new URLSearchParams(location.search).get('method') || 'SU-SEC-1';
  if (!Object.hasOwn(methods, method)) throw new Error('Unknown methodology. Choose one of the audit tabs.');
  const [file, methodology, title] = methods[method];
  const response = await fetch(file, {cache:'no-cache'});
  if (!response.ok) throw new Error('Report unavailable for this revision.');
  const report = await response.json();
  if (report.method !== method || !/^[0-9a-f]{40}$/.test(report.commit) || !['passing','failing','incomplete'].includes(report.result)) throw new Error('Invalid report identity.');
  const source = `https://github.com/seliverstov-maxim/skill-universe/blob/${report.commit}/`;
  document.title = `Skill Universe — ${title}`;
  document.getElementById('report-title').textContent = title;
  for (const tab of document.querySelectorAll('[data-method]')) {
    if (tab.dataset.method === method) tab.setAttribute('aria-current','page');
  }
  const raw = document.getElementById('raw-report');
  raw.href = file;
  raw.hidden = false;
  document.getElementById('security-method').href = source + 'docs/security/methodology.md';
  document.getElementById('declared-method').href = source + 'docs/security/declared-behavior-methodology.md';
  document.getElementById('verification-link').href = source + 'verification/README.md';
  const complete = check => check.code === 'passed' && ['passed','not-applicable'].includes(check.observed);
  const passed = report.checks.filter(complete).length;
  const failed = report.checks.filter(check => check.code === 'failed' || check.observed === 'failed').length;
  const pending = report.checks.length - passed - failed;
  const mark = document.getElementById('verdict-mark');
  mark.className = `verdict-mark ${report.result}`;
  mark.textContent = {passing:'✓', failing:'!', incomplete:'…'}[report.result];
  document.getElementById('verdict-title').textContent = {passing:'Assessment passed', failing:'Findings need attention', incomplete:'Assessment incomplete'}[report.result];
  document.getElementById('verdict-description').textContent = {
    passing:'All required checks passed within the recorded scope. Review evidence and limits below.',
    failing:'At least one finding remains open. Read the criterion evidence before using this revision.',
    incomplete:'Some required evidence is missing. Pending checks do not count as passed.'
  }[report.result];
  for (const [value,label,kind] of [[`${passed}/${report.checks.length}`,'Criteria passed','good'],[failed,'Failed criteria',failed ? 'bad' : ''],[pending,'Pending criteria','']]) {
    const metric = element('div', undefined, 'metric');
    metric.append(element('strong',value,kind),element('span',label));
    document.getElementById('metrics').append(metric);
  }
  const identity = document.getElementById('identity');
  for (const [key,value] of Object.entries({Methodology:`${method} · version ${report.version}`,Commit:report.commit,Reviewed:report.date,Environment:report.environment,Reviewer:report.reviewer})) {
    const content = element('dd',undefined,key === 'Commit' ? 'mono' : '');
    if (key === 'Commit') content.append(safeLink(value,`https://github.com/seliverstov-maxim/skill-universe/tree/${report.commit}`));
    else if (key === 'Methodology') content.append(safeLink(value, source + 'docs/security/' + methodology));
    else content.textContent = value;
    identity.append(element('dt',key),content);
  }
  document.getElementById('answer-heading').hidden = method !== 'SU-DECL-1';
  for (const check of report.checks) {
    const row = element('tr');
    const criterion = element('td');
    const details = element('details');
    const summary = element('summary');
    summary.append(element('span',check.id,'check-id'),element('span',check.question,'check-name'));
    const evidence = element('div',undefined,'check-detail');
    evidence.append(element('p',check.note));
    const links = element('div',undefined,'source-links');
    for (const item of check.evidence || []) links.append(safeLink(item.label,item.url));
    evidence.append(links);
    details.append(summary,evidence);
    criterion.append(details);
    row.append(criterion);
    for (const kind of ['code','observed']) {
      const cell = element('td'); cell.append(status(check[kind])); row.append(cell);
    }
    if (method === 'SU-DECL-1') row.append(element('td',check.answer,'answer'));
    document.getElementById('checks').append(row);
  }
  const evidence = document.getElementById('evidence');
  evidence.append(element('h3','Recorded observations'));
  for (const item of report.observations || []) {
    const observation = element('div',undefined,'observation');
    observation.append(element('h3',item.scenario),status(item.result),element('p',item.details));
    evidence.append(observation);
  }
  evidence.append(element('h3','File SHA-256 inventory'));
  evidence.append(element('div',Object.entries(report.files).map(([path,digest]) => `${digest}  ${path}`).join('\n'),'inventory'));
  document.getElementById('overview').hidden = false;
  document.getElementById('loading').textContent = 'Results apply to the recorded source commit, environment and observations.';
  const prompt = await fetch('review-prompt.txt', {cache:'no-cache'});
  if (!prompt.ok) throw new Error('Reproduction prompt unavailable.');
  document.getElementById('prompt').textContent = await prompt.text();
}
load().catch(error => { document.getElementById('loading').textContent = error.message; });
