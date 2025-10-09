import fs from "node:fs"

type Versions = Record<string, { repo: string, version: string }>

const versions: Versions = JSON.parse(fs.readFileSync("./tanka/environments/versions.json", "utf-8"))

const entries = Object.entries(versions)

await Promise.all(entries.map(checkVersion))

async function checkVersion([service, data]: [string, { repo: string, version: string }]) {
  const response = await fetch(`https://api.github.com/repos/${data.repo}/releases/latest`)

  if (!response.ok) {
    const text = await response.text()
    console.error(`❌ ${service}: ${response.status} ${response.statusText} - ${text}`)
    return
  }

  const json = await response.json()

  const current = normalizeVersion(data.version)
  const latest = normalizeVersion(json.tag_name)

  if(latest !== current) {
    console.log(`🔄 ${service}: ${current} -> ${latest}`)
  } else {
    console.log(`✅ ${service}: ${current}`)
  }
}

function normalizeVersion(version: string) {
  return version.replace('v', '').split('/')[0]
}
