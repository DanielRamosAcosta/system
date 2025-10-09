import fs from "node:fs"

type Versions = Record<string, { repo: string, version: string }>

const versions: Versions = JSON.parse(fs.readFileSync("./tanka/environments/versions.json", "utf-8"))

for(const [service, data] of Object.entries(versions)) {
  const response = await fetch(`https://api.github.com/repos/${data.repo}/releases/latest`)
  const json = await response.json()
  
  if(json.tag_name !== data.version) {
    console.log(`🔄 ${service}: ${data.version} -> ${json.name}`)
  } else {
    console.log(`✅ ${service}: ${data.version}`)
  }
}
