import json
import sys
import os
from pathlib import Path


HOME_PATH = Path.home()
extensionPath = HOME_PATH / 'Library/Application Support/Code/User/globalStorage/alefragnani.project-manager'

projectFiles = list(extensionPath.glob('projects*json'))

projects = list()
for projectFile in projectFiles:
    with open(projectFile, 'r') as file:
        data = file.read()
        projects += json.loads(data)

# sort
projects = sorted(projects, key=lambda k: k['name'])
items = []
for project in projects:
    projectPath = project.get('rootPath', project.get('fullPath', None))
    subtitle = projectPath.split('/')[-1]
    isEnabled = project.get('isEnabled', True)
    if isEnabled:
        item = {
            "title": project['name'],
            "subtitle": subtitle,
            "arg": projectPath
        }
        if len(sys.argv) > 1:
            if sys.argv[1].lower() in project['name'].lower():
                items.append(item)
        else:
            items.append(item)

result = {
    "items": items
}

output = json.dumps(result)
print(output)

sys.exit(0)
