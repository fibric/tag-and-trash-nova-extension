#!/usr/bin/env node

const { rm } = require('fs/promises')
const { promisify } = require('util');
const exec_file = promisify(require('child_process').execFile);
const [, , ...arguments] = process.argv
const rm_options = {
  force: true,
  maxRetires: 3,
  recursive: true,
}
const re_arguments = /(?<left>\S+)(?:\s*)(?:(?<is_assignment>:)|(?<is_copy_action>>))(?:\s*)(?<right>\S+)|^(?<is_file_or_folder>.*)$/

const rm_package_target_dir = async () => {
  for (arg of arguments) {
    const {groups: {left,is_assignment, is_copy_action,right, is_file_or_folder}} = re_arguments.exec(arg)
    if (is_assignment && left === 'package_target') {
      try {
        rm(right, rm_options) 
      } catch (err) {
        console.error(err)
        process.exit(1)
      }
    }
  }
}
rm_package_target_dir()

const rm_rescript_dirs = async () => {
  // call yarn
  const {stdout} = await exec_file('yarn', ['clean']);
  console.log(stdout)
}
rm_rescript_dirs()

