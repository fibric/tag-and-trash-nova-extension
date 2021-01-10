#!/usr/bin/env node

const { join } = require('path')
const { writeFile: write_file } = require('fs/promises')

const [, , ...arguments] = process.argv
const re_arguments = /(?:\s*)(?<key>\S+)(?:\s*)(?:(?<assignment>:)|(?<copy>>))(?:\s*)(?<value>\S+)(?:\s*)|^(?<file_or_folder>.+)$/

const package_extension = async () => {
  let package_target = '.'
  let project_path = '.'
  for (arg of arguments) {
    console.log({arg})
    const { groups: { key, assignment, copy, value, file_or_folder }} = re_arguments.exec(arg)
    if (key === 'package_target') {
      package_target = value
    } else if (key === 'project_path') {
      project_path = value
    }
  }
  
  const package_file = join(project_path,'package.json')
  const package_json = require(package_file)
  const extension_file = join(project_path,'extension.json')
  const extension_json = require(extension_file)
  const bsconfig_file = join(project_path,'bsconfig.json')
  const bsconfig_json = require(bsconfig_file)

  const extension_file2 = join(project_path, package_target, 'extension.json')

  extension_json.version = package_json.version
  bsconfig_json.version = package_json.version
  
  extension_json.description = package_json.description
  
  bsconfig_json.name = package_json.name
  
  try {
    write_file(extension_file, JSON.stringify(extension_json, null, 2))
    write_file(bsconfig_file, JSON.stringify(bsconfig_json, null, 2))
    try {
      const extension_json2 = require(extension_file2)
      write_file(extension_file2, JSON.stringify(extension_json, null, 2))
    } catch (_ignore) {
      // ignore
    }
  } catch (err) {
    console.error(err)
    process.exit(1)
  }
}
package_extension()
