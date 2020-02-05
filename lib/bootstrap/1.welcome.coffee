
module.exports = header: "System Information", handler: ({options}) ->
  @system.execute """
  hostname
  ip addr show
  """
