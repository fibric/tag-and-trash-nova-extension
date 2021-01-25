#!/usr/bin/env node

const { rm } = require('fs/promises')
const { promisify } = require('util')
const exec_file = promisify(require('child_process').execFile)
const [, , ...arguments] = process.argv
const rm_options = {
  force: true,
  maxRetires: 3,
  recursive: true,
}
const re_arguments = /(?:\s*)(?<key>\S+)(?:\s*)(?:(?<assignment>:)|(?<copy>>))(?:\s*)(?<value>\S+)(?:\s*)|^(?<file_or_folder>.+)$/

const cleanup_extension = async () => {
  for (arg of arguments) {
    const {
      groups: { key, assignment, copy, value, file_or_folder },
    } = re_arguments.exec(arg)
    if (assignment && (key === 'package_target' ||  key === 'compile_target')) {
      try {
        rm(value, rm_options)
      } catch (err) {
        console.error(err)
        process.exit(1)
      }
    }
  }
}

(async () => {
  await cleanup_extension()
})()
