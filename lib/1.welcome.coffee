
module.exports = header: "System Information", handler: (options) ->
  @execute """
  hostname
  ip addr show
  """, (err, status, stdout) ->
    console.log stdout if process.stdout.isTTY
    
