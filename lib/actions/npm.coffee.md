
# `nikital.system.npm`

Install Node.js packages with NPM.

## Options

*   `global` (string|array)
    Install packages globally.
*   `name` (string|array)
    Name of the package(s).
*   `upgrade` (boolean)
    Upgrade all packages, default to "false".

## Source code

    module.exports = ({options}) ->
      options.name = options.argument if options.argument?
      options.name = [options.name] if typeof options.name is 'string'
      global = if options.global then ' -g' else ''
      outdated = []
      installed = []
      # Note, cant see a difference between update and upgrade after printing help
      @execute
        command: "npm list --outdated --json #{global}"
        code: [0, 1]
        stdout_log: false
        shy: true
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        outdated = Object.keys pkgs.dependencies
      @execute
        $if: -> options.upgrade and outdated.length
        command: "npm update"
      , (err) ->
        throw err if err
        outdated = []
      @execute
        command: "npm list --installed --json #{global}"
        code: [0, 1]
        stdout_log: false
        shy: true
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        pkgs = Object.keys pkgs.dependencies
        installed = pkgs
      @call ->
        upgrade = options.name.filter (pkg) -> pkg in outdated
        install = options.name.filter (pkg) -> pkg not in installed
        @execute
          $if: upgrade.length
          command: "npm update #{global} #{upgrade.join ' '}"
          $sudo: options.sudo
        , (err) =>
          @log message: "NPM Updated Packages: #{upgrade.join ', '}"
        @execute
          $if: install.length
          command: "npm install #{global} #{install.join ' '}"
          $sudo: options.sudo
        , (err) =>
          @log message: "NPM Installed Packages: #{install.join ', '}"
