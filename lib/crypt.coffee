
module.exports = handler: (options, callback) ->
  console.log 'ok', options
  return callback()
  @execute """
  cryptsetup open --type plain /dev/nvme0n1 container --key-file /dev/random
  dd if=/dev/zero of=/dev/mapper/container status=progress bs=1M
  cryptsetup close container
  """
