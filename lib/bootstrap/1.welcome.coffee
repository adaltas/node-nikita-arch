
module.exports =
  metadata: header: "System Information"
  handler: ({ssh}) ->
    @execute """
    hostname
    ip addr show
    """
