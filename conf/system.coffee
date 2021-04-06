
module.exports =
  '@nikitajs/core/lib/actions/log/cli':
    pad: host: 20, header: 60
  '@nikitajs/core/lib/actions/log/md':
    basedir: "#{__dirname}/../log"
  '@nikitajs/core/lib/actions/ssh/open':
    $disabled: true
    host: 'XXX.XXX.XXX.XXX'
    port: 22
    password: 'XXXXXX'
  './lib/system/1.system':
    $disabled: false
    upgrade: false
    locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
    locale: 'en_US.UTF-8'
    groups: [
      name: 'docker'
      system: true
    ]
    user:
      groups: ['bumblebee', 'docker']
      shell: '/bin/zsh'
    aliases: 'll': 'ls -l'
  './lib/system/2.dev':
    atom_config:
      "*":
        "core":
          "autoHideMenuBar": true
          "closeDeletedFileTabs": true
          "disabledPackages": [ "indent-guide-improved" ]
          "excludeVcsIgnoredPaths": false
          "ignoreNames": [".hg", ".svn", ".DS_Store", "._*", "Thumbs.db", ".git", "node_modules"]
          "telemetryConsent": "no"
        "editor":
          "fontSize": 13
          "scrollPastEnd": true
        "git-plus":
          "remoteInteractions":
            "pullRebase": true
        "language-log":
          "tail": true
        "minimap":
          "plugins":
            "find-and-replace": true
            "find-and-replaceDecorationsZIndex": 0
            "highlight-selected": true
            "highlight-selectedDecorationsZIndex": 0
            "selection": true
            "selectionDecorationsZIndex": 0
        "tree-view":
          "hideVcsIgnoredFiles": false
        "welcome":
          "showOnStartup": false
        "whitespace":
          "removeTrailingWhitespace": false
      ".basic.html.text":
        "editor":
          "preferredLIneLength": 81
        "multi-wrap-guid": "column": [81]
      ".coffee.md":
        "whitespace":
          "removeTrailingWhitespace": false
      ".coffee.source":
        "editor":
          "autoIndent": true
          "autoIndentOnPaste": false
      ".jade.source":
        "editor":
          "autoIndent": true
          "autoIndentOnPaste": false
      ".md":
        "whitespace":
          "removeTrailingWhitespace": false
  './lib/system/3.office': {}
  '@nikitajs/core/lib/actions/ssh/close':
    $disabled: true
