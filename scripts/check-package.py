"""Portable structural checks. These do not replace Salesforce validation."""
from pathlib import Path
import json
import re
import xml.etree.ElementTree as ET

root=Path(__file__).resolve().parents[1]
ns={'m':'http://soap.sforce.com/2006/04/metadata'}
errors=[]
xml_files=list((root/'force-app').rglob('*.xml'))
for path in xml_files:
    try: ET.parse(path)
    except ET.ParseError as exc: errors.append(f'{path.relative_to(root)}: {exc}')
flow=ET.parse(root/'force-app/main/default/flows/SH_Create_Onboarding.flow-meta.xml').getroot()
names={x.text for x in flow.findall('./*/m:name',ns)}
for target in flow.findall('.//m:targetReference',ns):
    if target.text not in names: errors.append(f'Unresolved Flow connector: {target.text}')
for link in re.findall(r'href="([^"]+)"',(root/'CASE-STUDY.html').read_text()):
    if not link.startswith(('http:','https:','#')) and not (root/link).is_file():
        errors.append(f'Broken case-study link: {link}')
for directory in ['.sf','.sfdx','node_modules']:
    if (root/directory).exists(): errors.append(f'Exclude {directory} before sharing')
test_source=(root/'force-app/main/default/classes/SH_HandoffTests.cls').read_text()
print(json.dumps({'xml_files_parsed':len(xml_files),'test_methods_prepared':len(re.findall(r'@IsTest static void',test_source)),'errors':errors,'scope':'Local structure only; Salesforce compilation, test execution and UAT remain separate.'},indent=2))
raise SystemExit(bool(errors))
