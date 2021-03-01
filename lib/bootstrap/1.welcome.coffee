
module.exports = metadata: header: "System Information", handler: ({config}) ->
  @execute """
  hostname
  ip addr show
  """
