#!/usr/bin/env node

const { mkdir, copyFile: copy_file } = require('fs/promises')
const { join } = require('path')
const { promisify } = require('util')
const exec_file = promisify(require('child_process').execFile)

const [, , ...arguments] = process.argv
const mkdir_options = {
  recursive: true,
}

const compile_rescript = async () => {
  const child = exec_file('yarn', ['build'], (err, stdout, stderr) => {
    if (err) {
      console.error(err)
      proces.exit(1)
    }
    console.log(stdout)
  })
}
compile_rescript()

const copy_action = Symbol('action_copy_file')
const mkdir_action = Symbol('action_create_dir')
const re_arguments = /(?:\s*)(?<key>\S+)(?:\s*)(?:(?<assignment>:)|(?<copy>>))(?:\s*)(?<value>\S+)(?:\s*)|^(?<file_or_folder>.+)$/
const build_extension = async () => {
  const queue = []
  let package_target = '.'
  let project_path = '.'
  for (arg of arguments) {
    const {
      groups: { key, assignment, copy, value, file_or_folder },
    } = re_arguments.exec(arg)
    if (key === 'package_target') {
      package_target = value
      queue.push({ key, value, action: mkdir_action })
    } else if (key === 'project_path') {
      project_path = value
    } else if (file_or_folder) {
      queue.push({ file_or_folder, action: copy_action })
    }
  }
  for (step of queue) {
    switch (step.action) {
      case mkdir_action:
        try {
          await mkdir(step.value, mkdir_options)
        } catch (err) {
          console.error(err)
          process.exit(1)
        }
        break
      case copy_action:
        try {
          await copy_file(
            join(project_path, step.file_or_folder),
            join(project_path, package_target, step.file_or_folder)
          )
        } catch (err) {
          console.error(err)
          process.exit(1)
        }
        break
    }
  }
}
build_extension()
