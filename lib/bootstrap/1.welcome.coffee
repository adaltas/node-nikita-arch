
module.exports = header: "System Information", handler: ({options}) ->
  @system.execute """
  hostname
  ip addr show
  """, (err, status, stdout) ->
    console.log stdout if process.stdout.isTTY
