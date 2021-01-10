#!/usr/bin/env node

const { rm } = require('fs/promises')

const [, , ...arguments] = process.argv
const rm_options = {
  force: true,
  maxRetires: 3,
  recursive: true,
}

console.log('cleaning dependencies')
;(async () => {
  // take only files and folders
  const parse_arguemnts = arguments => {
    re = /(?<isAssignment>(?:.+)(?:[:])(?:.*))|^(?<isFileOrFolder>.*)$/
    return arguments.filter(value => {
      const {
        groups: { isFileOrFolder },
      } = re.exec(value)
      return isFileOrFolder ? true : false
    })
  }
  // remove yarn directory and lock file
  const rm_yarn_files_and_folders = async arguments => {
    const files_or_folders = parse_arguemnts(arguments)
    for (file_or_folder of files_or_folders) {
      try {
        await rm(file_or_folder, rm_options)
      } catch (err) {
        console.error(err)
        process.exit(1)
      }
    }
  }

  await rm_yarn_files_and_folders(arguments)
})()
