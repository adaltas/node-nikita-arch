
module.exports = header: "Disk Encryption", handler: (options) ->
  @execute """
  cryptsetup open --type plain #{options.disk} container --key-file /dev/random
  dd if=/dev/zero of=/dev/mapper/container status=progress bs=1M
  cryptsetup close container
  """
