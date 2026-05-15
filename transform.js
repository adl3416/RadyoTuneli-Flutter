const fs = require('fs');

let html = fs.readFileSync('web/landing.html', 'utf8');

// Replace modal onclick links with real page hrefs
html = html.replace(/href="#" onclick="openModal\('impressum'\);return false;"/g, 'href="imprint.html" target="_blank"');
html = html.replace(/href="#" onclick="openModal\('privacy'\);return false;"/g, 'href="privacy.html" target="_blank"');
html = html.replace(/href="#" onclick="openModal\('terms'\);return false;"/g, 'href="terms.html" target="_blank"');

// Cut everything from first modal div onward (removes modals + script)
const cutIdx = html.search(/<!-- .*MODAL.*IMPRESSUM/);
if (cutIdx > -1) {
  html = html.substring(0, cutIdx).trimEnd() + '\n\n</body>\n</html>\n';
}

if (!fs.existsSync('public')) fs.mkdirSync('public');
fs.writeFileSync('public/index.html', html);
console.log('public/index.html:', Math.round(fs.statSync('public/index.html').size / 1024), 'KB');
fs.unlinkSync('transform.js');
console.log('Done.');
