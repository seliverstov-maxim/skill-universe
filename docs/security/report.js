// Render repository data as text and safe links; no external scripts or HTML injection.
const methods = {
  'SU-SEC-1': ['security-report.json', 'methodology.md'],
  'SU-DECL-1': ['declared-behavior-report.json', 'declared-behavior-methodology.md']
};
function element(tag, text) {
  const node = document.createElement(tag);
  if (text !== undefined) node.textContent = String(text);
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
  const names = {passed:'Passed', failed:'Fail', passing:'Passing', failing:'Failing', incomplete:'Incomplete', 'not-checked':'Not checked', 'not-applicable':'Not applicable'};
  const node = element('span', names[value] || 'Unknown');
  node.className = `status ${Object.hasOwn(names, value) ? value : 'incomplete'}`;
  return node;
}
async function load() {
  const method = new URLSearchParams(location.search).get('method') || 'SU-SEC-1';
  if (!Object.hasOwn(methods, method)) throw new Error('Unknown methodology.');
  const response = await fetch(methods[method][0]);
  if (!response.ok) throw new Error('Report unavailable for this revision.');
  const report = await response.json();
  if (report.method !== method || !/^[0-9a-f]{40}$/.test(report.commit)) throw new Error('Invalid report identity.');
  const source = `https://github.com/seliverstov-maxim/skill-universe/blob/${report.commit}/`;
  const identity = document.getElementById('identity');
  for (const [key,value] of Object.entries({Methodology:`${method} v${report.version}`,Result:report.result,Commit:report.commit,Date:report.date,Environment:report.environment,Reviewer:report.reviewer})) {
    const row = element('tr');
    row.append(element('th',key));
    const cell = element('td');
    if (key === 'Result') cell.append(status(value));
    else if (key === 'Commit') cell.append(safeLink(value, `https://github.com/seliverstov-maxim/skill-universe/tree/${report.commit}`));
    else if (key === 'Methodology') cell.append(safeLink(value, source + 'docs/security/' + methods[method][1]));
    else cell.textContent = value;
    row.append(cell); identity.append(row);
  }
  for (const check of report.checks) {
    const row = element('tr');
    row.append(element('td',`${check.id} · ${check.question}`));
    for (const kind of ['code','observed']) {
      const cell = element('td'); cell.append(status(check[kind])); row.append(cell);
    }
    const evidence = element('td', check.note);
    if (check.answer) evidence.append(element('p',`Answer: ${check.answer}`));
    for (const item of check.evidence || []) {
      evidence.append(element('br'), safeLink(item.label, item.url));
    }
    row.append(evidence); document.getElementById('checks').append(row);
  }
  const evidence = document.getElementById('evidence');
  evidence.append(element('h3','Recorded observations'));
  for (const item of report.observations || []) evidence.append(element('p',`${item.scenario}: ${item.result}. ${item.details}`));
  evidence.append(element('h3','File SHA-256 inventory'));
  for (const [path,digest] of Object.entries(report.files)) evidence.append(element('p', `${digest}  ${path}`));
  document.getElementById('loading').textContent = 'Results apply to the recorded commit and environment.';
  const prompt = await fetch('review-prompt.txt');
  if (!prompt.ok) throw new Error('Reproduction prompt unavailable.');
  document.getElementById('prompt').textContent = await prompt.text();
}
load().catch(error => { document.getElementById('loading').textContent = error.message; });
