
module.exports =
  'nikita/lib/log/cli':
     pad: host: 20, header: 60
  'nikita/lib/log/md':
    basedir: "#{__dirname}/../log"
  'nikita/lib/ssh/open':
    disabled: true
    host: '192.168.0.17'
    port: 22
    password: 'secret'
  './lib/system/1.system':
    disabled: false
    upgrade: false
    locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
    locale: 'en_US.UTF-8'
    users: wdavidw:
      groups: ['bumblebee', 'docker']
      shell: '/bin/zsh'
      aliases: 'll': 'ls -l'
      atom_default:
        "*":
          "core":
            "disabledPackages": [ "indent-guide-improved" ]
            "excludeVcsIgnoredPaths": false
            "ignoreNames": [".hg", ".svn", ".DS_Store", "._*", "Thumbs.db", ".git"]
            "telemetryConsent": "no"
          "editor":
            "scrollPastEnd": true
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
  'nikita/lib/ssh/close':
    disabled: true
