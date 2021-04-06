
# `nikital.system.apm`

Install Atom packages with APM.

## Options

*   `name` (string|array)
    Name of the package(s).
*   `upgrade` (boolean)
    Upgrade all packages, default to "false".

## Source code

    module.exports = ({options}) ->
      options.name = options.argument if options.argument?
      options.name = [options.name] if typeof options.name is 'string'
      options.name = options.name.map (pkg) -> pkg.toLowerCase()
      outdated = []
      installed = []
      # Note, cant see a difference between update and upgrade after printing help
      @execute
        command: "apm outdated --json"
        shy: true
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        outdated = pkgs.map (pkg) -> pkg.name.toLowerCase()
      @execute
        command: "apm upgrade --no-confirm"
        $if: -> options.upgrade and outdated.length
      , (err) ->
        throw err if err
        outdated = []
      @execute
        command: "apm list --installed --json"
        shy: true
      , (err, {stdout}) ->
        throw err if err
        pkgs = JSON.parse stdout
        pkgs = pkgs.user.map (pkg) -> pkg.name.toLowerCase()
        installed = pkgs
      @call ->
        upgrade = options.name.filter (pkg) -> pkg in outdated
        install = options.name.filter (pkg) -> pkg not in installed
        @execute
          command: "apm upgrade #{upgrade.join ' '}"
          $if: upgrade.length
        , (err) =>
          @log message: "APM Updated Packages: #{upgrade.join ', '}"
        @execute
          command: "apm install #{install.join ' '}"
          $if: install.length
        , (err) =>
          @log message: "APM Installed Packages: #{install.join ', '}"
