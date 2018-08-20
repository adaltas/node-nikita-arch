
module.exports = header: "Partitions Formating", handler: ({options}) ->
  for mount, type of options.partitions
    @system.execute switch type
      when 'f32'
        "mkfs.vfat -F32 -nESP #{mount}"
      when 'ext4'
        "mkfs.ext4 #{mount}"
      else throw Error "Invalid partition type"
