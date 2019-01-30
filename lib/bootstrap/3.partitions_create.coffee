
module.exports = header: "Partitions Creation", handler: ({options}) ->
  @file
    target: '/root/layout.sfdisk'
    content: """
    label: gpt
    device: #{options.disk}
    unit: sectors
    
    #{options.partitions[0]} : start=     2048, size=   2097152, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
    #{options.partitions[1]} : start=  2099200, type=E6D6D379-F507-44C2-A23C-238F2A3DF928
    """
  @system.execute """
  sfdisk #{options.disk} < /root/layout.sfdisk
  """
