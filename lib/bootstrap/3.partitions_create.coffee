
module.exports = header: "Partitions Creation", handler: ({options}) ->
  @file
    target: '/root/layout.sfdisk'
    content: """
    /dev/nvme0n1p1 : start=     2048, size=   2097152, type=83
    /dev/nvme0n1p2 : start=  2099200, type=83
    """
  @system.execute """
  sfdisk #{options.disk} < /root/layout.sfdisk
  """
