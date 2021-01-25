#!/usr/bin/env node

const { mkdir, copyFile: copy_file } = require('fs/promises')
const { join } = require('path')
const { promisify } = require('util')
const exec_file = promisify(require('child_process').execFile)

const [, , ...arguments] = process.argv
const mkdir_options = {
  recursive: true,
}
const copy_action = Symbol('action_copy_file')
const mkdir_action = Symbol('action_create_dir')

const compile = async () => {
  console.log('compiling...')
  try {
    const { stdout } = await exec_file('npm', ['run', 'build:pretty'])
    console.log(stdout, '...done')
  } catch (err) {
    console.error(err.stdout, '...failed')
    process.exit(err.code || 1)
  }
}

const mk_dirs = async ({ queue }) => {
  const folders = queue.filter((acc) => {
    return acc.action === mkdir_action
  })
  for (folder of folders) {
    try {
      await mkdir(folder.value, mkdir_options)
      console.log(`created folder ${folder.value}`)
    } catch (err) {
      console.error(err)
      process.exit(err.code || 1)
    }
  }
}

const cp_files = async ({ queue, project_path, package_target }) => {
  const files = queue.filter((acc) => {
    return acc.action === copy_action
  })
  for (file of files) {
    try {
      await copy_file(
        join(project_path, file.file_or_folder || file.key),
        join(project_path, package_target, file.file_or_folder || file.value)
      )
      console.log(`copied file ${file.file_or_folder || file.value}`)
    } catch (err) {
      console.error(err)
      process.exit(err.code || 1)
    }
  }
}

const parse_arguments = () => {
  const re_arguments = /(?:\s*)(?<key>\S+)(?:\s*)(?:(?<assignment>:)|(?<copy>>))(?:\s*)(?<value>\S+)(?:\s*)|^(?<file_or_folder>.+)$/
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
      // treat every other value as file or folder and mark to copy it
      queue.push({ file_or_folder, action: copy_action })
    } else if (assignment) {
      // treat every other assignment as mkdir_action
      // queue.push({key, value, action: mkdir_action})
      queue.push({ key, value, action: mkdir_action })
    } else if (copy) {
      queue.push({ key, value, action: copy_action })
    } else {
      console.log('this shouldnt be here', arg)
    }
  }
  return { queue, project_path, package_target }
}

const build_extension = async () => {
  const parsed_args = parse_arguments()
  await mk_dirs(parsed_args)
  await compile()
  await cp_files(parsed_args)
}
build_extension()
